import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// 🎨 APP THEME "BIBLE" - CONTROL CENTRAL DE DISEÑO
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Este archivo controla TODO el diseño visual de la aplicación.
/// Para cambiar cualquier aspecto visual, modifique los valores aquí.
/// 
/// 📚 ÍNDICE:
///   1. COLORES DEL SISTEMA (Paleta de colores)
///   2. COLORES SEMÁNTICOS (Success, Warning, Error, Info)
///   3. DIMENSIONES Y FORMAS (Bordes redondeados, espaciados)
///   4. TIPOGRAFÍA (Estilos de texto)
///   5. ESTILOS DE COMPONENTES (Tarjetas, Inputs, Botones)
///   6. TEMA DE FLUTTER (ThemeData)
/// 
/// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. 🎨 COLORES DEL SISTEMA (Paleta Principal)
  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Cambie estos colores para modificar toda la paleta de la app.
  
  /// Color Principal Navy - Usado en: AppBar, Botones, Títulos
  static const navyPrimary = Color(0xFF112E51);
  
  /// Color de Acción Blue - Usado en: Links, Focus, Iconos activos
  static const actionBlue = Color(0xFF2B5C8A);
  
  /// Color Suave Blue - Usado en: Fondos de alertas info, Hover states
  static const softBlue = Color(0xFFEBF5FB);
  
  /// Color de Superficie (Tarjetas) - Blanco puro
  static const surfaceWhite = Color(0xFFFFFFFF);
  
  /// Color de Fondo de Pantallas - Gris muy claro
  static const backgroundGrey = Color(0xFFF0F2F5);
  
  /// Color de Líneas Divisorias
  static const dividerGrey = Color(0xFFCFD8DC);
  
  /// Texto Principal (Títulos) - Casi negro
  static const inkPrimary = Color(0xFF102035);
  
  /// Texto Secundario (Subtítulos) - Gris medio
  static const inkSecondary = Color(0xFF546E7A);
  
  /// Texto Inverso (Sobre fondos oscuros) - Blanco
  static const inkInverse = Color(0xFFFFFFFF);
  
  /// Blanco con opacidad 70% (para subtítulos sobre fondos oscuros)
  static const inkInverse70 = Color(0xB3FFFFFF);
  
  /// Blanco con opacidad 24% (para bordes sutiles sobre fondos oscuros)
  static const inkInverse24 = Color(0x3DFFFFFF);
  
  /// Borde de Tarjetas - Gris muy sutil
  static const cardBorderColor = Color(0xFFEEEEEE);
  
  /// Gris muy claro para fondos de inputs
  static const dividerGreyLight = Color(0xFFFAFAFA);
  
  /// Negro con opacidad 12% (para bordes muy sutiles)
  static const inkPrimary12 = Color(0x1F000000);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 2. 🚦 COLORES SEMÁNTICOS (Estados y Alertas)
  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Use estos colores para indicar estados en la UI.
  
  /// ✅ Color de Éxito (Verde)
  static const successGreen = Color(0xFF2E7D32);
  static const successGreenLight = Color(0xFFE8F5E9);
  
  /// ⚠️ Color de Advertencia (Naranja/Ámbar)
  static const warningOrange = Color(0xFFE65100);
  static const warningOrangeLight = Color(0xFFFFF3E0);
  
  /// ❌ Color de Error (Rojo)
  static const errorRed = Color(0xFFC62828);
  static const errorRedLight = Color(0xFFFFEBEE);
  
  /// ℹ️ Color Informativo (Azul)
  static const infoBlue = Color(0xFF1565C0);
  static const infoBlueLight = Color(0xFFE3F2FD);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 3. 📏 REDONDEO DE ESQUINAS (¿Qué tan redondeados son los elementos?)
  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Estos valores controlan las esquinas redondeadas de cada tipo de elemento.
  // 📍 Un valor más alto = más redondeado. Un valor de 0 = esquinas cuadradas.
  
  /// 🃏 TARJETAS (Cards de servicios, dashboard, etc.)
  /// Valor actual: 16px - Cambie para más/menos redondez en tarjetas.
  static const double radiusTarjetas = 8.0;
  static BorderRadius get cardRadius => BorderRadius.circular(radiusTarjetas);
  
  /// 🔘 BOTONES (Botón "Continuar", "Calcular", etc.)
  /// Valor actual: 8px - Cambie para más/menos redondez en botones.
  static const double radiusBotones = 8.0;
  static BorderRadius get buttonRadius => BorderRadius.circular(radiusBotones);
  
  /// 📝 CAMPOS DE TEXTO (Inputs, Dropdowns, Search)
  /// Valor actual: 12px - Cambie para más/menos redondez en campos de entrada.
  static const double radiusCamposTexto = 8.0;
  static BorderRadius get inputRadius => BorderRadius.circular(radiusCamposTexto);
  
  /// 💊 ETIQUETAS/PILLS (Badges como "$185 MRV", "SEVIS", "Visa K")
  /// Valor actual: 8px - Muy redondeado, casi ovalado.
  static const double radiusEtiquetas = 20.0;
  static BorderRadius get badgeRadius => BorderRadius.circular(radiusEtiquetas);
  
  /// 🔳 DETALLES PEQUEÑOS (Iconos circulares, chips, indicadores)
  /// Valor actual: 4px - Ligeramente redondeado.
  static const double radiusDetalles = 4.0;
  static BorderRadius get smallRadius => BorderRadius.circular(radiusDetalles);
  
  // Aliases para compatibilidad (NO EDITAR, son los mismos valores)
  static double get cardRadiusValue => radiusTarjetas;
  static double get buttonRadiusValue => radiusBotones;
  static double get inputRadiusValue => radiusCamposTexto;
  static double get badgeRadiusValue => radiusEtiquetas;
  static double get smallRadiusValue => radiusDetalles;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 4. 📐 ESPACIADOS (Márgenes y Padding)
  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Estos valores controlan la separación entre elementos.
  
  /// 📱 MARGEN DE PANTALLA (Espacio entre el borde de la pantalla y el contenido)
  /// Usado en: Padding de todas las pantallas (Scaffold body).
  static const double marginPantalla = 16.0;
  
  /// 🃏 ESPACIO ENTRE TARJETAS (Separación vertical entre cards)
  /// Usado en: Listas de tarjetas, dashboard, servicios.
  static const double espacioEntreTarjetas = 12.0;
  
  /// 📦 PADDING INTERNO DE TARJETAS (Espacio dentro de las tarjetas)
  /// Usado en: Contenido interno de todas las tarjetas.
  static const double paddingTarjetas = 16.0;
  
  /// 🔤 ESPACIO ENTRE LÍNEAS DE TEXTO (Separación entre título y subtítulo)
  /// Usado en: Espacio entre título y descripción en cards.
  static const double espacioTextos = 8.0;
  
  /// 📏 ESPACIO ENTRE SECCIONES (Separación entre grupos de elementos)
  /// Usado en: Espacio entre secciones en formularios, pantallas largas.
  static const double espacioSecciones = 20.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 5. 🔣 TAMAÑO DE ICONOS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Íconos en listas de servicios, tarjetas pequeñas
  static const double iconoEnTarjeta = 20.0;
  
  /// Íconos en botones de navegación inferior
  static const double iconoNavegacion = 24.0;
  
  /// Íconos grandes (pantallas de bienvenida, estados vacíos)
  static const double iconoGrande = 48.0;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 6. 📏 ALTURAS DE COMPONENTES
  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Estos valores controlan la altura de botones, inputs y dropdowns.
  
  /// Altura estándar de botones grandes (CTAs principales como "Continuar")
  static const double alturaBotonGrande = 35.0;
  
  /// Altura estándar de botones medianos (secundarios)
  static const double alturaBotonMedio = 35.0;
  
  /// Altura estándar de botones pequeños (inline, chips)
  static const double alturaBotonPequeno = 2.0;
  
  /// Altura estándar de TextFormField y DropdownButtonFormField
  static const double alturaInput = 35.0;
  
  /// Altura de items en listas (ListTile, Cards de lista)
  static const double alturaListItem = 35.0;
  
  /// Padding interno vertical de inputs (afecta altura visual)
  static const double paddingVerticalInput = 6.0;
  
  /// Padding interno horizontal de inputs
  static const double paddingHorizontalInput = 6.0;
  
  /// Padding interno de botones
  static const EdgeInsets paddingBoton = EdgeInsets.symmetric(
    horizontal: 6.0,
    vertical: 6.0,
  );
  
  // ═══════════════════════════════════════════════════════════════════════════
  // 4. ✍️ TIPOGRAFÍA (Estilos de Texto)
  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Ajuste aquí los tamaños de fuente de toda la aplicación.
  
  // --- TAMAÑOS BASE (En Pixeles) ---
  static const double _sizeH1 = 18.0;      // Títulos de Pantalla
  static const double _sizeH2 = 16.0;      // Subtítulos
  static const double _sizeBody = 14.0;    // Texto normal
  static const double _sizeLabel = 13.0;   // Etiquetas y Botones
  static const double _sizeCaption = 12.0; // Textos pequeños

  // --- H1: Títulos Grandes (18px) ---
  static TextStyle get h1NavyBold => GoogleFonts.roboto(
    fontSize: _sizeH1, 
    fontWeight: FontWeight.w700, 
    color: navyPrimary
  );
  static TextStyle get h1WhiteBold => GoogleFonts.roboto(
    fontSize: _sizeH1, 
    fontWeight: FontWeight.w700, 
    color: inkInverse
  );
  
  // --- H2: Subtítulos (16px) ---
  static TextStyle get h2NavyBold => GoogleFonts.roboto(
    fontSize: _sizeH2, 
    fontWeight: FontWeight.w600, 
    color: navyPrimary
  );
  static TextStyle get h2WhiteBold => GoogleFonts.roboto(
    fontSize: _sizeH2, 
    fontWeight: FontWeight.w600, 
    color: inkInverse
  );
  
  // --- BODY: Texto Normal (14px) ---
  static TextStyle get bodyPrimaryRegular => GoogleFonts.roboto(
    fontSize: _sizeBody, 
    fontWeight: FontWeight.w400, 
    color: inkPrimary
  );
  static TextStyle get bodyWhiteRegular => GoogleFonts.roboto(
    fontSize: _sizeBody, 
    fontWeight: FontWeight.w400, 
    color: inkInverse
  );
  static TextStyle get bodyWhiteBold => GoogleFonts.roboto(
    fontSize: _sizeBody, 
    fontWeight: FontWeight.w700, 
    color: inkInverse
  );
  
  // --- LABEL: Etiquetas y Botones (14px) ---
  static TextStyle get labelBold => GoogleFonts.roboto(
    fontSize: _sizeLabel, 
    fontWeight: FontWeight.w600, 
    color: navyPrimary
  );
  static TextStyle get labelRegular => GoogleFonts.roboto(
    fontSize: _sizeLabel, 
    fontWeight: FontWeight.w400, 
    color: inkSecondary
  );

  // --- CAPTION: Textos Pequeños (12px) ---
  static TextStyle get captionGreyRegular => GoogleFonts.roboto(
    fontSize: _sizeCaption, 
    fontWeight: FontWeight.w400, 
    color: inkSecondary
  );
  static TextStyle get captionGreyBold => GoogleFonts.roboto(
    fontSize: _sizeCaption, 
    fontWeight: FontWeight.w700, 
    color: inkSecondary
  );
  static TextStyle get captionNavyBold => GoogleFonts.roboto(
    fontSize: _sizeCaption, 
    fontWeight: FontWeight.w700, 
    color: navyPrimary
  );
  static TextStyle get captionNavyRegular => GoogleFonts.roboto(
    fontSize: _sizeCaption, 
    fontWeight: FontWeight.w400, 
    color: navyPrimary
  );
  static TextStyle get captionWhiteBold => GoogleFonts.roboto(
    fontSize: _sizeCaption, 
    fontWeight: FontWeight.w700, 
    color: inkInverse
  );
  static TextStyle get captionWhiteRegular => GoogleFonts.roboto(
    fontSize: _sizeCaption, 
    fontWeight: FontWeight.w400, 
    color: inkInverse
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. 🃏 ESTILOS DE COMPONENTES (Reutilizables)
  // ═══════════════════════════════════════════════════════════════════════════
  // 📍 Use estos estilos predefinidos en sus widgets.

  /// Estilo ESTÁNDAR para Tarjetas
  /// Incluye: Fondo blanco, Borde redondeado, Sombra suave, Borde gris.
  static BoxDecoration get standardCardDecoration => BoxDecoration(
    color: surfaceWhite,
    borderRadius: cardRadius,
    border: Border.all(color: cardBorderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  /// Estilo para Tarjeta con Header Navy
  static BoxDecoration get navyHeaderCardDecoration => BoxDecoration(
    color: navyPrimary,
    borderRadius: cardRadius,
    boxShadow: [
      BoxShadow(
        color: navyPrimary.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Estilo ESTÁNDAR para Inputs (Cajas de texto)
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceWhite,
      contentPadding: EdgeInsets.symmetric(
        horizontal: paddingHorizontalInput, 
        vertical: paddingVerticalInput,
      ),
      border: OutlineInputBorder(
        borderRadius: inputRadius, 
        borderSide: const BorderSide(color: dividerGrey)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius, 
        borderSide: const BorderSide(color: dividerGrey)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius, 
        borderSide: const BorderSide(color: actionBlue, width: 2)
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: inputRadius, 
        borderSide: const BorderSide(color: errorRed, width: 1)
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. 🛠️ FLUTTER THEME DATA (Configuración Global)
  // ═══════════════════════════════════════════════════════════════════════════
  // Esta sección conecta todo lo anterior con los widgets nativos de Flutter.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.roboto().fontFamily,
      
      // Esquema de Colores
      colorScheme: const ColorScheme.light(
        primary: navyPrimary,
        onPrimary: inkInverse,
        secondary: actionBlue,
        onSecondary: inkInverse,
        surface: surfaceWhite,
        onSurface: inkPrimary,
        error: navyPrimary, 
        onError: inkInverse,
        outline: dividerGrey,
      ),
      
      scaffoldBackgroundColor: backgroundGrey, // Fondo gris de la app
      
      // Tema de Texto Global
      textTheme: TextTheme(
        headlineLarge: h1NavyBold,
        headlineMedium: h2NavyBold,
        titleLarge: h1NavyBold,
        titleMedium: h2NavyBold,
        bodyLarge: bodyPrimaryRegular,
        bodyMedium: labelRegular,
        labelLarge: GoogleFonts.roboto( // Estilo del TEXTO DE BOTONES
          fontSize: _sizeLabel, 
          fontWeight: FontWeight.w700, 
          color: inkInverse
        ), 
      ),
      
      // Configuración de la Barra Superior (AppBar)
      appBarTheme: AppBarTheme(
        backgroundColor: navyPrimary,
        foregroundColor: inkInverse,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: h1WhiteBold,
        iconTheme: const IconThemeData(color: inkInverse, size: 20),
      ),
      
      // Configuración de Botones (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyPrimary, // Color de fondo del botón
          foregroundColor: inkInverse,  // Color del texto del botón
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadiusValue) // Radio del botón
          ),
          padding: paddingBoton,
          textStyle: GoogleFonts.roboto( // Tipografía del botón
            fontSize: 14, // Tamaño de texto ligeramente mayor para legibilidad
            fontWeight: FontWeight.w600
          ), 
        ),
      ),
      
      // Configuración Global de Inputs (TextFormField Defaults)
      // Esto aplica si no se usa AppTheme.inputDecoration explícitamente
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        isDense: false,
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingHorizontalInput, 
          vertical: paddingVerticalInput,
        ),
        labelStyle: labelRegular,
        floatingLabelStyle: const TextStyle(color: actionBlue, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: inputRadius, borderSide: const BorderSide(color: dividerGrey)),
        enabledBorder: OutlineInputBorder(borderRadius: inputRadius, borderSide: const BorderSide(color: dividerGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: inputRadius, borderSide: const BorderSide(color: actionBlue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: inputRadius, borderSide: const BorderSide(color: errorRed)),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return actionBlue;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}
