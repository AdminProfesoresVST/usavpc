// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dataSavedSuccess => 'Datos guardados exitosamente';

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
  String get verificationTitle => 'Verificación de Identidad';

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
  String get example => 'Ejemplo';

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
  String get visaB1B2 => 'Visitante Negocios/Turismo';

  @override
  String get visaF1 => 'Estudiante Académico';

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
  String get fieldRequired => 'Este campo es obligatorio';

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
  String get ds160AutoFill => 'DS-160 Auto-fill';

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

  @override
  String get navigatingTo => 'Navegando a';

  @override
  String get pageLoaded => 'Página cargada';

  @override
  String get networkError => 'Error de red';

  @override
  String get detectingFormFields => 'Detectando campos del formulario...';

  @override
  String get injectingData => 'Inyectando datos en formulario...';

  @override
  String fieldsFilled(int filled, int notFound) {
    return 'Campos llenados: $filled | No encontrados: $notFound';
  }

  @override
  String get injectionComplete => 'Inyección completada';

  @override
  String get automationReady =>
      'Automatización lista. Revise los datos y continúe manualmente.';

  @override
  String get processComplete =>
      'PROCESO COMPLETADO - Verifique los datos antes de continuar';

  @override
  String get injectionError => 'Error durante inyección';

  @override
  String get costCalculatorTitle => 'Calculadora de Costos';

  @override
  String get costCalculatorSubtitle => 'Estimación completa de tarifas';

  @override
  String get travelBanTitle => 'Verificar Restricciones';

  @override
  String get travelBanSubtitle => 'Chequeo de Travel Ban 2026';

  @override
  String get knowYourTotal => 'Conoce tu Total';

  @override
  String get knowYourTotalSubtitle => 'Calcula todas las tarifas para tu visa';

  @override
  String get yourNationality => 'Tu Nacionalidad';

  @override
  String get selectCountry => 'Selecciona tu país';

  @override
  String get visaCategory => 'Categoría de Visa';

  @override
  String get selectCategory => 'Selecciona categoría';

  @override
  String get additionalOptions => 'Opciones Adicionales';

  @override
  String get crossingByLand => 'Cruce Terrestre';

  @override
  String get crossingByLandSubtitle => 'Agrega tarifa I-94 (\$24)';

  @override
  String get calculateTotalCost => 'Calcular Costo Total';

  @override
  String get feeSchedule => 'Tabla de Tarifas 2026';

  @override
  String get checkYourEligibility => 'Verifica tu Elegibilidad';

  @override
  String get checkYourEligibilitySubtitle =>
      'Revisa si hay restricciones para tu nacionalidad';

  @override
  String get checkRestrictions => 'Verificar Restricciones';

  @override
  String get currentRestrictions => 'Restricciones Actuales (2026)';

  @override
  String get totalBan => 'Prohibición Total';

  @override
  String get partial => 'Parcial';

  @override
  String get paused => 'Pausado';

  @override
  String get selectVisaType => 'Seleccionar Tipo de Visa';

  @override
  String get nonImmigrant => 'No Inmigrante';

  @override
  String get immigrant => 'Inmigrante';

  @override
  String get mrvFee => 'Tarifa MRV';

  @override
  String get fiance => 'Prometido/a';

  @override
  String get petition => 'Petición';

  @override
  String get sevis => 'SEVIS';

  @override
  String get kVisa => 'Visa K';

  @override
  String get documentChecklist => 'Lista de Documentos';

  @override
  String get prerequisitesVerified =>
      'Todos los documentos requeridos verificados';

  @override
  String get missingDocuments => 'Faltan documentos requeridos';

  @override
  String get progress => 'Progreso';

  @override
  String get required => 'requeridos';

  @override
  String get noPrerequisities => 'Sin Prerrequisitos';

  @override
  String get noPrerequisitiesDesc =>
      'Esta categoría no requiere documentos previos. Puede continuar directamente a la solicitud.';

  @override
  String get continueToApp => 'Continuar a Solicitud';

  @override
  String get proceedingToApp => 'Prerrequisitos verificados. Continuando...';

  @override
  String get visaB1 => 'Visitante de Negocios';

  @override
  String get visaB2 => 'Turista';

  @override
  String get visaF2 => 'Dependiente de Estudiante';

  @override
  String get visaM1 => 'Estudiante Vocacional';

  @override
  String get visaJ1 => 'Visitante de Intercambio';

  @override
  String get visaH1B => 'Ocupación Especializada';

  @override
  String get visaL1 => 'Transferencia Ejecutiva';

  @override
  String get visaO1 => 'Habilidad Extraordinaria';

  @override
  String get visaK1 => 'Prometido/a';

  @override
  String get visaE1 => 'Comerciante por Tratado';

  @override
  String get visaE2 => 'Inversionista por Tratado';

  @override
  String get optional => 'Opcional';

  @override
  String get doYouHaveDocument => '¿Tienes este documento?';

  @override
  String get yesHaveIt => 'Sí, lo tengo';

  @override
  String get noNotYet => 'No, aún no';

  @override
  String get enterDocDetails => 'Ingresa Detalles del Documento';

  @override
  String get saveDocInfo => 'Guardar Información';

  @override
  String get docInfoSaved => 'Información guardada';

  @override
  String get issuedBy => 'Emitido por';

  @override
  String get issuedBySchool => 'Tu Escuela/Universidad';

  @override
  String get issuedByUSCIS => 'USCIS';

  @override
  String get issuedBySponsor => 'Organización Patrocinadora';

  @override
  String get issuedByPetitioner => 'Tu Peticionario (Patrocinador)';

  @override
  String get issuedByStateDept => 'Departamento de Estado de EE.UU.';

  @override
  String get invalidFormat => 'Formato inválido';

  @override
  String get visaB1Name => 'Visitante de Negocios';

  @override
  String get visaB1Desc =>
      'Actividades comerciales temporales, reuniones, conferencias';

  @override
  String get visaB1B2Name => 'Turismo/Negocios';

  @override
  String get visaB1B2Desc => 'Para propósitos temporales de negocios o turismo';

  @override
  String get visaB2Name => 'Turista';

  @override
  String get visaB2Desc =>
      'Turismo, vacaciones, tratamiento médico, visitar familia';

  @override
  String get visaCR1Name => 'Residente Condicional - Cónyuge';

  @override
  String get visaCR1Desc => 'Cónyuge casado menos de 2 años';

  @override
  String get visaCR2Name => 'Residente Condicional - Hijo';

  @override
  String get visaCR2Desc => 'Hijo de CR1';

  @override
  String get visaDVName => 'Visa de Diversidad';

  @override
  String get visaDVDesc => 'Ganadores de la lotería de visas de diversidad';

  @override
  String get visaE1Name => 'Comerciante por Tratado';

  @override
  String get visaE1Desc => 'Comerciantes en comercio sustancial';

  @override
  String get visaE1E2Name => 'Comerciante/Inversionista por Tratado';

  @override
  String get visaE1E2Desc => 'Para inversionistas de países con tratado';

  @override
  String get visaE2Name => 'Inversionista por Tratado';

  @override
  String get visaE2Desc => 'Inversionistas con inversión sustancial';

  @override
  String get visaEB1Name => 'Empleo Primera Preferencia';

  @override
  String get visaEB1Desc =>
      'Trabajadores prioritarios, habilidad extraordinaria';

  @override
  String get visaEB2Name => 'Empleo Segunda Preferencia';

  @override
  String get visaEB2Desc => 'Profesionales con títulos avanzados';

  @override
  String get visaEB3Name => 'Empleo Tercera Preferencia';

  @override
  String get visaEB3Desc => 'Trabajadores calificados, profesionales';

  @override
  String get visaEB4Name => 'Empleo Cuarta Preferencia';

  @override
  String get visaEB4Desc => 'Inmigrantes especiales, trabajadores religiosos';

  @override
  String get visaEB5Name => 'Empleo Quinta Preferencia';

  @override
  String get visaEB5Desc => 'Inversionistas inmigrantes';

  @override
  String get visaF1Name => 'Estudiante Académico';

  @override
  String get visaF1Desc =>
      'Estudios académicos de tiempo completo en institución acreditada';

  @override
  String get visaF1IMMName => 'Primera Preferencia Familiar';

  @override
  String get visaF1IMMDesc =>
      'Hijos adultos solteros de ciudadanos estadounidenses';

  @override
  String get visaH1BName => 'Ocupación Especializada';

  @override
  String get visaH1BDesc =>
      'Trabajadores profesionales que requieren conocimiento especializado';

  @override
  String get visaH2AName => 'Trabajador Agrícola';

  @override
  String get visaH2ADesc => 'Trabajadores agrícolas temporales';

  @override
  String get visaH2BName => 'Trabajador Temporal';

  @override
  String get visaH2BDesc => 'Trabajadores temporales no agrícolas';

  @override
  String get visaIR1Name => 'Familiar Inmediato - Cónyuge';

  @override
  String get visaIR1Desc => 'Cónyuge de ciudadano estadounidense';

  @override
  String get visaIR2Name => 'Familiar Inmediato - Hijo';

  @override
  String get visaIR2Desc =>
      'Hijo soltero menor de 21 años de ciudadano estadounidense';

  @override
  String get visaIR5Name => 'Familiar Inmediato - Padre';

  @override
  String get visaIR5Desc =>
      'Padre de ciudadano estadounidense mayor de 21 años';

  @override
  String get visaJ1Name => 'Visitante de Intercambio';

  @override
  String get visaJ1Desc =>
      'Programas de intercambio: au pair, pasante, profesor, trabajo y viaje';

  @override
  String get visaK1Name => 'Prometido/a';

  @override
  String get visaK1Desc =>
      'Prometido/a de ciudadano estadounidense, debe casarse en 90 días';

  @override
  String get visaK2Name => 'Hijo de K-1';

  @override
  String get visaK2Desc => 'Hijo soltero del solicitante K-1';

  @override
  String get visaL1Name => 'Transferencia Ejecutiva';

  @override
  String get visaL1Desc =>
      'Gerentes y ejecutivos transferidos dentro de la empresa';

  @override
  String get visaM1Name => 'Estudiante Vocacional';

  @override
  String get visaM1Desc => 'Programas de formación vocacional o técnica';

  @override
  String get visaO1Name => 'Habilidad Extraordinaria';

  @override
  String get visaO1Desc =>
      'Individuos con habilidad extraordinaria en ciencias, artes, etc.';

  @override
  String get visaP1Name => 'Atleta/Artista';

  @override
  String get visaP1Desc => 'Atletas o artistas reconocidos internacionalmente';

  @override
  String get visaQ1Name => 'Intercambio Cultural';

  @override
  String get visaQ1Desc => 'Programas de intercambio cultural internacional';

  @override
  String get visaR1Name => 'Trabajador Religioso';

  @override
  String get visaR1Desc => 'Trabajadores religiosos en capacidad religiosa';

  @override
  String get visaTNName => 'Profesional NAFTA';

  @override
  String get visaTNDesc => 'Profesionales canadienses/mexicanos bajo T-MEC';

  @override
  String get visaF2AName => 'Segunda Preferencia 2A';

  @override
  String get visaF2ADesc => 'Cónyuge e hijos menores de residente permanente';

  @override
  String get visaF2BName => 'Segunda Preferencia 2B';

  @override
  String get visaF2BDesc => 'Hijos adultos solteros de residente permanente';

  @override
  String get visaF3Name => 'Tercera Preferencia Familiar';

  @override
  String get visaF3Desc =>
      'Hijos adultos casados de ciudadanos estadounidenses';

  @override
  String get visaF4Name => 'Cuarta Preferencia Familiar';

  @override
  String get visaF4Desc => 'Hermanos de ciudadanos estadounidenses adultos';

  @override
  String get runAudit => 'Ejecutar Auditoría';

  @override
  String get edit => 'Editar';

  @override
  String get addProfile => 'Agregar Perfil';

  @override
  String get selectPlatform => 'Por favor selecciona una plataforma';

  @override
  String get learnMore => 'Más Información';

  @override
  String errorGeneric(Object error) {
    return 'Error: $error';
  }

  @override
  String get biometrics => 'Biometría';

  @override
  String get biometricsEnabled => 'Biometría activada';

  @override
  String get biometricsDisabled => 'Biometría desactivada';

  @override
  String get enabled => 'Activado';

  @override
  String get disabled => 'Desactivado';

  @override
  String get noFormData => 'Sin datos de formulario';

  @override
  String get noDocuments => 'Sin documentos';

  @override
  String get scannedPassport => 'Pasaporte Escaneado';

  @override
  String get noPracticeSessions => 'Sin sesiones de práctica';

  @override
  String get startSimulation => 'Iniciar Simulación';

  @override
  String get currentScore => 'Puntaje Actual';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String recoveryLinkWillBeSent(Object email) {
    return 'Se enviará un enlace de recuperación a:\n$email';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String linkSentTo(Object email) {
    return 'Enlace enviado a $email';
  }

  @override
  String get send => 'Enviar';

  @override
  String get languageChangeRequiresRestart =>
      'Cambio de idioma requiere reinicio';

  @override
  String get openingTerms => 'Abriendo términos...';

  @override
  String get openingPrivacy => 'Abriendo política...';

  @override
  String get emailCopied => 'Email copiado';

  @override
  String get loading => 'Cargando...';

  @override
  String get formDS2019Name => 'Certificado de Elegibilidad';

  @override
  String get formDS2019Help =>
      'Emitido por el patrocinador de tu programa (ej. agencia Au Pair).';

  @override
  String get formI129SName => 'Petición L en Bloque';

  @override
  String get formI129SHelp => 'Requerido para aplicaciones L en bloque.';

  @override
  String get formI20Name => 'Certificado de Elegibilidad';

  @override
  String get formI20HelpAcademic =>
      'Emitido por tu escuela después de la aceptación.';

  @override
  String get formI20HelpVocational =>
      'Emitido por tu escuela vocacional después de la aceptación.';

  @override
  String get formI797Name => 'Notificación de Acción (Aprobación)';

  @override
  String get formI797Help => 'Aviso de aprobación de USCIS (I-797A o I-797B).';

  @override
  String get issuedByProgramSponsor => 'Patrocinador del Programa';

  @override
  String get issuedByEmployer => 'Empleador';

  @override
  String get issuedByDHSSEVPSchool => 'Escuela DHS/SEVP';

  @override
  String get planDiyTitle => 'Revisión de Estrategia de Visa (DIY)';

  @override
  String get planDiyDesc =>
      'Análisis completo e informe VisaScore™. Ideal para autodidactas.';

  @override
  String get planFullTitle => 'Servicio Completo de Visa US';

  @override
  String get planFullDesc =>
      'Gestión completa de la aplicación y revisión prioritaria.';

  @override
  String get planSimulatorTitle => 'Simulador de Entrevista IA';

  @override
  String get planSimulatorDesc =>
      '30 días de práctica ilimitada con nuestro Oficial IA.';

  @override
  String get featureAIRiskAssessment => 'Evaluación de Riesgo IA';

  @override
  String get featureVisaScoreReport => 'Informe VisaScore™';

  @override
  String get featureDocumentChecklist => 'Lista de Documentos';

  @override
  String get featureEmailSupport => 'Soporte por Email';

  @override
  String get featureEverythingInDIY => 'Todo lo del plan DIY';

  @override
  String get featureDS160AutoFill => 'Auto-llenado DS-160';

  @override
  String get featureInterviewPrepGuide => 'Guía de Preparación para Entrevista';

  @override
  String get featurePrioritySupport => 'Soporte Prioritario';

  @override
  String get featureMoneyBackGuarantee => 'Garantía de Devolución';

  @override
  String get featureUnlimitedPracticeSessions =>
      'Sesiones de Práctica Ilimitadas';

  @override
  String get featureRealConsulScenarios => 'Escenarios Consulares Reales';

  @override
  String get featurePerformanceAnalytics => 'Análisis de Desempeño';

  @override
  String get featureWeaknessAnalysis => 'Análisis de Debilidades';

  @override
  String get restrictionTotalBan => 'Prohibición Total';

  @override
  String get restrictionPartialBan => 'Restricción Parcial';

  @override
  String get restrictionEnhancedVetting => 'Verificación Reforzada';

  @override
  String get restrictionCompleteEntryProhibition =>
      'Prohibición completa de entrada';

  @override
  String get splashDisclaimer =>
      'Proveedor de servicios privado - No gubernamental';

  @override
  String get profileIncomplete =>
      'Perfil incompleto. Por favor escanea tu pasaporte primero.';

  @override
  String get digitalFile => 'Expediente Digital';

  @override
  String get ds160Responses => 'Respuestas DS-160';

  @override
  String fieldsCount(int count) {
    return '$count campos';
  }

  @override
  String get noData => 'Sin datos';

  @override
  String get myDocuments => 'Mis Documentos';

  @override
  String documentCount(int count) {
    return '$count Documento';
  }

  @override
  String get simulatorHistory => 'Historial de Simulaciones';

  @override
  String sessionsCount(int count) {
    return '$count sesiones';
  }

  @override
  String get noSessions => 'Sin sesiones';

  @override
  String get accountSection => 'Cuenta';

  @override
  String get basicInfo => 'Información Básica';

  @override
  String get securitySection => 'Seguridad';

  @override
  String get updateAccess => 'Actualizar acceso';

  @override
  String get biometricsLabel => 'Biometría';

  @override
  String get activated => 'Activado';

  @override
  String get deactivated => 'Desactivado';

  @override
  String get legal => 'Legal';

  @override
  String get termsAndPrivacy => 'Términos y privacidad';

  @override
  String get verified => 'VERIFICADO';

  @override
  String get passport => 'PASAPORTE';

  @override
  String get nationality => 'NACIONALIDAD';

  @override
  String get birthDate => 'NACIMIENTO';

  @override
  String get ds160Data => 'Datos DS-160';

  @override
  String sessionNumber(int number) {
    return 'Sesión $number';
  }

  @override
  String get accountInfo => 'Información de Cuenta';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Teléfono';

  @override
  String get notRegistered => 'No registrado';

  @override
  String get role => 'Rol';

  @override
  String passwordResetSent(String email) {
    return 'Enlace enviado a $email';
  }

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String passwordResetDialogContent(String email) {
    return 'Se enviará un enlace de recuperación a:\n$email';
  }

  @override
  String get legalDocuments => 'Documentos Legales';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get viewDocument => 'Ver documento';

  @override
  String get spanishLanguage => '🇪🇸  Español';

  @override
  String get englishLanguage => '🇺🇸  English';
}
