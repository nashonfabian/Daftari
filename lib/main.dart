import 'package:flutter/material.dart';

import 'page_entry.dart';
import 'page_store.dart';

const _paper = Color(0xFFFFFEFA);
const _background = Color(0xFFF6F4EF);
const _ink = Color(0xFF252923);
const _muted = Color(0xFF777B72);
const _green = Color(0xFF47634F);

void main() {
  runApp(DaftariApp(store: SqlitePageStore.instance));
}

class DaftariApp extends StatelessWidget {
  const DaftariApp({super.key, required this.store});

  final PageStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Daftari',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _green,
            surface: _paper,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: _background,
            foregroundColor: _ink,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: _paper,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        home: NotebookScreen(store: store),
      );
}

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key, required this.store});

  final PageStore store;

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  List<PageEntry> _pages = [];
  bool _loading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final pages = await widget.store.getPages();
      if (!mounted) return;
      setState(() {
        _pages = pages;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error;
      });
    }
  }

  Future<void> _editPage([PageEntry? page]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PageEditorScreen(store: widget.store, page: page),
      ),
    );
    if (changed == true) await _loadPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftari',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                'OFFLINE  |  PRIVATE',
                style: TextStyle(
                  color: _green,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? _ErrorState(error: _loadError!, onRetry: _loadPages)
                : _pages.isEmpty
                    ? _EmptyState(onNewPage: () => _editPage())
                    : RefreshIndicator(
                        onRefresh: _loadPages,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                          children: [
                            const Text(
                              'YOUR PAGES',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (final page in _pages)
                              _PageCard(
                                page: page,
                                onTap: () => _editPage(page),
                              ),
                          ],
                        ),
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editPage(),
        tooltip: 'New page',
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New page'),
      ),
    );
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({required this.page, required this.onTap});

  final PageEntry page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: _paper,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE9E6DE)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(page.date),
                  style: const TextStyle(
                    color: _green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  page.title.isEmpty ? 'Untitled page' : page.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (page.body.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    page.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onNewPage});

  final VoidCallback onNewPage;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEE7),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.menu_book_outlined,
                    size: 34, color: _green),
              ),
              const SizedBox(height: 20),
              const Text(
                'A little space for your thoughts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w600, color: _ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your pages stay private on this device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onNewPage,
                icon: const Icon(Icons.add),
                label: const Text('Write your first page'),
              ),
            ],
          ),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 34),
              const SizedBox(height: 12),
              const Text('Could not load your pages.'),
              const SizedBox(height: 6),
              Text('$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted)),
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      );
}

class PageEditorScreen extends StatefulWidget {
  const PageEditorScreen({super.key, required this.store, this.page});

  final PageStore store;
  final PageEntry? page;

  @override
  State<PageEditorScreen> createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late DateTime _pageDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.page?.title ?? '');
    _bodyController = TextEditingController(text: widget.page?.body ?? '');
    _pageDate = widget.page?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _pageDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Choose page date',
    );
    if (chosen != null) setState(() => _pageDate = chosen);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.store.savePage(
        PageEntry(
          id: widget.page?.id,
          title: _titleController.text.trim().isEmpty
              ? 'Untitled page'
              : _titleController.text.trim(),
          body: _bodyController.text,
          date: _pageDate,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save page: $error')),
      );
    }
  }

  Future<void> _delete() async {
    final id = widget.page?.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this page?'),
        content: const Text('This page will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.store.deletePage(id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete page: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.page != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit page' : 'New page'),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Delete page',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Untitled page',
                      ),
                    ),
                    const SizedBox(height: 14),
                    Card(
                      color: _paper,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFE9E6DE)),
                      ),
                      child: ListTile(
                        key: const ValueKey('page-date-picker'),
                        onTap: _pickDate,
                        leading: const Icon(Icons.calendar_today_outlined,
                            color: _green),
                        title: const Text('PAGE DATE'),
                        subtitle: Text(_formatDate(_pageDate)),
                        trailing:
                            const Icon(Icons.edit_outlined, color: _muted),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _bodyController,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      minLines: 12,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Your thoughts',
                        hintText: 'Start writing...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save page'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
