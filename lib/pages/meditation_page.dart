import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils.dart';
import 'meditation.dart';

class MeditationHomePage extends StatelessWidget {
  const MeditationHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/meditation.json'),
              const SizedBox(height: 20),
              Text(
                "Choose Your Meditation",
                style: GoogleFonts.montserrat(
                  fontSize: 25,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: black,
                ),
              ),
              const SizedBox(height: 20),
              CarouselSlider(
                options: CarouselOptions(height: 100.0),
                items: [
                  MeditationIcon(icon: Icons.local_fire_department_rounded, label: "Fireplace"),
                  MeditationIcon(icon: Icons.water, label: "Ocean"),
                  MeditationIcon(icon: Icons.air, label: "Wind"),
                ].map((icon) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeditationTimer(meditationType: icon.label),
                            ),
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: teal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon.icon, size: 50, color: black),
                              Text(icon.label, style: TextStyle(color: black)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MeditationIcon {
  final IconData icon;
  final String label;

  MeditationIcon({required this.icon, required this.label});
}