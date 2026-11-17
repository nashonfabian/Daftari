import 'package:daftari/main.dart';
import 'package:daftari/page_entry.dart';
import 'package:daftari/page_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryPageStore implements PageStore {
  final List<PageEntry> pages = [];
  int _nextId = 1;

  @override
  Future<List<PageEntry>> getPages() async =>
      [...pages]..sort((a, b) => b.date.compareTo(a.date));

  @override
  Future<int> savePage(PageEntry page) async {
    final id = page.id ?? _nextId++;
    pages.removeWhere((saved) => saved.id == id);
    pages.add(
      PageEntry(id: id, title: page.title, body: page.body, date: page.date),
    );
    return id;
  }

  @override
  Future<void> deletePage(int id) async {
    pages.removeWhere((page) => page.id == id);
  }
}

void main() {
  testWidgets('creates a page and saves an edited date', (tester) async {
    final store = MemoryPageStore();
    await tester.pumpWidget(DaftariApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Write your first page'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'My day');
    await tester.enterText(find.byType(TextFormField).at(1), 'A quiet day.');

    await tester.tap(find.byKey(const ValueKey('page-date-picker')));
    await tester.pumpAndSettle();
    final dayToSelect = DateTime.now().day == 1 ? '2' : '1';
    await tester.tap(find.text(dayToSelect).last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save page'));
    await tester.pumpAndSettle();

    expect(store.pages, hasLength(1));
    expect(store.pages.single.title, 'My day');
    expect(store.pages.single.body, 'A quiet day.');
    expect(store.pages.single.date.day, int.parse(dayToSelect));
    expect(find.text('My day'), findsOneWidget);
  });
}
