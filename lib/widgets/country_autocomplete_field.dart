import 'package:flutter/material.dart';

import '../l10n/locale_text.dart';
import '../theme/app_theme.dart';
import '../utils/country_currency_data.dart';

class CountryAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<CountryCurrency> onSelected;

  const CountryAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.onSelected,
  });

  @override
  State<CountryAutocompleteField> createState() => _CountryAutocompleteFieldState();
}

class _CountryAutocompleteFieldState extends State<CountryAutocompleteField> {
  late final FocusNode _focusNode;
  final GlobalKey _fieldKey = GlobalKey();
  static const _openDirection = OptionsViewOpenDirection.up;
  double? _fieldWidth;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  void _updateMenuLayout() {
    final fieldContext = _fieldKey.currentContext;
    if (fieldContext == null) return;
    final renderBox = fieldContext.findRenderObject();
    if (renderBox is! RenderBox) return;

    final size = renderBox.size;
    if (_fieldWidth != size.width) {
      setState(() {
        _fieldWidth = size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: BizootColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return RawAutocomplete<CountryCurrency>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsViewOpenDirection: _openDirection,
      displayStringForOption: (option) => option.name,
      optionsBuilder: (textEditingValue) {
        final query = _normalize(textEditingValue.text);
        if (query.isEmpty) {
          return allCountries;
        }
        return allCountries.where((country) {
          final name = _normalize(country.name);
          return name.contains(query) || name.startsWith(query);
        });
      },
      onSelected: (value) {
        widget.controller.text = value.name;
        widget.onSelected(value);
      },
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        return KeyedSubtree(
          key: _fieldKey,
          child: TextField(
            controller: fieldController,
            focusNode: focusNode,
            style: textStyle,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: localeText(
                context,
                en: 'Search countries A-Z',
                da: 'Søg lande A-Z',
                de: 'Länder A-Z suchen',
                es: 'Buscar países de la A a la Z',
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onTap: () {
              _updateMenuLayout();
              if (!focusNode.hasFocus) {
                focusNode.requestFocus();
              }
            },
            onChanged: (_) => _updateMenuLayout(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final optionList = options.toList(growable: false);
        return Align(
          alignment: Alignment.bottomLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: _fieldWidth,
              constraints: const BoxConstraints(maxHeight: 220),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: BizootColors.surfaceElevated.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: BizootColors.border.withValues(alpha: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  itemCount: optionList.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: BizootColors.border.withValues(alpha: 0.4),
                  ),
                  itemBuilder: (context, index) {
                    final country = optionList[index];
                    return InkWell(
                      onTap: () => onSelected(country),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Text(
                          country.name,
                          style: textStyle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
