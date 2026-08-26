
import 'package:flutter/material.dart';

void main() {
  runApp(const BibleLessonApp());
}

class BibleLessonApp extends StatefulWidget {
  const BibleLessonApp({super.key});

  @override
  State<BibleLessonApp> createState() => _BibleLessonAppState();
}

class _BibleLessonAppState extends State<BibleLessonApp> {
  bool isDarkMode = false;
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible Lesson App',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MainHomeScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: (val) {
          setState(() {
            isDarkMode = val;
          });
        },
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainHomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> lessons = [
    {
      'title': 'Lesson 1: Faith & Hope',
      'content': 'Faith is the substance of things hoped for, the evidence of things not seen. (Hebrews 11:1)'
    },
    {
      'title': 'Lesson 2: Love & Compassion',
      'content': 'Love is patient, love is kind. It does not envy, it does not boast. (1 Corinthians 13:4)'
    },
    {
      'title': 'Lesson 3: Peace & Wisdom',
      'content': 'The Lord is my shepherd; I shall not want. He makes me lie down in green pastures. (Psalm 23:1)'
    },
  ];

  final List<String> favorites = [];
  final List<String> notes = [];

  double playbackSpeed = 1.0;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeSection(),
      _buildLessonsSection(),
      _buildBibleReaderSection(),
      _buildNotesSection(),
      _buildFavoritesSection(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Bible Lesson App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: LessonSearchDelegate(lessons),
              );
            },
          ),
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Lessons'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Bible'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
        ],
      ),
    );
  }

  Widget _buildHomeSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏠 Welcome to Bible Study',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.blueAccent.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✨ Verse of the Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 5),
                  Text('"For I know the plans I have for you," declares the LORD. (Jeremiah 29:11)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildAudioPlayerCard(),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('🔊 Lesson Audio Player', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                  iconSize: 40,
                  onPressed: () {
                    setState(() {
                      isPlaying = !isPlaying;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  onPressed: () {},
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Speed: '),
                DropdownButton<double>(
                  value: playbackSpeed,
                  items: [0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                    return DropdownMenuItem(
                      value: speed,
                      child: Text('${speed}x'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        playbackSpeed = val;
                      });
                    }
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsSection() {
    return ListView.builder(
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isFav = favorites.contains(lesson['title']);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(lesson['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(lesson['content']!),
            trailing: IconButton(
              icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : null),
              onPressed: () {
                setState(() {
                  if (isFav) {
                    favorites.remove(lesson['title']);
                  } else {
                    favorites.add(lesson['title']!);
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBibleReaderSection() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📖 Bible Reader', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SelectableText(
            '🖍️ Genesis 1:1 - In the beginning God created the heavens and the earth.\n\n'
            'John 3:16 - For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '📝 Write a note...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    setState(() {
                      notes.add(controller.text);
                      controller.clear();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(notes[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          notes.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return favorites.isEmpty
        ? const Center(child: Text('⭐ No favorites added yet.'))
        : ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(favorites[index]),
              );
            },
          );
  }
}

class LessonSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> lessons;

  LessonSearchDelegate(this.lessons);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final results = lessons
        .where((l) => l['title']!.toLowerCase().contains(query.toLowerCase()) || l['content']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]['title']!),
          subtitle: Text(results[index]['content']!),
        );
      },
    );
  }
}
