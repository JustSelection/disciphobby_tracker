// lib/screens/active_object_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/active_object_screen_body.dart';
import 'active_object_screen_actions.dart';

class ActiveObjectScreen extends StatefulWidget {
  final HobbyObject object;
  const ActiveObjectScreen({super.key, required this.object});

  @override
  State<ActiveObjectScreen> createState() => _ActiveObjectScreenState();
}

class _ActiveObjectScreenState extends State<ActiveObjectScreen> {
  @override
  Widget build(BuildContext context) {
    // Реактивный поток для самого объекта (имя, эмодзи, даты)
    final objectStream = (db.select(db.hobbyObjects)
          ..where((t) => t.id.equals(widget.object.id)))
        .watchSingle();

    return StreamBuilder<HobbyObject>(
      stream: objectStream,
      builder: (context, objSnapshot) {
        if (!objSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final currentObject = objSnapshot.data!;

        // Реактивный поток для заметок этого объекта
        final notesStream = (db.select(db.notes)
              ..where((t) => t.objectId.equals(widget.object.id))
              ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)]))
            .watch();

        return StreamBuilder<List<Note>>(
          stream: notesStream,
          builder: (context, notesSnapshot) {
            final notes = notesSnapshot.data ?? [];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Активный объект', overflow: TextOverflow.ellipsis),
              ),
              body: ActiveObjectScreenBody(
                isLoading: false, // Stream управляет состоянием загрузки
                notes: notes,
                object: currentObject,
                onRefresh: () async {
                  // Stream обновляется автоматически, задержка только для UX индикатора
                  await Future.delayed(const Duration(milliseconds: 300));
                },
                onEmojiTap: () => changeEmoji(
                  context: context,
                  currentObject: currentObject,
                  onDataChanged: () {}, // Stream сделает обновление автоматически
                ),
                onNameTap: () => editObjectName(
                  context: context,
                  currentObject: currentObject,
                  onDataChanged: () {},
                ),
                onNoteTap: (note) => editNote(
                  context: context,
                  note: note,
                  onDataChanged: () {},
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => showAddNoteDialog(
                  context: context,
                  objectId: widget.object.id,
                  onDataChanged: () {},
                ),
                icon: const Icon(Icons.add),
                label: const Text('Записать мысль'),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton.icon(
                  onPressed: () => startCompletionFlow(
                    context: context,
                    currentObject: currentObject,
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Завершить объект'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}