// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Bizoot';

  @override
  String get dashboard => 'Panel';

  @override
  String get calendar => 'Calendario';

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String get reports => 'Informes';

  @override
  String get settings => 'Configuración';

  @override
  String get premium => 'Premium';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authCreateAccount => 'Crea tu cuenta de Bizoot';

  @override
  String get authWelcomeSubtitle =>
      'Inicia sesión para ver lo que tus gastos fijos realmente le hacen a tu mes.';

  @override
  String get authCreateSubtitle =>
      'Crea tu cuenta y reúne cada cargo recurrente en un centro de control premium.';

  @override
  String get authHero => 'Deja de perder dinero en suscripciones olvidadas.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get logIn => 'Iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get enterEmailPassword =>
      'Introduce tu correo y tu contraseña para continuar.';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get needAccount => '¿Necesitas una cuenta? Regístrate';

  @override
  String onboardingStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get back => 'Atrás';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get finishSetup => 'Finalizar configuración';

  @override
  String get finishingSetup => 'Finalizando configuración...';

  @override
  String get fullNameAndCountryRequired =>
      'El nombre completo y el país son obligatorios.';

  @override
  String get validCountryRequired => 'Selecciona un país válido de la lista.';

  @override
  String get profileSetup => 'Configuración del perfil';

  @override
  String get profileSetupSubtitle =>
      'Vamos a personalizar Bizoot antes de empezar a seguir tus gastos recurrentes.';

  @override
  String get tapChooseProfilePicture => 'Toca para elegir una foto de perfil';

  @override
  String get profilePictureSelected => 'Foto de perfil seleccionada';

  @override
  String get opensPhoneGallery => 'Abre la galería de tu teléfono';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get phoneNumberOptional => 'Número de teléfono (opcional)';

  @override
  String get country => 'País';

  @override
  String get financialSetup => 'Configuración financiera';

  @override
  String get financialSetupSubtitle =>
      'Elige la configuración monetaria que Bizoot debe usar en tu panel, insights y recordatorios.';

  @override
  String get currency => 'Moneda';

  @override
  String get currencyAutoSelected =>
      'Se selecciona automáticamente según el país que elijas.';

  @override
  String get monthlyIncome => 'Ingresos mensuales';

  @override
  String get monthlyIncomeHelper =>
      'Opcional, pero recomendable para Health Score y gasto seguro.';

  @override
  String get mainFinancialGoal => 'Objetivo financiero principal';

  @override
  String get estimatedSubscriptions => 'Suscripciones estimadas';

  @override
  String estimatedSubscriptionsLabel(int count) {
    return '$count suscripciones';
  }

  @override
  String get goalSaveMoney => 'Ahorrar dinero';

  @override
  String get goalTrackBills => 'Controlar facturas';

  @override
  String get goalAvoidSurpriseCharges => 'Evitar cargos sorpresa';

  @override
  String get goalCancelUnusedSubscriptions =>
      'Cancelar suscripciones no usadas';

  @override
  String get settingsSyncing => 'Guardando tus últimos cambios de Bizoot...';

  @override
  String get settingsOffline =>
      'Modo sin conexión activo. Tus cambios están seguros y continuarán cuando vuelvas a conectarte.';

  @override
  String get settingsPendingChanges =>
      'Algunos cambios recientes aún se están guardando.';

  @override
  String get settingsReady =>
      'Aquí viven tus ajustes de cuenta, recordatorios, privacidad y soporte.';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription =>
      'Elige el idioma que Bizoot debe usar en toda la app.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDanish => 'Dansk';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageUpdated => 'Idioma actualizado.';

  @override
  String get notificationPreferencesUpdated =>
      'Preferencias de notificaciones actualizadas.';

  @override
  String get notificationPreferencesFailed =>
      'No pudimos actualizar tus preferencias de notificaciones ahora mismo.';

  @override
  String get signOutQuestion => '¿Cerrar sesión en Bizoot?';

  @override
  String get signOutBody =>
      'Volverás a la pantalla de inicio de sesión y tus datos sincronizados seguirán vinculados a tu cuenta.';

  @override
  String get staySignedIn => 'Seguir conectado';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get openPhoneNotificationSettings =>
      'Abrir ajustes de notificaciones del teléfono';

  @override
  String get paymentReminders => 'Recordatorios de pago';

  @override
  String get paymentRemindersSubtitle =>
      'Recordatorios para tus suscripciones activas que vencen mañana o pronto.';

  @override
  String get weeklySummaries => 'Resúmenes semanales';

  @override
  String get weeklySummariesSubtitle =>
      'Resúmenes del domingo por la noche con renovaciones y totales de la próxima semana.';

  @override
  String get trialAlerts => 'Alertas de prueba';

  @override
  String get trialAlertsSubtitle =>
      'Avisos antes de que una prueba gratuita se convierta en una suscripción de pago.';

  @override
  String get smartInsights => 'Smart insights';

  @override
  String get smartInsightsSubtitle =>
      'Sugerencias de ahorro, seguimientos de cancelación y avisos sobre gasto recurrente.';

  @override
  String get promotionalNotifications => 'Notificaciones promocionales';

  @override
  String get promotionalNotificationsSubtitle =>
      'Actualizaciones opcionales del producto, noticias de lanzamientos y anuncios de funciones.';

  @override
  String premiumRequiredSuffix(Object text) {
    return '$text Se requiere Premium.';
  }

  @override
  String get subscriptionPremium => 'Suscripción y Premium';

  @override
  String get currentPlan => 'Plan actual';

  @override
  String get trialStatus => 'Estado de prueba';

  @override
  String get subscriptionUsage => 'Uso de suscripción';

  @override
  String get whatHappensNow => 'Qué ocurre ahora';

  @override
  String get planPremium => 'Premium';

  @override
  String get planTrial => 'Prueba de 7 días';

  @override
  String get planFree => 'Gratis';

  @override
  String get premiumUnlocked => 'Premium desbloqueado';

  @override
  String trialDaysRemaining(int days) {
    return '$days días restantes';
  }

  @override
  String get trialEnded => 'Prueba finalizada';

  @override
  String subscriptionsTrackedUnlimited(int count) {
    return '$count suscripciones seguidas • plan ilimitado';
  }

  @override
  String subscriptionsUsed(int count, int limit) {
    return '$count / $limit suscripciones usadas';
  }

  @override
  String get premiumActiveDescription =>
      'Tienes seguimiento ilimitado de suscripciones y todas las funciones premium desbloqueadas.';

  @override
  String get trialPremiumDescription =>
      'Tienes todas las funciones premium durante la prueba, con un límite de 5 suscripciones.';

  @override
  String freePlanDescription(int limit) {
    return 'Puedes seguir hasta $limit suscripciones activas en este plan.';
  }

  @override
  String get limitReachedDescription =>
      'Límite alcanzado: actualiza para seguimiento ilimitado.';

  @override
  String get upgradeToPremium => 'Actualizar a Premium';

  @override
  String get premiumFeatureComparison => 'Comparación de funciones premium';

  @override
  String get premiumCompareFree =>
      'Gratis: hasta 5 suscripciones activas, recordatorios básicos y seguimiento esencial';

  @override
  String get premiumCompareOne =>
      'Premium: suscripciones ilimitadas, informes avanzados y smart insights';

  @override
  String get premiumCompareTwo =>
      'Premium: mejor inteligencia de cancelación, resúmenes semanales e insights más profundos';

  @override
  String get privacySecurity => 'Privacidad y seguridad';

  @override
  String get privacyAiSettings => 'Privacidad y ajustes de IA';

  @override
  String get privacyAiSubtitle =>
      'Controla los insights de IA y revisa cómo Bizoot protege la información sensible.';

  @override
  String get support => 'Soporte';

  @override
  String get contactSupport => 'Contactar con soporte';

  @override
  String get contactSupportSubtitle =>
      'Obtén ayuda, informa de un problema o comparte comentarios con el equipo de Bizoot.';

  @override
  String get legal => 'Legal';

  @override
  String get savedServices => 'Servicios guardados';

  @override
  String get dangerZone => 'Zona de riesgo';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get savedServicesEmptyTitle => 'Aún no hay servicios personalizados';

  @override
  String get savedServicesEmptyBody =>
      'Cuando crees una suscripción personalizada con tu propio enlace de cancelación, Bizoot la recordará aquí para un autocompletado más rápido la próxima vez.';

  @override
  String get savedServiceUpdated => 'Servicio guardado actualizado.';

  @override
  String get savedServiceUpdatedFailed =>
      'No pudimos actualizar ese servicio guardado ahora mismo.';

  @override
  String get editSavedService => 'Editar servicio guardado';

  @override
  String get deleteSavedService => 'Eliminar servicio guardado';

  @override
  String get cancellationUrl => 'URL de cancelación';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get deleteSavedServiceQuestion => '¿Eliminar servicio guardado?';

  @override
  String deleteSavedServiceBody(Object serviceName) {
    return 'Bizoot olvidará $serviceName y dejará de sugerirlo desde tu lista personalizada.';
  }

  @override
  String get savedServiceDeleted => 'Servicio guardado eliminado.';

  @override
  String get savedServiceDeletedFailed =>
      'No pudimos eliminar ese servicio guardado ahora mismo.';

  @override
  String get noSavedCancellationUrl =>
      'Aún no hay URL de cancelación guardada.';

  @override
  String usedTimes(int count) {
    return 'Usado $count veces';
  }

  @override
  String get debugLocalization => 'Depuración de localización';

  @override
  String get currentLocale => 'Configuración regional actual';

  @override
  String get supportedLocalesLabel => 'Configuraciones regionales compatibles';

  @override
  String get fallbackBehavior => 'Comportamiento de reserva';

  @override
  String get fallbackBehaviorValue =>
      'Los idiomas del dispositivo no compatibles vuelven al inglés.';

  @override
  String get missingTranslationFallbackCount =>
      'Conteo de reserva por traducciones faltantes';

  @override
  String get premiumTooltip => 'Premium';
}
