import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  void initState() {
    _updateAppbar();
    super.initState();
  }

  void _updateAppbar() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    return flutter_material.Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: jumlah.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 6,
                                offset: Offset(0, 6),
                              ),
                            ],
                            color: selectedIndex == index ? pinkish : white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                12.0,
                              ),
                            ),
                          ),
                          child: Center(
                              child: Text(
                                "${jumlah[index]}",
                                style: GoogleFonts.montserrat(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500,
                                  color: selectedIndex == index ? white : black,
                                ),
                              )),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                CarouselSlider.builder(
                  itemCount: quotes[selectedIndex].length,
                  itemBuilder: (BuildContext context, int index, int realIdx) {
                    return Container(  // Remove the Expanded widget here
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: teal,
                            blurRadius: 6,
                            offset: Offset(0, 6),
                          ),
                        ],
                        color: index.isEven ? blueish: pinkish,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.format_quote, color: Colors.white),
                            Text(
                              quotes[selectedIndex][index],
                              style: GoogleFonts.montserrat(
                                letterSpacing: 1,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 400.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                    const Duration(milliseconds: 800),
                    viewportFraction: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const white = flutter_material.Colors.white;

const cream = flutter_material.Color.fromRGBO(250, 210, 200, 1);
const yellow = flutter_material.Color.fromRGBO(251, 241, 163, 1);
const teal = flutter_material.Color.fromRGBO(179, 221, 198, 1);
const black = flutter_material.Color.fromRGBO(44, 44, 44, 1);
const pinkish =flutter_material.Color.fromRGBO(244,159,188,1);
const blueish = flutter_material.Color.fromRGBO(166,217,247,1);

final font = GoogleFonts.montserrat(
  letterSpacing: 1,
  fontWeight: FontWeight.w500,
);

List jumlah = ["Mood Swing", "Stress", "Depression", "Healing", "Relax"];

List<List<String>> quotes = [
  [
    "Life is a series of natural and spontaneous changes. Don't resist them; that only creates sorrow. Let reality be reality. Let things flow naturally forward in whatever way they like. - Lao Tzu",
    "The only way to make sense out of change is to plunge into it, move with it, and join the dance. - Alan Watts",
    "Change is the law of life. And those who look only to the past or present are certain to miss the future. - John F. Kennedy",
    "To improve is to change; to be perfect is to change often. - Winston Churchill",
  ],
  [
    "Do not anticipate trouble, or worry about what may never happen. Keep in the sunlight. - Benjamin Franklin",
    "It's not the load that breaks you down, it's the way you carry it. - Lou Holtz",
    "The greatest weapon against stress is our ability to choose one thought over another. - William James",
    "Much of the stress that people feel doesn't come from having too much to do. It comes from not finishing what they've started. - David Allen",
  ],
  [
    "You are not alone. You are seen. I am with you. You are not alone. - Shonda Rhimes",
    "Start by doing what’s necessary; then do what’s possible; and suddenly you are doing the impossible. - Francis of Assisi",
    "Every man has his secret sorrows which the world knows not; and often times we call a man cold when he is only sad. - Henry Wadsworth Longfellow",
    "There is hope, even when your brain tells you there isn’t. - John Green",
  ],
  [
    "The wound is the place where the Light enters you. - Rumi",
    "Healing takes time, and asking for help is a courageous step. - Mariska Hargitay",
    "Healing yourself is connected with healing others. - Yoko Ono",
    "To heal is to touch with love that which we previously touched with fear. - Stephen Levine",
  ],
  [
    "Calm mind brings inner strength and self-confidence, so that's very important for good health. - Dalai Lama",
    "Your calm mind is the ultimate weapon against your challenges. So relax. - Bryant McGill",
    "Peace begins with a smile. - Mother Teresa",
    "The more tranquil a man becomes, the greater is his success, his influence, his power for good. Calmness of mind is one of the beautiful jewels of wisdom. - James Allen",
  ],
];
