// lib/widgets/next_object_step_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';

/// Шаг 3 ритуала завершения: Экран успеха и выбора следующего объекта (Сцена 5).
class NextObjectStepWidget extends StatefulWidget {
  final HobbyObject completedObject;
  final List<HobbyObject> queuedObjects;
  final HobbyObject? deferredObject;
  final ValueChanged<HobbyObject> onObjectSelected; // ИЗМЕНЕНО: теперь передает объект
  final VoidCallback onAddNewObject;
  final VoidCallback onLeaveEmpty;

  const NextObjectStepWidget({
    super.key,
    required this.completedObject,
    required this.queuedObjects,
    required this.deferredObject,
    required this.onObjectSelected,
    required this.onAddNewObject,
    required this.onLeaveEmpty,
  });

  @override
  State<NextObjectStepWidget> createState() => _NextObjectStepWidgetState();
}

class _NextObjectStepWidgetState extends State<NextObjectStepWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _successController;
  bool _showChooser = false;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showChooser = true);
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _onObjectTapped(HobbyObject obj) {
    HapticFeedback.mediumImpact();
    widget.onObjectSelected(obj); // ИЗМЕНЕНО: передаем объект
  }

  bool get _hasAnyNextObject =>
      widget.queuedObjects.isNotEmpty || widget.deferredObject != null;

  @override
  Widget build(BuildContext context) {
    if (!_showChooser) {
      return _SuccessScreen(
        controller: _successController,
        emoji: widget.completedObject.emoji,
        name: widget.completedObject.name,
      );
    }
    if (!_hasAnyNextObject) {
      return _EmptyQueueState(
        onAddNew: widget.onAddNewObject,
        onLeaveEmpty: widget.onLeaveEmpty,
      );
    }
    return _ChooserScreen(
      queuedObjects: widget.queuedObjects,
      deferredObject: widget.deferredObject,
      onObjectTapped: _onObjectTapped,
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final AnimationController controller;
  final String emoji;
  final String name;

  const _SuccessScreen({
    required this.controller,
    required this.emoji,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _ConfettiPainter(controller: controller))),
        Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final scale = 0.5 + controller.value * 0.5;
              return Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withValues(alpha: 0.6 * controller.value),
                            Colors.amber.withValues(alpha: 0),
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 80)),
                    ),
                    const SizedBox(height: 32),
                    Text('Объект завершен!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(name, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final AnimationController controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  _ConfettiPainter({required this.controller}) {
    for (int i = 0; i < 40; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        startY: -0.1 - _random.nextDouble() * 0.3,
        speed: 0.5 + _random.nextDouble() * 0.5,
        color: [Colors.amber, Colors.pink, Colors.cyan, Colors.green, Colors.purple][_random.nextInt(5)],
        size: 4 + _random.nextDouble() * 6,
        rotation: _random.nextDouble() * pi * 2,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final progress = controller.value;
    for (final p in _particles) {
      final y = (p.startY + progress * p.speed * 1.5) * size.height;
      final x = p.x * size.width + sin(progress * 4 + p.rotation) * 20;
      final paint = Paint()..color = p.color.withValues(alpha: 1.0 - progress * 0.5);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 6 + p.rotation);
      canvas.drawRect(Rect.fromLTWH(-p.size / 2, -p.size / 2, p.size, p.size * 0.6), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConfettiParticle {
  final double x, startY, speed, rotation, size;
  final Color color;
  _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.color,
    required this.size,
    required this.rotation,
  });
}

class _ChooserScreen extends StatelessWidget {
  final List<HobbyObject> queuedObjects;
  final HobbyObject? deferredObject;
  final ValueChanged<HobbyObject> onObjectTapped;

  const _ChooserScreen({
    required this.queuedObjects,
    required this.deferredObject,
    required this.onObjectTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выберите следующий объект', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Из очереди или отложенного слота', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 24),
          if (deferredObject != null) ...[
            Text('Отложенный слот', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 8),
            _ObjectCard(object: deferredObject!, onTap: () => onObjectTapped(deferredObject!)),
            const SizedBox(height: 16),
          ],
          if (queuedObjects.isNotEmpty) ...[
            Text('Очередь (${queuedObjects.length})', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 8),
            Expanded(child: ListView.builder(itemCount: queuedObjects.length, itemBuilder: (ctx, i) => _ObjectCard(object: queuedObjects[i], onTap: () => onObjectTapped(queuedObjects[i])))),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}

class _ObjectCard extends StatelessWidget {
  final HobbyObject object;
  final VoidCallback onTap;

  const _ObjectCard({required this.object, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Text(object.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(child: Text(object.name, style: theme.textTheme.titleMedium)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _EmptyQueueState extends StatelessWidget {
  final VoidCallback onAddNew;
  final VoidCallback onLeaveEmpty;

  const _EmptyQueueState({required this.onAddNew, required this.onLeaveEmpty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined, size: 80, color: theme.colorScheme.outline),
          const SizedBox(height: 24),
          Text('Очередь пуста', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Добавьте новый объект или оставьте категорию пустой', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: onAddNew, icon: const Icon(Icons.add), label: const Text('Добавить объект сейчас'))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onLeaveEmpty, child: const Text('Оставить категорию пустой'))),
        ],
      ),
    );
  }
}