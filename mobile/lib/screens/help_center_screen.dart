import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ❓ CENTRO DE AYUDA - FAQ Screen
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Contains hero section and 20 frequently asked questions about US visa
/// applications, written in simple, understandable language for everyone.
/// 
/// Created: 2026-01-31
/// ═══════════════════════════════════════════════════════════════════════════

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expandedIndex;

  // 20 FAQs in simple, understandable language
  static const List<Map<String, String>> _faqs = [
    // === SOBRE LA APP ===
    {
      'question': '¿Qué es esta aplicación y cómo me ayuda?',
      'answer': 'Esta aplicación es tu asistente personal para preparar tu solicitud de visa estadounidense. Te guía paso a paso para llenar formularios, practicar para la entrevista en el consulado, y tener todo listo antes de tu cita. Es como tener un experto en visas en tu bolsillo.',
    },
    {
      'question': '¿Tengo que pagar para usar la app?',
      'answer': 'Puedes comenzar gratis y explorar los servicios básicos. Para acceder al simulador de entrevista con inteligencia artificial y otras herramientas premium, ofrecemos planes mensuales o anuales. El plan anual te ahorra dinero a largo plazo.',
    },
    {
      'question': '¿Mis datos están seguros aquí?',
      'answer': 'Absolutamente. Usamos la misma tecnología de seguridad que usan los bancos. Tus datos personales están encriptados y nunca los compartimos con terceros. Solo tú puedes ver tu información.',
    },
    
    // === SOBRE EL FORMULARIO DS-160 ===
    {
      'question': '¿Qué es el formulario DS-160?',
      'answer': 'Es el formulario oficial que debes llenar en línea antes de solicitar una visa de no inmigrante (como turista, estudiante o trabajo). Contiene preguntas sobre tu identidad, historial de viajes, empleo y propósito del viaje. Sin este formulario completo, no puedes agendar tu cita en la embajada.',
    },
    {
      'question': '¿Cuánto tiempo toma llenar el DS-160?',
      'answer': 'Normalmente toma entre 1 y 2 horas si tienes toda tu información lista. Con nuestra app, el proceso es más rápido porque te guiamos pregunta por pregunta y guardamos tu progreso automáticamente. Puedes pausar y continuar cuando quieras.',
    },
    {
      'question': '¿Qué documentos necesito para llenar el DS-160?',
      'answer': 'Necesitas: tu pasaporte vigente, fechas de viajes anteriores a EE.UU. (si aplica), información de tu empleo actual, dirección donde te hospedarás en EE.UU., y datos de un contacto en Estados Unidos. Ten todo a la mano antes de empezar.',
    },
    {
      'question': '¿Qué pasa si me equivoco en el DS-160?',
      'answer': 'No te preocupes. Antes de enviar el formulario, puedes revisar y corregir cualquier error. Nuestra app te alerta si detecta información incompleta o inconsistente. Una vez enviado, ya no se puede modificar, pero puedes empezar uno nuevo si es necesario.',
    },
    
    // === SOBRE LA ENTREVISTA ===
    {
      'question': '¿Es obligatoria la entrevista en el consulado?',
      'answer': 'En la mayoría de los casos, sí. La entrevista es donde el oficial consular decide si aprueba tu visa. Hay excepciones para renovaciones o ciertos solicitantes, pero la primera vez casi siempre requiere entrevista presencial.',
    },
    {
      'question': '¿Qué preguntas me harán en la entrevista?',
      'answer': 'Las preguntas más comunes son: ¿Por qué quiere viajar a Estados Unidos? ¿Dónde trabaja? ¿Tiene familia aquí? ¿Cuánto tiempo planea quedarse? El oficial quiere asegurarse de que regresarás a tu país. Nuestro simulador te ayuda a practicar estas preguntas.',
    },
    {
      'question': '¿Cómo me ayuda el simulador de entrevista?',
      'answer': 'Es como practicar con un entrevistador real. La inteligencia artificial te hace preguntas típicas del consulado, escucha tus respuestas y te da consejos para mejorar. Entre más practiques, más confianza tendrás el día de tu cita real.',
    },
    {
      'question': '¿Qué debo llevar el día de la entrevista?',
      'answer': 'Lleva tu pasaporte, la confirmación del DS-160 (página con código de barras), foto reciente, comprobante de pago de la visa, carta de tu empleador, estados de cuenta bancarios, y cualquier documento que demuestre que regresarás (propiedades, familia, trabajo estable).',
    },
    {
      'question': '¿Cuánto dura la entrevista?',
      'answer': 'La entrevista en sí es muy corta: entre 2 y 5 minutos. Pero la espera en el consulado puede ser de varias horas. El oficial hace pocas preguntas clave y decide rápidamente. Por eso es importante que tus respuestas sean claras y directas.',
    },
    
    // === SOBRE TIPOS DE VISA ===
    {
      'question': '¿Qué tipo de visa necesito para ir de vacaciones?',
      'answer': 'Necesitas una visa B1/B2, que es la visa de turista y negocios. Te permite visitar Estados Unidos por placer, visitar familia, recibir tratamiento médico o asistir a reuniones de negocios. Es la visa más común y puede durar hasta 10 años.',
    },
    {
      'question': '¿Cuál es la diferencia entre visa de inmigrante y no inmigrante?',
      'answer': 'La visa de no inmigrante (como turista o estudiante) es temporal: visitas y regresas a tu país. La visa de inmigrante es para quedarte permanentemente en EE.UU. y obtener la residencia (Green Card). Esta app se enfoca en visas de no inmigrante.',
    },
    {
      'question': '¿Cuánto cuesta la visa de turista?',
      'answer': 'El costo del trámite (MRV fee) para la visa B1/B2 es de $185 dólares. Este pago no es reembolsable, incluso si te niegan la visa. Se paga antes de agendar la cita y es válido por un año.',
    },
    
    // === PROBLEMAS COMUNES ===
    {
      'question': '¿Qué significa "214(b)" si me niegan la visa?',
      'answer': 'Es la razón más común de rechazo. Significa que el oficial no quedó convencido de que regresarás a tu país después del viaje. No es un castigo: puedes volver a aplicar demostrando más lazos con tu país (trabajo, propiedades, familia).',
    },
    {
      'question': '¿Puedo volver a aplicar si me negaron la visa?',
      'answer': 'Sí, puedes aplicar de nuevo inmediatamente. No hay tiempo de espera obligatorio. Pero es importante que algo haya cambiado en tu situación (mejor empleo, más ahorro, documentos adicionales) para que el resultado sea diferente.',
    },
    {
      'question': '¿Cómo demuestro que voy a regresar a mi país?',
      'answer': 'Muestra pruebas de arraigo: un trabajo estable, carta de tu empleador, propiedades a tu nombre, cuenta bancaria con ahorros, familia que depende de ti, o un negocio propio. Entre más fuerte sea tu conexión con tu país, más fácil es obtener la visa.',
    },
    
    // === SOBRE LA APP (TÉCNICO) ===
    {
      'question': '¿Puedo usar la app sin internet?',
      'answer': 'Necesitas conexión a internet para usar el simulador de entrevista y sincronizar tus datos. Sin embargo, puedes revisar información guardada previamente sin conexión. Recomendamos tener WiFi cuando uses las funciones principales.',
    },
    {
      'question': '¿Cómo contacto a soporte si tengo problemas?',
      'answer': 'Puedes escribirnos desde la sección de Perfil > Ayuda > Contactar Soporte. Respondemos en menos de 24 horas. También puedes enviarnos un email a soporte@usavpc.com con tu consulta y te ayudaremos lo antes posible.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
        title: const Text('Centro de Ayuda'),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(
            child: _buildHeroSection(),
          ),
          
          // FAQ Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Preguntas Frecuentes',
                style: AppTheme.h2NavyBold,
              ),
            ),
          ),
          
          // FAQ List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildFaqItem(index),
                childCount: _faqs.length,
              ),
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.navyPrimary,
            AppTheme.navyPrimary.withBlue(120),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                '¿Cómo podemos ayudarte?',
                style: AppTheme.h1NavyBold.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Encuentra respuestas a las preguntas más comunes sobre visas, formularios y entrevistas.',
                style: AppTheme.bodyWhiteBold.copyWith(
                  fontWeight: FontWeight.normal,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Contact button
              OutlinedButton.icon(
                onPressed: () {
                  // Could navigate to contact screen or open email
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Escríbenos a soporte@usavpc.com'),
                      backgroundColor: AppTheme.actionBlue,
                    ),
                  );
                },
                icon: const Icon(Icons.email_outlined, size: 18),
                label: const Text('Contactar Soporte'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(int index) {
    final faq = _faqs[index];
    final isExpanded = _expandedIndex == index;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? AppTheme.actionBlue : AppTheme.cardBorderColor,
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: AppTheme.actionBlue.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isExpanded 
                              ? AppTheme.actionBlue 
                              : AppTheme.dividerGreyLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTheme.labelBold.copyWith(
                              color: isExpanded 
                                  ? Colors.white 
                                  : AppTheme.inkSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Question text
                      Expanded(
                        child: Text(
                          faq['question']!,
                          style: AppTheme.labelBold.copyWith(
                            color: AppTheme.inkPrimary,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Expand icon
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded 
                              ? AppTheme.actionBlue 
                              : AppTheme.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Answer (animated)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 40),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.softBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          faq['answer']!,
                          style: AppTheme.captionGreyRegular.copyWith(
                            color: AppTheme.inkPrimary,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded 
                        ? CrossFadeState.showSecond 
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
