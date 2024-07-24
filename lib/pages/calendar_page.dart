import 'dart:core';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _currentRecordingPath;
  Map<DateTime, String> _voiceNotes = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: 'aFullPath/myFile.m4a');
        setState(() {
          _isRecording = true;
          _currentRecordingPath = path;
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        _voiceNotes[DateTime.now()] = path;
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording(String path) async {
    try {
      await _audioPlayer.play(DeviceFileSource(path));
    } catch (e) {
      print('Error playing recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F7F4), // Light cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              SizedBox(height: 20),
              _buildWeekCalendar(),
              SizedBox(height: 40),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "What are you thankful for today?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: _isRecording ? _stopRecording : _startRecording,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA8E0D1), // Light mint green
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Tap to record",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
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
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) =>
              Text(day, style: GoogleFonts.inter(fontWeight: FontWeight.bold)))
              .toList(),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final date = weekStart.add(Duration(days: index));
            final isSelected = date.day == _selectedDate.day;
            final hasNote = _voiceNotes.containsKey(date);
            final isPastOrToday = date.isBefore(today) || date.isAtSameMomentAs(today);

            return GestureDetector(
              onTap: isPastOrToday
                  ? () => setState(() => _selectedDate = date)
                  : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Color(0xFF8871E6) : Colors.transparent,
                ),
                child: Center(
                  child: isPastOrToday
                      ? hasNote
                      ? Icon(Icons.play_arrow, color: isSelected ? Colors.white : Colors.black)
                      : Text(
                    '${date.day}',
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  )
                      : Text(
                    '${date.day}',
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
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
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
