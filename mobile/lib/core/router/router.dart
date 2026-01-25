import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mobile/features/dashboard/presentation/screens/main_scaffold.dart';
import 'package:mobile/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/payments/presentation/screens/service_selection_screen.dart';
import 'package:mobile/features/payments/presentation/screens/visa_type_selection_screen.dart';
import 'package:mobile/features/payments/presentation/screens/order_summary_screen.dart';
import 'package:mobile/features/kyc/presentation/screens/form_wizard_screen.dart';
import 'package:mobile/features/kyc/presentation/screens/ai_intake_screen.dart';
import 'package:mobile/features/ocr/presentation/screens/verification_landing_screen.dart';
import 'package:mobile/features/ocr/presentation/screens/verification_scanner_screen.dart';
import 'package:mobile/features/ocr/presentation/screens/passport_confirm_screen.dart';
import 'package:mobile/features/ocr/logic/mrz_parser.dart';
import 'package:mobile/features/simulator/presentation/screens/simulator_intro_screen.dart';
import 'package:mobile/features/simulator/presentation/screens/simulator_interview_screen.dart';
import 'package:mobile/features/kyc/presentation/screens/chat_intake_screen.dart';
import 'package:mobile/features/risk_audit/presentation/screens/quick_check_screen.dart';
import 'package:mobile/features/risk_audit/presentation/screens/risk_audit_screen.dart';
import 'package:mobile/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:mobile/features/visa/presentation/screens/visa_category_selector_screen.dart';
import 'package:mobile/features/visa/presentation/screens/prerequisite_checker_screen.dart';
import 'package:mobile/features/travel_ban/presentation/screens/restriction_check_screen.dart';
import 'package:mobile/features/cost_calculator/presentation/screens/cost_calculator_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        path: '/services',
        builder: (context, state) => const ServiceSelectionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainScaffold(navigationShell: navigationShell),
        branches: [
          // Branch 1: Inicio (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 2: Servicios (Service Selection) - User asked "Where are services?"
          StatefulShellBranch(
            routes: [
               GoRoute(
                path: '/services_tab', // Distinct path for tab
                builder: (context, state) => const ServiceSelectionScreen(),
              ),
            ],
          ),
          // Branch 3: Placeholder (Keep 3 branches for nav balance, but Profile accessed via push)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile_tab', // Placeholder - actual Profile is standalone
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // STANDALONE PROFILE (No BottomNavBar)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const ServiceSelectionScreen(),
      ),
      GoRoute(
        path: '/visa-type',
        builder: (context, state) => const VisaTypeSelectionScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const OrderSummaryScreen(),
      ),
      GoRoute(
        path: '/kyc',
         builder: (context, state) {
           final type = state.uri.queryParameters['visa_type'] ?? 'b1b2'; 
           return ChatIntakeScreen(visaType: type);
        },
      ),
      GoRoute(
        path: '/kyc/chat',
        builder: (context, state) {
            // FIXED: Use the new AI Intake Screen which has the DB logic
            return const AiIntakeScreen();
        },
      ),
      GoRoute(
        path: '/kyc/confirm',
        builder: (context, state) {
           // ZERO TOLERANCE: Check query params instead of fragile extra object
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
           // Fallback: If no data, go to new Chat Intake
           final type = state.uri.queryParameters['visa_type'] ?? 'b1b2'; 
           return ChatIntakeScreen(visaType: type);
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
            builder: (context, state) => const SimulatorInterviewScreen(),
          ),
        ],
      ),
      // Alias for legacy support if needed, but better to migrate
      GoRoute(
        path: '/sim',
        redirect: (_, __) => '/simulator', 
      ),
      GoRoute(
        path: '/quick-check',
        builder: (context, state) => const QuickCheckScreen(),
      ),
      GoRoute(
        path: '/risk-audit',
        builder: (context, state) => const RiskAuditScreen(),
      ),
      GoRoute(
        path: '/chat-intake',
        builder: (context, state) {
           final type = state.uri.queryParameters['type'] ?? 'b1b2';
           return ChatIntakeScreen(visaType: type);
        },
      ),

      // VISA SERVICES ROUTES
      GoRoute(
        path: '/visa/select',
        builder: (context, state) => const VisaCategorySelectorScreen(),
      ),
      GoRoute(
        path: '/visa/prerequisites',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'] ?? 'B1/B2';
          return PrerequisiteCheckerScreen(visaCategoryCode: code);
        },
      ),
      GoRoute(
        path: '/travel-ban/check',
        builder: (context, state) => const RestrictionCheckScreen(),
      ),
      GoRoute(
        path: '/cost/calculate',
        builder: (context, state) => const CostCalculatorScreen(),
      ),
    ],
  );
}
