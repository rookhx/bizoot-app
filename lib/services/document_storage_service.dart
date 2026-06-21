import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_document.dart';

class PickedDocumentAsset {
  final String fileName;
  final String fileExtension;
  final String mimeType;
  final int fileSize;
  final Uint8List bytes;
  final String? localPath;

  const PickedDocumentAsset({
    required this.fileName,
    required this.fileExtension,
    required this.mimeType,
    required this.fileSize,
    required this.bytes,
    required this.localPath,
  });

  bool get isImage {
    final normalized = fileExtension.toLowerCase();
    return normalized == 'jpg' ||
        normalized == 'jpeg' ||
        normalized == 'png' ||
        normalized == 'webp' ||
        normalized == 'heic';
  }
}

class DocumentStorageService {
  DocumentStorageService({required this.cloudSyncEnabled});

  final bool cloudSyncEnabled;

  static const _localKeyPrefix = 'bizoot_user_documents_';
  static const _deletedKeyPrefix = 'bizoot_deleted_user_documents_';
  static const _maxFileSizeBytes = 10 * 1024 * 1024;
  static const _allowedExtensions = <String>{
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
  };
  static const _uuid = Uuid();

  String _documentsKeyForUser(String userId) => '$_localKeyPrefix$userId';
  String _deletedKeyForUser(String userId) => '$_deletedKeyPrefix$userId';
  Reference _storageRef(String storagePath) =>
      FirebaseStorage.instance.ref().child(storagePath);
  CollectionReference<Map<String, dynamic>> _documentsCollection(
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('documents');
  }

  Future<PickedDocumentAsset?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions.toList(growable: false),
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;
    final extension = _normalizeExtension(
      file.extension ?? _extractExtension(file.name),
    );
    if (!_allowedExtensions.contains(extension)) {
      throw StateError('unsupported_document_type');
    }
    if (file.size > _maxFileSizeBytes) {
      throw StateError('document_too_large');
    }

    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      throw StateError('document_bytes_missing');
    }

    return PickedDocumentAsset(
      fileName: file.name,
      fileExtension: extension,
      mimeType: _mimeTypeForExtension(extension),
      fileSize: file.size,
      bytes: bytes,
      localPath: file.path,
    );
  }

  Future<List<UserDocument>> fetchDocuments(String userId) async {
    if (cloudSyncEnabled) {
      try {
        final remote = await fetchRemoteDocuments(userId);
        await saveLocalDocuments(userId, remote);
        return remote;
      } catch (_) {
        // Fall back to local snapshot.
      }
    }
    return fetchLocalDocuments(userId);
  }

  Future<List<UserDocument>> fetchRemoteDocuments(String userId) async {
    final snapshot = await _documentsCollection(
      userId,
    ).orderBy('uploaded_at', descending: true).get();
    return snapshot.docs
        .map((doc) => UserDocument.fromMap({...doc.data(), 'id': doc.id}))
        .toList(growable: false);
  }

  Future<List<UserDocument>> fetchLocalDocuments(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_documentsKeyForUser(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map((item) => UserDocument.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<UserDocument> uploadDocument({
    required String userId,
    required PickedDocumentAsset asset,
    required String title,
    required UserDocumentCategory category,
    String? linkedItemId,
    LinkedItemType? linkedItemType,
    String notes = '',
  }) async {
    final documentId = _uuid.v4();
    final storagePath =
        '$userId/$documentId/${_sanitizeFileName(asset.fileName)}';
    final now = DateTime.now();
    final document = UserDocument(
      id: documentId,
      userId: userId,
      linkedItemId: linkedItemId,
      linkedItemType: linkedItemType,
      title: title.trim().isEmpty
          ? _fallbackTitleFromFileName(asset.fileName)
          : title.trim(),
      originalFileName: asset.fileName,
      filePath: storagePath,
      mimeType: asset.mimeType,
      fileExtension: asset.fileExtension,
      fileSize: asset.fileSize,
      documentCategory: category,
      notes: notes.trim(),
      uploadedAt: now,
      updatedAt: now,
    );

    await _uploadBinary(storagePath, asset.bytes, asset.mimeType);
    await _upsertLocalDocument(document);
    if (cloudSyncEnabled) {
      try {
        await upsertRemoteDocuments([document]);
      } catch (_) {
        // Leave local snapshot intact so sync can retry later.
      }
    }
    return document;
  }

  Future<UserDocument> replaceDocument({
    required UserDocument existing,
    required PickedDocumentAsset asset,
    String? title,
    UserDocumentCategory? category,
    String? notes,
  }) async {
    final nextPath =
        '${existing.userId}/${existing.id}/${_sanitizeFileName(asset.fileName)}';
    if (cloudSyncEnabled &&
        existing.filePath.isNotEmpty &&
        existing.filePath != nextPath) {
      try {
        await _deleteBinary(existing.filePath);
      } catch (_) {
        // Ignore cleanup failure and continue with the new upload.
      }
    }
    await _uploadBinary(nextPath, asset.bytes, asset.mimeType);

    final updated = existing.copyWith(
      title: (title ?? existing.title).trim(),
      originalFileName: asset.fileName,
      filePath: nextPath,
      mimeType: asset.mimeType,
      fileExtension: asset.fileExtension,
      fileSize: asset.fileSize,
      documentCategory: category ?? existing.documentCategory,
      notes: notes ?? existing.notes,
      updatedAt: DateTime.now(),
    );

    await _upsertLocalDocument(updated);
    if (cloudSyncEnabled) {
      try {
        await upsertRemoteDocuments([updated]);
      } catch (_) {
        // Keep local snapshot and let sync retry later.
      }
    }
    return updated;
  }

  Future<void> deleteDocument(UserDocument document) async {
    await _deleteLocalDocument(document.userId, document.id);
    await recordDeletedDocumentId(document.userId, document.id);
    if (cloudSyncEnabled) {
      try {
        if (document.filePath.isNotEmpty) {
          await _deleteBinary(document.filePath);
        }
        await deleteRemoteDocument(document.id);
        await clearDeletedDocumentIds(document.userId, {document.id});
      } catch (_) {
        // Keep tombstone for later cleanup.
      }
    }
  }

  Future<UserDocument> linkDocumentToItem({
    required UserDocument document,
    required String linkedItemId,
    required LinkedItemType linkedItemType,
  }) async {
    final updated = document.copyWith(
      linkedItemId: linkedItemId,
      linkedItemType: linkedItemType,
      updatedAt: DateTime.now(),
    );
    await _upsertLocalDocument(updated);
    if (cloudSyncEnabled) {
      try {
        await upsertRemoteDocuments([updated]);
      } catch (_) {
        // Keep local snapshot and let sync retry later.
      }
    }
    return updated;
  }

  Future<UserDocument> unlinkDocumentFromItem(UserDocument document) async {
    final updated = document.copyWith(
      clearLinkedItemId: true,
      clearLinkedItemType: true,
      updatedAt: DateTime.now(),
    );
    await _upsertLocalDocument(updated);
    if (cloudSyncEnabled) {
      try {
        await upsertRemoteDocuments([updated]);
      } catch (_) {
        // Keep local snapshot and let sync retry later.
      }
    }
    return updated;
  }

  Future<void> unlinkDocumentsForItem(String userId, String itemId) async {
    final documents = await fetchLocalDocuments(userId);
    final linked = documents
        .where((item) => item.linkedItemId == itemId)
        .toList(growable: false);
    for (final document in linked) {
      await unlinkDocumentFromItem(document);
    }
  }

  Future<String> getSignedUrl(
    UserDocument document, {
    int expiresInSeconds = 60 * 15,
  }) async {
    if (!cloudSyncEnabled) {
      throw StateError('document_view_unavailable_offline');
    }
    return _storageRef(document.filePath).getDownloadURL();
  }

  Future<void> upsertRemoteDocuments(List<UserDocument> documents) async {
    if (documents.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final document in documents) {
      batch.set(
        _documentsCollection(document.userId).doc(document.id),
        document.toMap(),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> deleteRemoteDocument(String documentId) async {
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('documents')
        .where(FieldPath.documentId, isEqualTo: documentId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.delete();
  }

  Future<void> deleteAllRemoteDocuments(String userId) async {
    final snapshot = await _documentsCollection(userId).get();
    if (snapshot.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> saveLocalDocuments(
    String userId,
    List<UserDocument> documents,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _documentsKeyForUser(userId),
      jsonEncode(documents.map((item) => item.toMap()).toList(growable: false)),
    );
  }

  Future<void> recordDeletedDocumentId(String userId, String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds =
        prefs.getStringList(_deletedKeyForUser(userId)) ?? const <String>[];
    final next = {...deletedIds, documentId}.toList(growable: false);
    await prefs.setStringList(_deletedKeyForUser(userId), next);
  }

  Future<Set<String>> listDeletedDocumentIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_deletedKeyForUser(userId)) ?? const <String>[])
        .toSet();
  }

  Future<void> clearDeletedDocumentIds(String userId, Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final existing =
        prefs.getStringList(_deletedKeyForUser(userId)) ?? const <String>[];
    final next = existing
        .where((id) => !ids.contains(id))
        .toList(growable: false);
    if (next.isEmpty) {
      await prefs.remove(_deletedKeyForUser(userId));
      return;
    }
    await prefs.setStringList(_deletedKeyForUser(userId), next);
  }

  Future<void> deleteAllForUser(String userId) async {
    final documents = await fetchLocalDocuments(userId);
    if (cloudSyncEnabled) {
      final paths = documents
          .map((item) => item.filePath)
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      if (paths.isNotEmpty) {
        try {
          await Future.wait(paths.map(_deleteBinary));
        } catch (_) {
          // Best-effort cleanup.
        }
      }
      try {
        await deleteAllRemoteDocuments(userId);
      } catch (_) {
        // Best-effort cleanup.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_documentsKeyForUser(userId));
    await prefs.remove(_deletedKeyForUser(userId));
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where(
      (key) =>
          key.startsWith(_localKeyPrefix) || key.startsWith(_deletedKeyPrefix),
    )) {
      await prefs.remove(key);
    }
  }

  Future<void> _uploadBinary(
    String storagePath,
    Uint8List bytes,
    String mimeType,
  ) async {
    if (!cloudSyncEnabled) {
      throw StateError('document_upload_unavailable_offline');
    }
    await _storageRef(
      storagePath,
    ).putData(bytes, SettableMetadata(contentType: mimeType));
  }

  Future<void> _deleteBinary(String storagePath) async {
    await _storageRef(storagePath).delete();
  }

  Future<void> _upsertLocalDocument(UserDocument document) async {
    final documents = await fetchLocalDocuments(document.userId);
    final index = documents.indexWhere((item) => item.id == document.id);
    final next = [...documents];
    if (index == -1) {
      next.insert(0, document);
    } else {
      next[index] = document;
    }
    await saveLocalDocuments(document.userId, next);
  }

  Future<void> _deleteLocalDocument(String userId, String documentId) async {
    final documents = await fetchLocalDocuments(userId);
    final next = documents
        .where((item) => item.id != documentId)
        .toList(growable: false);
    await saveLocalDocuments(userId, next);
  }

  String _extractExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(dotIndex + 1);
  }

  String _normalizeExtension(String value) => value.trim().toLowerCase();

  String _sanitizeFileName(String fileName) {
    final safe = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return safe.isEmpty ? 'document' : safe;
  }

  String _fallbackTitleFromFileName(String fileName) {
    final base = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    return base.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  }

  String _mimeTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'application/octet-stream';
    }
  }
}
