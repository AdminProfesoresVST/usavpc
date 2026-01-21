// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Consular Assistant';

  @override
  String get officialGuide => 'Guía Oficial';

  @override
  String get heroTitle => 'Simplifica tu Trámite Consular';

  @override
  String get heroSubtitle =>
      'Escanea documentos y simula tu entrevista para asegurar tu visa.';

  @override
  String get howItWorks => 'Cómo funciona';

  @override
  String get stepScan => 'Escanear';

  @override
  String get stepScanSubtitle => 'Pasaporte';

  @override
  String get stepSimulate => 'Simular';

  @override
  String get stepSimulateSubtitle => 'Entrevista AI';

  @override
  String get stepResults => 'Resultados';

  @override
  String get stepResultsSubtitle => 'Obtén Reporte';

  @override
  String get popularServices => 'Servicios Populares';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get newVisaApplication => 'Nueva Solicitud de Visa';

  @override
  String get newVisaSubtitle => 'Escanea tu ID para autocompletar formularios.';

  @override
  String get badgeFast => 'RÁPIDO';

  @override
  String get interviewSimulator => 'Simulador de Entrevista';

  @override
  String get interviewSimulatorSubtitle =>
      'Practica preguntas reales con nuestra IA.';

  @override
  String get documentAudit => 'Auditoría de Documentos';

  @override
  String get documentAuditSubtitle =>
      'Lista personalizada según tu tipo de visa.';

  @override
  String get securityNote => 'Tus datos están seguros y encriptados.';

  @override
  String get loginTitle => 'Iniciar Sesión';

  @override
  String get loginAppName => 'USA Visa Processing';

  @override
  String get emailLabel => 'Correo Electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'INGRESAR / LOGIN';

  @override
  String get createAccountLink => 'Crear una cuenta / Create Account';

  @override
  String get quickFillTest => 'Llenado Rápido (Usuario de Prueba)';

  @override
  String get nonGovernmentDisclaimer => 'Servicio no gubernamental';

  @override
  String get emailRequired => 'Por favor ingrese su correo';

  @override
  String get emailInvalid => 'Correo inválido';

  @override
  String get passwordRequired => 'Por favor ingrese su contraseña';

  @override
  String get dashboardTitle => 'Mi Solicitud';

  @override
  String get applicationStatus => 'Estado de Solicitud';

  @override
  String get nextSteps => 'Próximos Pasos';

  @override
  String percentComplete(int percent) {
    return '$percent% Completado';
  }

  @override
  String lastEdited(String date) {
    return 'Última edición: $date';
  }

  @override
  String get statusDraft => 'Borrador';

  @override
  String get statusPendingPayment => 'Pendiente de Pago';

  @override
  String get statusPaid => 'Pagado';

  @override
  String get statusSubmitted => 'Enviado';

  @override
  String get statusNotStarted => 'Sin Iniciar';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get settingsOption => 'Configuración';

  @override
  String get helpOption => 'Ayuda y Soporte';

  @override
  String get logoutOption => 'Cerrar Sesión';

  @override
  String get settingsComingSoon => 'Configuración próximamente';

  @override
  String get contactSupport => 'Contacte: soporte@usavpc.org';

  @override
  String get noEmail => 'Sin correo';

  @override
  String get defaultUser => 'Usuario';

  @override
  String get verificationTitle => 'VERIFICACIÓN DE IDENTIDAD';

  @override
  String get scanDocument => 'Escanee su Documento';

  @override
  String get scanDocumentSubtitle =>
      'Necesitamos capturar los datos de su pasaporte para autocompletar su solicitud.';

  @override
  String get useCamera => 'Usar Cámara';

  @override
  String get useCameraSubtitle => 'Escanear directamente';

  @override
  String get uploadImage => 'Subir Imagen';

  @override
  String get uploadImageSubtitle => 'Desde galería';

  @override
  String get dataSecure => 'Sus datos están encriptados y seguros';

  @override
  String get documentValidated => 'Documento validado correctamente';

  @override
  String get noValidPassport =>
      'No se detectó un pasaporte válido. Intente de nuevo.';

  @override
  String get ds160Assistant => 'Asistente DS-160';

  @override
  String questionProgress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get typeYourResponse => 'Escribe tu respuesta...';

  @override
  String loadingQuestionsError(String error) {
    return 'Error cargando preguntas: $error';
  }

  @override
  String get validationError =>
      'Hmm, eso no parece correcto. ¿Puedes verificar?';

  @override
  String savingError(String error) {
    return 'Error guardando: $error';
  }

  @override
  String get intakeComplete =>
      '🎉 ¡Excelente! Has completado todas las preguntas. Tu información está guardada y lista para generar tu formulario DS-160.';

  @override
  String get viewMyApplication => 'VER MI SOLICITUD';

  @override
  String get tips => 'Tips:';

  @override
  String example(String text) {
    return 'Ejemplo: $text';
  }

  @override
  String get preliminaryAuditTitle => 'Auditoría Preliminar';

  @override
  String get eligibilityVerification => 'Verificación de Elegibilidad';

  @override
  String get eligibilitySubtitle =>
      'Antes de simular su entrevista, analizaremos su perfil básico para detectar riesgos evidentes.';

  @override
  String get visaTypeLabel => 'Tipo de Visa Solicitada';

  @override
  String get visaB1B2 => 'B1/B2 - Turismo y Negocios';

  @override
  String get visaF1 => 'F1 - Estudiante';

  @override
  String get visaH2 => 'H2 - Trabajo Temporal';

  @override
  String get ds160Question => '¿Ya completó su formulario DS-160?';

  @override
  String get yesHaveCode => 'Sí, tengo el código';

  @override
  String get notYet => 'No, aún no';

  @override
  String get ds160CodeLabel => 'Código de Confirmación DS-160';

  @override
  String get ds160CodeHint => 'Ej: AA00...';

  @override
  String get enterCode => 'Ingrese el código';

  @override
  String get codeStartAA => 'Debe comenzar con \"AA\"';

  @override
  String get noDs160Warning =>
      'Para una auditoría precisa, recomendamos tener el formulario listo. Puede continuar, pero el análisis será limitado.';

  @override
  String get startAnalysis => 'COMENZAR ANÁLISIS';

  @override
  String get simulatorTitle => 'Simulador de Entrevista';

  @override
  String get simulatorDescription =>
      'Practique con nuestro Oficial Consular de IA. Responda verbalmente para evaluar su fluidez y coherencia.';

  @override
  String get enableMicrophone => 'HABILITAR MICRÓFONO';

  @override
  String get startInterview => 'INICIAR ENTREVISTA';

  @override
  String get microphoneRequired =>
      'Se requiere micrófono para el simulador de voz.';

  @override
  String get languageSettingTitle => 'Idioma';

  @override
  String get selectLanguageTitle => 'Seleccionar Idioma';

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get registerTitle => 'Crear Cuenta';

  @override
  String get confirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get registerButton => 'REGISTRARSE / SIGN UP';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta? Inicia Sesión';

  @override
  String get fieldRequired => 'Requerido';

  @override
  String passwordMinLength(int count) {
    return 'Mínimo $count caracteres';
  }

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get accountCreated => '¡Cuenta Creada! Bienvenido.';

  @override
  String get orderSummaryTitle => 'Resumen del Pedido';

  @override
  String get total => 'Total';

  @override
  String payButton(String amount) {
    return 'Pagar \$$amount';
  }

  @override
  String get processing => 'Procesando...';

  @override
  String get paymentCompleted => '¡Pago completado exitosamente!';

  @override
  String paymentCancelled(String message) {
    return 'Pago cancelado: $message';
  }

  @override
  String get securePayment => 'Pago seguro con Stripe';

  @override
  String get priorityProcessing => 'Procesamiento Prioritario';

  @override
  String get noPlansAvailable => 'No hay planes disponibles';

  @override
  String get userNotAuthenticated => 'Usuario no autenticado';

  @override
  String get approvalAuditTitle => 'Auditoría de Aprobación';

  @override
  String get approvalProbability => 'Probabilidad de Aprobación';

  @override
  String riskLevel(String level) {
    return 'Riesgo $level';
  }

  @override
  String get factorAnalysis => 'Análisis Factorial';

  @override
  String get continueToSimulator => 'CONTINUAR AL SIMULADOR';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String errorLoadingData(String error) {
    return 'Error cargando datos: $error';
  }

  @override
  String get confirmDataTitle => 'Confirmar Datos';

  @override
  String get passportScanned => 'Pasaporte Escaneado';

  @override
  String get verifyDataCorrect => 'Verifica que los datos sean correctos';

  @override
  String get surnameLabel => 'Apellido(s)';

  @override
  String get givenNameLabel => 'Nombre(s)';

  @override
  String get birthDateLabel => 'Fecha de Nacimiento';

  @override
  String get nationalityLabel => 'Nacionalidad';

  @override
  String get passportNumberLabel => 'Número de Pasaporte';

  @override
  String get additionalQuestionsInfo =>
      'Después de confirmar, te haré algunas preguntas adicionales que no están en tu pasaporte.';

  @override
  String get confirmAndContinue => 'CONFIRMAR Y CONTINUAR';

  @override
  String get interviewInProgress => 'Entrevista en Curso';

  @override
  String get pressMicToSpeak => 'Presione el micrófono para hablar...';

  @override
  String get connectingToOfficer => 'Conectando con el Oficial Consular...';

  @override
  String get listening => 'Escuchando...';

  @override
  String get ds160AutoFill => 'DS-160 AUTO-FILL';

  @override
  String get inject => 'INYECTAR';

  @override
  String get consoleOutput => '> CONSOLE OUTPUT';

  @override
  String get passportDetected => '¡Pasaporte Detectado!';

  @override
  String get passportScanInstructions =>
      'Escanee la zona de datos del pasaporte';

  @override
  String get searchingMRZ => 'Buscando MRZ...';

  @override
  String get detected => '¡Detectado!';
}
