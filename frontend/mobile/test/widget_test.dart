import 'package:flutter_test/flutter_test.dart';
import 'package:octosense/app/octosense_app.dart';
import 'package:octosense/app/widgets/octosense_logo.dart';

void main() {
  testWidgets('renders Google-only OctoSense entry', (tester) async {
    await tester.pumpWidget(const OctoSenseApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(OctoSenseLogo), findsWidgets);
    expect(
      find.text('Seu corpo, de um jeito fácil de entender.'),
      findsOneWidget,
    );

    expect(find.text('Entrar com Google'), findsOneWidget);

    // Não deve existir autenticação local por senha.
    expect(find.text('Entrar'), findsNothing);
    expect(find.text('Criar conta'), findsNothing);
    expect(find.text('Esqueci minha senha'), findsNothing);
  });
}
