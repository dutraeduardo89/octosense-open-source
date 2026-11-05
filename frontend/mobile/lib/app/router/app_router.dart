import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/session/user_session.dart';
import '../../features/auth/presentation/auth_pages.dart';
import '../../features/auth/presentation/permissions_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/learn/presentation/learn_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/trends/presentation/trends_page.dart';
import '../widgets/app_shell.dart';

/// Rotas que NÃO exigem autenticação.
const _publicRoutes = {'/welcome'};

/// Rotas que fazem parte do fluxo pós-login (onboarding + permissões).
/// Passam pelo router mesmo sem redirect, porque o usuário acabou de logar.
const _postLoginRoutes = {'/onboarding', '/permissions'};

final appRouter = GoRouter(
  initialLocation: '/welcome',

  /// Auto-login e auto-logout.
  ///
  /// Roda ANTES de qualquer navegação:
  /// - Se tem token e está tentando ir pra /welcome → vai direto pra /
  /// - Se NÃO tem token e está tentando ir pra rota privada → vai pra /welcome
  ///
  /// Como main.dart chama UserSession.restore() antes do runApp, a flag
  /// isAuthenticated já está preenchida na primeira navegação.
  redirect: (context, state) {
    if (!getIt.isRegistered<UserSession>()) {
      return null;
    }

    final session = getIt<UserSession>();
    final isAuthenticated = session.isAuthenticated;
    final loc = state.matchedLocation;

    final isPublic = _publicRoutes.contains(loc);
    final isPostLogin = _postLoginRoutes.contains(loc);

    // Sem token em rota privada → welcome
    if (!isAuthenticated && !isPublic && !isPostLogin) {
      return '/welcome';
    }

    // Já logado tentando abrir /welcome → dashboard
    if (isAuthenticated && isPublic) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/permissions',
      builder: (context, state) =>
          PermissionsPage(force: state.uri.queryParameters['force'] == '1'),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(location: state.uri.path, child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
        GoRoute(
          path: '/trends',
          builder: (context, state) => const TrendsPage(),
        ),
        GoRoute(path: '/learn', builder: (context, state) => const LearnPage()),
        GoRoute(
          path: '/learn/overview',
          builder: (context, state) =>
              const LearnDetailPage(section: LearnSection.overview),
        ),
        GoRoute(
          path: '/learn/sensors',
          builder: (context, state) =>
              const LearnDetailPage(section: LearnSection.sensors),
        ),
        GoRoute(
          path: '/learn/science',
          builder: (context, state) =>
              const LearnDetailPage(section: LearnSection.science),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/settings/account',
          builder: (context, state) => const AccountSettingsPage(),
        ),
        GoRoute(
          path: '/settings/devices',
          builder: (context, state) => const DevicesSettingsPage(),
        ),
        GoRoute(
          path: '/settings/accessibility',
          builder: (context, state) => const AccessibilitySettingsPage(),
        ),
        GoRoute(
          path: '/settings/privacy',
          builder: (context, state) => const PrivacySettingsPage(),
        ),
        GoRoute(
          path: '/settings/help',
          builder: (context, state) => const HelpSettingsPage(),
        ),
        GoRoute(
          path: '/settings/about',
          builder: (context, state) => const AboutSettingsPage(),
        ),
      ],
    ),
  ],
);
