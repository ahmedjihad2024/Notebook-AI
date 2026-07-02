# Testing Strategy & Guidelines

This document outlines the testing strategy for Notebook AI, built with **Feature-first architecture and Riverpod**.

Our primary focus is ensuring business logic is stable. We rely on **Unit Testing** for isolated components and **Logic Integration Testing** to verify layers work together.

---

## 1. Unit Testing (Isolated Logic)

Unit tests check isolated pieces of code (a single Notifier, DataSource, or utility). We mock immediate dependencies using `mocktail` to ensure tests run in milliseconds.

### Example: Testing a Notifier (Riverpod)

To test a Notifier, we use `ProviderContainer` to read the provider with overridden dependencies.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockDataSource extends Mock implements NotesDataSource {}

void main() {
  late MockDataSource mockDs;
  late ProviderContainer container;

  setUp(() {
    mockDs = MockDataSource();
    container = ProviderContainer(
      overrides: [
        // Override the data source provider with our mock
      ],
    );
  });

  test('NoteEditorNotifier updates tags on runTag', () async {
    when(() => mockDs.save(any())).thenAnswer((_) async {});

    final notifier = container.read(noteEditorProvider.notifier);
    await notifier.runTag('test text');

    final state = container.read(noteEditorProvider);
    expect(state.tags.isNotEmpty, true);
  });
}
```

---

## 2. Test Folder Structure

To keep tests maintainable and easy to navigate, the `test/` folder should mirror the `lib/` folder structure exactly.

```
test/
├── helpers/                      # Mock definitions, dummy data, and setup helpers
│   ├── mocks.dart                # Mock classes
│   └── test_extensions.dart      # Custom test matchers
│
├── unit/                         # Isolated Unit Tests
│   ├── features/
│   │   └── notes/
│   │       └── data/
│   │           └── providers/
│   │               └── note_editor_provider_test.dart
│   └── core/
│       └── utils/
└── integration/                  # Logic Integration Tests (Multi-Layer, No UI)
    └── notes/
        └── create_note_integration_test.dart
```

**Key Rules:**
1. **Strict Mirroring**: If a class is at `lib/features/notes/data/providers/note_editor_provider.dart`, its test MUST be at `test/unit/features/notes/data/providers/note_editor_provider_test.dart`.
2. **Centralized Helpers**: Never define mocks directly inside the test file if they will be reused. Put them in `helpers/mocks.dart`.
3. **Naming Convention**: Every test file must end with `_test.dart` or Flutter won't run it.
