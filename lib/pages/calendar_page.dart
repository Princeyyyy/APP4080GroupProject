import 'dart:core';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  Map<DateTime, List<Map<String, dynamic>>> _voiceNotes = {};
  DateTime _selectedDate = DateTime.now();
  late Future<Database> _databaseFuture;
  Stopwatch _recordingStopwatch = Stopwatch();
  Duration _playbackPosition = Duration.zero;
  int? _playingIndex;
  Timer? _recordingTimer;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _databaseFuture = _initDatabase();
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _playbackPosition = position;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
        _playbackPosition = Duration.zero;
      });
    });
    _loadVoiceNotes();
    _currentWeekStart = _getWeekStart(DateTime.now());
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _navigateWeek(int weeks) {
    final now = DateTime.now();
    final newWeekStart = _currentWeekStart.add(Duration(days: 7 * weeks));
    if (newWeekStart.isBefore(now) || _isSameWeek(newWeekStart, now)) {
      setState(() {
        _currentWeekStart = newWeekStart;
        if (_selectedDate.isAfter(now)) {
          _selectedDate = now;
        }
      });
    }
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final week1Start = _getWeekStart(date1);
    final week2Start = _getWeekStart(date2);
    return week1Start == week2Start;
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'voice_notes.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE voice_notes (id INTEGER PRIMARY KEY, date TEXT, path TEXT, duration INTEGER)',
        );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db
              .execute('ALTER TABLE voice_notes ADD COLUMN duration INTEGER');
        }
      },
    );
  }

  Future<void> _loadVoiceNotes() async {
    final database = await _databaseFuture;
    final List<Map<String, dynamic>> maps = await database.query('voice_notes');
    setState(() {
      _voiceNotes = {};
      for (var map in maps) {
        final date = DateTime.parse(map['date']).toLocal();
        final path = map['path'] as String;
        final durationMillis = map['duration'] as int?;
        final duration = durationMillis != null
            ? Duration(milliseconds: durationMillis)
            : Duration.zero;
        final dateKey = DateTime(date.year, date.month, date.day);
        if (_voiceNotes.containsKey(dateKey)) {
          _voiceNotes[dateKey]!.add({'path': path, 'duration': duration});
        } else {
          _voiceNotes[dateKey] = [
            {'path': path, 'duration': duration}
          ];
        }
      }
    });
  }

  Future<void> _saveVoiceNote(
      DateTime date, String path, Duration duration) async {
    final database = await _databaseFuture;
    await database.insert(
      'voice_notes',
      {
        'date': date.toUtc().toIso8601String(),
        'path': path,
        'duration': duration.inMilliseconds - 1000,
        // Subtract one second (1000 milliseconds)
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _loadVoiceNotes();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
        });
        _recordingStopwatch.reset();
        _recordingStopwatch.start();
        _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          setState(
              () {}); // This will rebuild the widget to update the duration display
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _recordingStopwatch.stop();
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        await _saveVoiceNote(_selectedDate, path, _recordingStopwatch.elapsed);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> _playRecording(String path, int index) async {
    if (_isPlaying && _playingIndex == index) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
        _playbackPosition = Duration.zero;
      });
    } else {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(path));
        setState(() {
          _isPlaying = true;
          _playingIndex = index;
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error playing recording: $e');
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Daily Gratitude",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildWeekCalendar(),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Flexible(child: _buildRecordingsList()),
                    Text(
                      "What are you thankful for today?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: AvatarGlow(
                        startDelay: const Duration(milliseconds: 1000),
                        glowColor: const Color(0xFFA8E0D1),
                        glowShape: BoxShape.circle,
                        animate: true,
                        curve: Curves.fastOutSlowIn,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA8E0D1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isRecording
                          ? "Recording: ${_formatDuration(_recordingStopwatch.elapsed)}"
                          : "Tap to record",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final now = DateTime.now();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _navigateWeek(-1),
            ),
            Text(
              "${_currentWeekStart.day} ${_getMonthName(_currentWeekStart.month)} - ${_currentWeekStart.add(const Duration(days: 6)).day} ${_getMonthName(_currentWeekStart.add(const Duration(days: 6)).month)}",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _isSameWeek(_currentWeekStart, now)
                  ? null
                  : () => _navigateWeek(1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Text(day,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold)))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final date = _currentWeekStart.add(Duration(days: index));
            final dateKey = DateTime(date.year, date.month, date.day);
            final isSelected = dateKey.isAtSameMomentAs(DateTime(
                _selectedDate.year, _selectedDate.month, _selectedDate.day));
            final hasNote = _voiceNotes.containsKey(dateKey);
            final isToday = dateKey
                .isAtSameMomentAs(DateTime(now.year, now.month, now.day));
            final isPastOrToday = date.isBefore(now) || isToday;

            return GestureDetector(
              onTap: isPastOrToday
                  ? () => setState(() {
                        _selectedDate = date;
                      })
                  : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF8871E6)
                      : (isToday
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.transparent),
                ),
                child: Center(
                  child: hasNote
                      ? Icon(Icons.music_note,
                          color: isSelected ? Colors.white : const Color(0xFF8871E6),
                          size: 18)
                      : Text(
                          '${date.day}',
                          style: GoogleFonts.inter(
                            color: isPastOrToday
                                ? (isSelected
                                    ? Colors.white
                                    : (isToday ? Colors.black : Colors.black54))
                                : Colors.black26,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  Widget _buildRecordingsList() {
    final dateKey =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final recordings = _voiceNotes[dateKey] ?? [];
    if (recordings.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "No recordings for this day",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const Spacer(), // This will push the content below to the bottom
          const SizedBox(height: 10),
        ],
      );
    }
    return ListView.builder(
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final recording = recordings[index];
        final isPlaying = _isPlaying && _playingIndex == index;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.music_note, color: Color(0xFF8871E6)),
            title: Text(
              "Recording ${index + 1}",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              "Duration: ${_formatDuration(recording['duration'])}",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPlaying)
                  Text(
                    _formatDuration(_playbackPosition),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.stop : Icons.play_arrow,
                    color: const Color(0xFF8871E6),
                  ),
                  onPressed: () => _playRecording(recording['path'], index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
