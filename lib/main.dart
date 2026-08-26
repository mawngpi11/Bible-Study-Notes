import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const BibleLessonApp());
}

class BibleLessonApp extends StatefulWidget {
  const BibleLessonApp({super.key});

  @override
  State<BibleLessonApp> createState() => _BibleLessonAppState();
}

class _BibleLessonAppState extends State<BibleLessonApp> {
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible Lesson App Pro',
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
  int _selectedIndex = 2; // Default to Bible Tab
  static const platform = MethodChannel('flutter.native/tts');
  String selectedLang = 'Myanmar';

  bool isLoggedIn = false;
  String userName = 'Guest User';
  String userEmail = 'Please sign in with Google';

  String selectedVersion = 'KJV';
  String selectedBook = 'Genesis';
  int selectedChapter = 1;

  final List<String> versions = ['KJV', 'ယုဒသန်', 'စံမီကျမ်း', 'TDB'];
  
  final List<String> bibleBooks = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
    'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
    '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
    'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
    'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations',
    'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
    'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
    'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
    'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy',
    '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James',
    '1 Peter', '2 Peter', '1 John', '2 John', '3 John',
    'Jude', 'Revelation'
  ];

  List<Map<String, String>> lessons = [];
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromLocalStorage();
  }

  Future<void> _loadDataFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? lessonsString = prefs.getString('saved_lessons');
    if (lessonsString != null) {
      final List decoded = jsonDecode(lessonsString);
      setState(() {
        lessons = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    } else {
      lessons = [
        {
          'title': 'Lesson 1: Faith & Hope',
          'content': 'Faith is the substance of things hoped for, the evidence of things not seen. (Hebrews 11:1)'
        }
      ];
    }

    final String? notesString = prefs.getString('saved_notes');
    if (notesString != null) {
      final List decoded = jsonDecode(notesString);
      setState(() {
        notes = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    } else {
      notes = [
        {
          'title': 'ဟေရှာယ ၅၃:၅',
          'content': 'ဒဏ်ချက်တော်ကြောင့် အနာပျောက်ခြင်းယူပါ။',
          'color': Colors.amber.value
        }
      ];
    }
  }

  Future<void> _saveDataToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_lessons', jsonEncode(lessons));
    await prefs.setString('saved_notes', jsonEncode(notes));
  }

  Future<void> _speak(String text) async {
    try {
      await platform.invokeMethod('speak', {'text': text, 'lang': selectedLang});
    } on PlatformException {
      // Fallback
    }
  }

  void _simulateGoogleLogin() {
    setState(() {
      isLoggedIn = true;
      userName = 'David Lian';
      userEmail = 'david.lian@gmail.com';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully signed in with Google! Data synced.')),
    );
  }

  void _signOut() {
    setState(() {
      isLoggedIn = false;
      userName = 'Guest User';
      userEmail = 'Please sign in with Google';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Bible & Lesson App'),
        actions: [
          DropdownButton<String>(
            value: selectedLang,
            dropdownColor: Theme.of(context).cardColor,
            items: ['Myanmar', 'English', 'Tedim'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => selectedLang = val!),
          ),
          IconButton(
            icon: Icon(isLoggedIn ? Icons.account_circle : Icons.login),
            onPressed: () => setState(() => _selectedIndex = 4),
          ),
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          )
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Lessons'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Bible'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (_selectedIndex == 0) return _buildHomeTab();
    if (_selectedIndex == 1) return _buildLessonsTab();
    if (_selectedIndex == 2) return _buildBibleTab();
    if (_selectedIndex == 3) return _buildNotesTab();
    if (_selectedIndex == 4) return _buildSettingsTab();
    return _buildBibleTab();
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌟 Daily Verse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                  const SizedBox(height: 10),
                  const Text('"Thy word is a lamp unto my feet, and a light unto my path." — Psalm 119:105', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue),
                      onPressed: () => _speak('Thy word is a lamp unto my feet, and a light unto my path.'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBibleTab() {
    String sampleContent = "$selectedBook Chapter $selectedChapter ($selectedVersion):\n"
        "1. In the beginning God created the heaven and the earth.\n"
        "2. And the earth was without form, and void; and darkness was upon the face of the deep.\n"
        "3. And God said, Let there be light: and there was light.";

    if (selectedVersion == 'ယုဒသန်') {
      sampleContent = "$selectedBook အခန်းကြီး $selectedChapter (ယုဒသန်):\n"
          "၁။ ရှေးဦးစ၌ ဘုရားသခင် သည် ကောင်းကင်နှင့်မြေကြီးကို ဖန်ဆင်းတော်မူ၏။\n"
          "၂။ မြေကြီးသည် ပြင်ဆင်၍မရှိ၊ မှောင်မိုက်ဖုံးလွှမ်း၏။";
    } else if (selectedVersion == 'TDB') {
      sampleContent = "$selectedBook Gel 3 $selectedChapter (TDB):\n"
          "1. A kipan in Pathianin van leh lei bawl hi.\n"
          "2. Lei pen koima om lo, ruak suak hi.";
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: selectedVersion,
                items: versions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (val) => setState(() => selectedVersion = val!),
              ),
              DropdownButton<String>(
                value: selectedBook,
                items: bibleBooks.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (val) => setState(() => selectedBook = val!),
              ),
              DropdownButton<int>(
                value: selectedChapter,
                items: List.generate(50, (index) => index + 1)
                    .map((c) => DropdownMenuItem(value: c, child: Text('Ch $c')))
                    .toList(),
                onChanged: (val) => setState(() => selectedChapter = val!),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$selectedBook $selectedChapter', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue, size: 30),
                      onPressed: () => _speak(sampleContent),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Text(sampleContent, style: const TextStyle(fontSize: 18, height: 1.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLessonDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final item = lessons[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['content']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    onPressed: () => _speak(item['content']!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showLessonDialog(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => lessons.removeAt(index));
                      _saveDataToLocalStorage();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLessonDialog({int? index}) {
    final titleCon = TextEditingController(text: index != null ? lessons[index]['title'] : '');
    final contentCon = TextEditingController(text: index != null ? lessons[index]['content'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add Lesson' : 'Edit Lesson'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCon, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: contentCon, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (index == null) {
                  lessons.add({'title': titleCon.text, 'content': contentCon.text});
                } else {
                  lessons[index] = {'title': titleCon.text, 'content': contentCon.text};
                }
              });
              _saveDataToLocalStorage();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add_comment),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final item = notes[index];
          return Card(
            color: Color(item['color'] ?? Colors.grey.value).withOpacity(0.3),
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['content']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.blue),
                    onPressed: () => _speak(item['content']!),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showNoteDialog(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => notes.removeAt(index));
                      _saveDataToLocalStorage();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNoteDialog({int? index}) {
    final titleCon = TextEditingController(text: index != null ? notes[index]['title'] : '');
    final contentCon = TextEditingController(text: index != null ? notes[index]['content'] : '');
    int selectedColor = index != null ? notes[index]['color'] : Colors.amber.value;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCon, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: contentCon, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Colors.amber, Colors.green, Colors.blue, Colors.pink].map((c) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = c.value),
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: 14,
                      child: selectedColor == c.value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (index == null) {
                    notes.add({'title': titleCon.text, 'content': contentCon.text, 'color': selectedColor});
                  } else {
                    notes[index] = {'title': titleCon.text, 'content': contentCon.text, 'color': selectedColor};
                  }
                });
                _saveDataToLocalStorage();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Account & Cloud Sync', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(userEmail, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                isLoggedIn
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
                        onPressed: _simulateGoogleLogin,
                        icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.blue),
                        label: const Text('Sign in with Google'),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: widget.isDarkMode,
          onChanged: widget.onThemeChanged,
        ),
      ],
    );
  }
}
