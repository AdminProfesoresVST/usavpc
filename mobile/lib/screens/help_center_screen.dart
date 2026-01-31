import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'help_center_screen.g.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ❓ CENTRO DE AYUDA - FAQ Screen
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// Contains hero section and FAQs fetched from database.
/// Follows Real Data Architect skill: No hardcoded data in UI.
/// 
/// Created: 2026-01-31
/// Modified: 2026-01-31 - Refactored to fetch FAQs from Supabase
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// DOMAIN: FAQ Entity
// ═══════════════════════════════════════════════════════════════════════════
class Faq {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int displayOrder;
  
  Faq({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.displayOrder,
  }) : assert(question.isNotEmpty, 'FAQ question cannot be empty'),
       assert(answer.isNotEmpty, 'FAQ answer cannot be empty');
  
  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      category: json['category'] as String? ?? 'general',
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATA LAYER: Provider connected to Supabase
// ═══════════════════════════════════════════════════════════════════════════
@riverpod
Future<List<Faq>> faqs(Ref ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('faqs')
      .select()
      .eq('is_active', true)
      .order('display_order', ascending: true);
  
  return (response as List)
      .map((json) => Faq.fromJson(json as Map<String, dynamic>))
      .toList();
}

// ═══════════════════════════════════════════════════════════════════════════
// PRESENTATION LAYER: HelpCenterScreen
// ═══════════════════════════════════════════════════════════════════════════
class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    // REAL DATA ARCHITECT: Consume FAQs from provider connected to DB
    final faqsAsync = ref.watch(faqsProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.navyPrimary,
        foregroundColor: AppTheme.inkInverse,
        title: const Text('Centro de Ayuda'),
        elevation: 0,
      ),
      body: faqsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.navyPrimary),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar las preguntas',
                style: AppTheme.labelBold.copyWith(color: AppTheme.inkPrimary),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(faqsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (faqs) => CustomScrollView(
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
                  (context, index) => _buildFaqItem(faqs[index], index),
                  childCount: faqs.length,
                ),
              ),
            ),
            
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
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

  Widget _buildFaqItem(Faq faq, int index) {
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
                          faq.question,
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
                          faq.answer,
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
