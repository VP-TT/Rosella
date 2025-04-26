import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PCOSExerciseCompanion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCOS Exercise Companion 🌸',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        primarySwatch: Colors.deepPurple,
      ),
      home: ExerciseHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExerciseHomePage extends StatefulWidget {
  @override
  _ExerciseHomePageState createState() => _ExerciseHomePageState();
}

class _ExerciseHomePageState extends State<ExerciseHomePage> {
  String selectedCategory = 'All';

  final Map<String, List<Map<String, String>>> exerciseData = {
    "Relaxation": [
      {
        "name": "PCOS Yoga for Hormonal Balance",
        "youtube": "https://www.youtube.com/watch?v=1JzWXkGatbA"
      },
      {
        "name": "Guided Meditation for PCOS",
        "youtube": "https://www.youtube.com/watch?v=W19PdslW7iw"
      },
      {
        "name": "Slow Yoga Flow for Stress Relief",
        "youtube": "https://www.youtube.com/watch?v=1vuUeYzQ7xQ"
      },
      {
        "name": "Evening Wind Down for PCOS",
        "youtube": "https://www.youtube.com/watch?v=6QmAOlRe9pM"
      },
      {
        "name": "Bedtime Stretch for Hormonal Health",
        "youtube": "https://www.youtube.com/watch?v=wD8QTQp9hhM"
      },
      {
        "name": "Morning Calm Routine",
        "youtube": "https://www.youtube.com/watch?v=9z6heqOjqRM"
      },
      {
        "name": "5-Minute Breathing for PCOS",
        "youtube": "https://www.youtube.com/watch?v=IebtjULMw1g"
      },
      {
        "name": "Yin Yoga for Relaxation",
        "youtube": "https://www.youtube.com/watch?v=jOfshreyu4w"
      },
      {
        "name": "Mindful Movement & Meditation",
        "youtube": "https://www.youtube.com/watch?v=92m7V1BRnko"
      },
      {
        "name": "Gentle Flow for Anxiety",
        "youtube": "https://www.youtube.com/watch?v=4pLUleLdwY4"
      },
    ],
    "Get Fit (Weight Loss)": [
      {
        "name": "Full Body PCOS Workout (No Equipment)",
        "youtube": "https://www.youtube.com/watch?v=FkDWr-Pp308"
      },
      {
        "name": "Fat-Burning PCOS HIIT",
        "youtube": "https://www.youtube.com/watch?v=ml6cT4AZdqI"
      },
      {
        "name": "Beginner HIIT for PCOS",
        "youtube": "https://www.youtube.com/watch?v=wU4vccVCvk8"
      },
      {
        "name": "Cardio for PCOS Management",
        "youtube": "https://www.youtube.com/watch?v=l0X3HFylFY8"
      },
      {
        "name": "Home Workout for PCOS",
        "youtube": "https://www.youtube.com/watch?v=aW1g2TRS98g"
      },
      {
        "name": "Fat Loss Dance Workout",
        "youtube": "https://www.youtube.com/watch?v=dV9t4I_0GDA"
      },
      {
        "name": "Bodyweight Burnout for PCOS",
        "youtube": "https://www.youtube.com/watch?v=jB-wuGAT0fY"
      },
      {
        "name": "15-Min Weight Loss Routine",
        "youtube": "https://www.youtube.com/watch?v=X3q5e1pV4pc"
      },
      {
        "name": "No Jump Workout (PCOS Friendly)",
        "youtube": "https://www.youtube.com/watch?v=VHyGqsPOUHs"
      },
      {
        "name": "Low Impact Cardio for PCOS",
        "youtube": "https://www.youtube.com/watch?v=R0mMyV5OtcM"
      },
    ]
  };

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...exerciseData.keys];
    final categoriesToShow =
    selectedCategory == 'All' ? exerciseData.keys : [selectedCategory];

    return Scaffold(
        backgroundColor: const Color(0xFFFCECF1),
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      '🌸 PCOS Exercise Companion 🌸',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: selectedCategory,
                    icon: Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: categoriesToShow.map((category) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A148C),
                              ),
                            ),
                            Divider(color: Color(0xFFB39DDB), thickness: 2),
                            ...exerciseData[category]!.map((ex) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: GestureDetector(
                                onTap: () async {
                                  final url = Uri.parse(ex['youtube']!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    ex['name']!,
                                    style: TextStyle(
                                      color: Color(0xFF1A237E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
                ),
                    );
            }
}