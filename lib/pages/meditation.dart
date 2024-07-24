import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

import '../utils.dart';

class MeditationTimer extends StatefulWidget {
  final String meditationType;

  const MeditationTimer({Key? key, required this.meditationType}) : super(key: key);

  @override
  State<MeditationTimer> createState() => _MeditationTimerState();
}

class _MeditationTimerState extends State<MeditationTimer> {
  bool isActive = false;
  int _seconds = 0;
  int _totalSeconds = 0;
  late Timer _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  List<int> presetTimes = [60, 180, 300]; // 1 min, 3 min, 5 min in seconds

  late IconData meditationIcon;
  late Color meditationColor;

  @override
  void initState() {
    super.initState();
    _setMeditationProperties();
  }

  void _setMeditationProperties() {
    switch (widget.meditationType.toLowerCase()) {
      case 'fireplace':
        meditationIcon = Icons.fireplace;
        meditationColor = Colors.orange;
        break;
      case 'ocean':
        meditationIcon = Icons.water;
        meditationColor = Colors.blue;
        break;
      case 'wind':
        meditationIcon = Icons.air;
        meditationColor = Colors.greenAccent;
        break;
      default:
        meditationIcon = Icons.spa;
        meditationColor = teal;
    }
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _resetTimer();
    setState(() {
      _seconds = seconds;
      _totalSeconds = seconds;
      isActive = true;
      isPlaying = true;
    });
    _audioPlayer.play(AssetSource('${widget.meditationType.toLowerCase()}.mp3'));
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer.cancel();
        _audioPlayer.stop();
        setState(() {
          isActive = false;
          isPlaying = false;
        });
      }
    });
  }

  void _pauseResumeTimer() {
    if (isActive) {
      _timer.cancel();
      _audioPlayer.pause();
    } else {
      _startTimer(_seconds);
    }
    setState(() {
      isActive = !isActive;
      isPlaying = isActive;
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _audioPlayer.stop();
    setState(() {
      _seconds = 0;
      _totalSeconds = 0;
      isActive = false;
      isPlaying = false;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(widget.meditationType),
        backgroundColor: meditationColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: CircularProgressIndicator(
                    value: _totalSeconds == 0 ? 0 : (_totalSeconds - _seconds) / _totalSeconds,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(meditationColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(meditationIcon, size: 60, color: meditationColor),
                    SizedBox(height: 10),
                    Text(
                      _formatTime(_seconds),
                      style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.bold, color: meditationColor),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: presetTimes.map((time) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _startTimer(time),
                    child: Text('${time ~/ 60} min', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(backgroundColor: meditationColor),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _seconds > 0 ? _pauseResumeTimer : null,
                  child: Text(isActive ? 'Pause' : 'Resume', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(backgroundColor: meditationColor),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text('Reset', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(backgroundColor: meditationColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}