import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils.dart';
import 'meditation.dart';

class MeditationHomePage extends StatelessWidget {
  const MeditationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MeditationOption> meditationOptions = [
      MeditationOption(
        icon: "assets/fire.json",
        label: "Fireplace",
        color: Colors.orange,
      ),
      MeditationOption(
        icon: "assets/ocean.json",
        label: "Ocean",
        color: Colors.blue,
      ),
      MeditationOption(
        icon: "assets/wind.json",
        label: "Wind",
        color: Colors.greenAccent,
      ),
    ];

    return Scaffold(
      backgroundColor: cream,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Lottie.asset('assets/meditation.json'),
          ),
          Text(
            "Choose Your Meditation",
            style: GoogleFonts.montserrat(
              fontSize: 22,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
              color: black,
            ),
          ),
          CarouselSlider.builder(
            itemCount: meditationOptions.length,
            itemBuilder: (BuildContext context, int index, int realIdx) {
              return MeditationCard(option: meditationOptions[index]);
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.3,
              enlargeCenterPage: true,
              autoPlay: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class MeditationOption {
  final String icon;
  final String label;
  final Color color;

  MeditationOption(
      {required this.icon, required this.label, required this.color});
}

class MeditationCard extends StatelessWidget {
  final MeditationOption option;

  const MeditationCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: option.color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: option.color.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(option.icon, width: 100, height: 100),
          const SizedBox(height: 8),
          Text(
            option.label,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MeditationTimer(meditationType: option.label),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: option.color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Start',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
