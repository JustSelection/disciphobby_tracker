// lib/data/quotes_part1.dart
/// Цитаты о фокусе, внимании и завершённости для Hobby Focus Tracker.
/// Часть 1 из 3.
library;

/// Модель одной цитаты.
class AppQuote {
  final String text;
  final String author;
  final String category;

  const AppQuote({
    required this.text,
    required this.author,
    required this.category,
  });
}

/// 🌿 Фокус + 🏁 Завершённость (20 цитат)
const List<AppQuote> quotesPart1 = [
  // 🌿 1. О ценности внимания и фокуса
  AppQuote(text: 'Внимание — самая редкая и чистая форма щедрости.', author: 'Симона Вейль', category: 'focus'),
  AppQuote(text: 'То, на чем вы фокусируетесь, растет. То, о чем вы думаете, расширяется.', author: 'Робин Шарма', category: 'focus'),
  AppQuote(text: 'У вас есть власть над своим разумом, но не над внешними событиями. Осознайте это, и вы обретете силу.', author: 'Марк Аврелий', category: 'focus'),
  AppQuote(text: 'Фокус — это искусство знать, что игнорировать.', author: 'Джеймс Клир', category: 'focus'),
  AppQuote(text: 'Способность фокусироваться — это суперсила.', author: 'Дженсен Хуанг', category: 'focus'),
  AppQuote(text: 'Качество вашей жизни определяется качеством ваших мыслей.', author: 'Марк Аврелий', category: 'focus'),
  AppQuote(text: 'Внимание — это валюта, в которой вы обмениваете свое время.', author: 'Современная философия осознанности', category: 'focus'),
  AppQuote(text: 'Не позволяйте размышлениям о всей полноте жизни раздавить вас. Живите настоящим.', author: 'Марк Аврелий', category: 'focus'),
  AppQuote(text: 'Вы становитесь тем, чему вы уделяете свое внимание.', author: 'На основе стоической философии', category: 'focus'),
  AppQuote(text: 'Мудрые люди фокусируются на правильных вещах.', author: 'Дженсен Хуанг', category: 'focus'),

  // 🏁 2. О радости завершенности
  AppQuote(text: 'Начать — похвально, но закончить — самое важное.', author: 'Фрэнк Эдвардс', category: 'completion'),
  AppQuote(text: 'Природа не спешит, однако все успевает.', author: 'Лао-цзы', category: 'completion'),
  AppQuote(text: 'Лучше пройти один путь до конца, чем начинать тысячу и бросать их на полпути.', author: 'Восточная мудрость', category: 'completion'),
  AppQuote(text: 'Дисциплина — это мост между целями и их достижением.', author: 'Джим Рон', category: 'completion'),
  AppQuote(text: 'Завершение дела дает разуму покой, которого не может дать начало.', author: 'Принципы самодисциплины', category: 'completion'),
  AppQuote(text: 'Не бойтесь медленного продвижения, бойтесь только остановки.', author: 'Китайская пословица', category: 'completion'),
  AppQuote(text: 'Мастерство достигается не количеством начатых дел, а количеством завершенных.', author: 'Принцип глубокой работы', category: 'completion'),
  AppQuote(text: 'Каждый раз, когда вы доводите дело до конца, вы укрепляете свою идентичность как человека, который держит слово перед самим собой.', author: 'Джеймс Клир', category: 'completion'),
  AppQuote(text: 'Заканчивайте сильно. Всегда.', author: 'Джон Спенс', category: 'completion'),
  AppQuote(text: 'Тот, кто движется вперед, пусть завершит начатое, ибо в завершении — мудрость.', author: 'Конфуций', category: 'completion'),
];