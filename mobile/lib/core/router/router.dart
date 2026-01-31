import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/dashboard_screen.dart';
import 'package:mobile/screens/main_scaffold.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:mobile/screens/register_screen.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/screens/service_selection_screen.dart';
import 'package:mobile/screens/visa_type_selection_screen.dart';
import 'package:mobile/screens/order_summary_screen.dart';

import 'package:mobile/screens/ds160_intake_screen.dart';
import 'package:mobile/screens/ds260_intake_screen.dart';
import 'package:mobile/screens/verification_landing_screen.dart';
import 'package:mobile/screens/verification_scanner_screen.dart';
import 'package:mobile/screens/passport_confirm_screen.dart';
import 'package:mobile/services/mrz_parser.dart';
import 'package:mobile/screens/simulator_intro_screen.dart';
import 'package:mobile/screens/ds160_interview_simulator_screen.dart';
import 'package:mobile/screens/quick_check_screen.dart';
import 'package:mobile/screens/risk_audit_screen.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/screens/visa_category_selector_screen.dart';
import 'package:mobile/screens/prerequisite_checker_screen.dart';
import 'package:mobile/screens/restriction_check_screen.dart';
import 'package:mobile/screens/cost_calculator_screen.dart';
import 'package:mobile/screens/help_topic_screen.dart';
import 'package:mobile/screens/premium_checkout_screen.dart';
import 'package:mobile/screens/admin_payment_config_screen.dart';
import 'package:mobile/screens/help_center_screen.dart';
import 'package:mobile/screens/consular_risk_dashboard_screen.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final location = state.uri.toString();
      
      // Public routes that don't require auth
      final publicRoutes = ['/splash', '/services', '/login', '/register'];
      if (publicRoutes.contains(location)) return null;

      // If not logged in and trying to access protected route
      if (!isLoggedIn) return '/login';
      
      // If logged in and on login/splash, rely on internal navigation or default
      if (isLoggedIn && location == '/login') return '/dashboard';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Immersive Flows (No Shell)
      GoRoute(
        path: '/kyc',
        redirect: (context, state) => '/kyc/chat', // Default to DS-160 Intake
      ),
      GoRoute(
        path: '/kyc/chat',
        builder: (context, state) => const Ds160IntakeScreen(),
      ),
      GoRoute(
        path: '/kyc/ds260',
        builder: (context, state) => const Ds260IntakeScreen(),
      ),
      GoRoute(
        path: '/kyc/confirm',
        builder: (context, state) {
           final p = state.uri.queryParameters;
           if (p['passport'] != null) {
             return PassportConfirmScreen(
               passportData: PassportModel(
                 documentNumber: p['passport']!,
                 firstName: p['firstName'] ?? '',
                 lastName: p['surname'] ?? '',
                 birthDate: p['dob'] ?? '',
                 nationality: p['nationality'] ?? '',
                 expiryDate: p['expiry'] ?? '',
                 sex: p['sex'] ?? '',
                 personalNumber: '',
               ),
             );
           }
           final type = state.uri.queryParameters['visa_type'] ?? 'b1b2'; 
           return const Ds160IntakeScreen();
        },
      ),
      GoRoute(
        path: '/identity/start',
        builder: (context, state) => const VerificationLandingScreen(),
      ),
      GoRoute(
        path: '/identity/capture',
        builder: (context, state) => const VerificationScannerScreen(),
      ),
      GoRoute(
        path: '/simulator',
        builder: (context, state) => const SimulatorIntroScreen(),
        routes: [
           GoRoute(
            path: 'chat',
            builder: (context, state) => const Ds160InterviewSimulatorScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/sim',
        redirect: (_, __) => '/simulator', 
      ),
       GoRoute(
        path: '/chat-intake',
         redirect: (context, state) => '/kyc/chat',
      ),
      // Admin Routes
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentConfigScreen(),
      ),
      // Consular Risk Command Dashboard
      GoRoute(
        path: '/risk-command',
        builder: (context, state) => const ConsularRiskDashboardScreen(),
      ),
      
      // UNIFIED SHELL
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainScaffold(navigationShell: navigationShell),
        branches: [
          // Branch 0: Dashboard (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Services (Public Catalog + Tools)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                redirect: (context, state) {
                   // User Request: Services tab -> Risk Command instead of simulator
                   final isLoggedIn = ref.read(authStateProvider).value != null;
                   // FIX: Only redirect if explicitly hitting the tab root, NOT subroutes
                   if (isLoggedIn && state.uri.toString() == '/services') {
                     return '/risk-command';
                   }
                   return null;
                },
                builder: (context, state) => const ServiceSelectionScreen(),
                routes: [
                  GoRoute(
                    path: 'visa/select',
                    builder: (context, state) => const VisaCategorySelectorScreen(),
                  ),
                  GoRoute(
                    path: 'visa/prerequisites',
                    builder: (context, state) {
                      final code = state.uri.queryParameters['code'] ?? 'B1/B2';
                      return PrerequisiteCheckerScreen(visaCategoryCode: code);
                    },
                  ),
                  GoRoute(
                    path: 'visa-type',
                    builder: (context, state) => const VisaTypeSelectionScreen(),
                  ),
                  GoRoute(
                    path: 'cost/calculate',
                    builder: (context, state) => const CostCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'travel-ban/check',
                    builder: (context, state) => const RestrictionCheckScreen(),
                  ),
                  GoRoute(
                    path: 'quick-check',
                    builder: (context, state) => const QuickCheckScreen(),
                  ),
                  GoRoute(
                    path: 'risk-audit',
                    builder: (context, state) => const RiskAuditScreen(),
                  ),
                  GoRoute(
                    path: 'payment',
                    builder: (context, state) {
                      final plan = state.uri.queryParameters['plan'] ?? 'monthly';
                      return PremiumCheckoutScreen(planId: plan);
                    },
                  ),
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) => const OrderSummaryScreen(),
                  ),
                   GoRoute(
                    path: 'help/:topic',
                    builder: (context, state) {
                      final topicStr = state.pathParameters['topic'] ?? 'scan';
                      final topic = HelpTopic.values.firstWhere(
                        (e) => e.name == topicStr,
                        orElse: () => HelpTopic.scan,
                      );
                      return HelpTopicScreen(topic: topic);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          // Branch 3: Help Center
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/help',
                builder: (context, state) => const HelpCenterScreen(),
              ),
            ],
          ),
        ],
      ),

      // LEGACY REDIRECTS (Maintain backward compatibility)
      GoRoute(
        path: '/profile_tab',
        redirect: (_, __) => '/profile',
      ),
      GoRoute(
        path: '/services_tab',
        redirect: (_, __) => '/services',
      ),
      GoRoute(
        path: '/visa/select',
        redirect: (context, state) => state.uri.replace(path: '/services/visa/select').toString(),
      ),
      GoRoute(
        path: '/visa/prerequisites',
        redirect: (context, state) => state.uri.replace(path: '/services/visa/prerequisites').toString(),
      ),
      GoRoute(
        path: '/cost/calculate',
        redirect: (context, state) => state.uri.replace(path: '/services/cost/calculate').toString(),
      ),
      GoRoute(
        path: '/travel-ban/check',
         redirect: (context, state) => state.uri.replace(path: '/services/travel-ban/check').toString(),
      ),
      GoRoute(
        path: '/quick-check',
         redirect: (context, state) => state.uri.replace(path: '/services/quick-check').toString(),
      ),
      GoRoute(
        path: '/risk-audit',
         redirect: (context, state) => state.uri.replace(path: '/services/risk-audit').toString(),
      ),
      GoRoute(
        path: '/payment',
         redirect: (context, state) => state.uri.replace(path: '/services').toString(),
      ),
    ],
  );
}
