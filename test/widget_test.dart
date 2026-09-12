import 'package:flutter_test/flutter_test.dart';
import 'package:disciphobby_tracker/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Запускаем наш актуальный виджет приложения
    await tester.pumpWidget(const DiscipHobbyApp());

    // Проверяем, что заголовок приложения отображается корректно
    expect(find.text('DiscipHobby Tracker'), findsOneWidget);
  });
}