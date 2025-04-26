import 'package:flutter/material.dart';
import '../widgets/question_field.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  State<HomeScreen1> createState() => _HomeScreenState1();
}

class _HomeScreenState1 extends State<HomeScreen1> {
  final _formKey = GlobalKey<FormState>();

  // Form state variables
  String skinDarkening = 'N';
  String hairGrowth = 'N';
  String weightGain = 'N';
  String cycle = 'R';
  String fastFood = 'N';
  String pimples = 'N';
  String hairLoss = 'N';
  String regExercise = 'N';
  String age = '';
  String weight = '';

  void handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final result = await ApiService.predictPCOS({
        'Skin_darkening': skinDarkening,
        'Hair_growth': hairGrowth,
        'Weight_gain': weightGain,
        'Cycle': cycle,
        'Fast_food': fastFood,
        'Pimples': pimples,
        'Hair_loss': hairLoss,
        'Reg_Exercise': regExercise,
        'Age': age,
        'Weight': weight,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(prediction: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PCOS Predictor'),
        backgroundColor: const Color(0xFFE75A7C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              QuestionField(
                label: 'Skin Darkening',
                value: skinDarkening,
                onChanged: (val) => setState(() => skinDarkening = val),
              ),
              QuestionField(
                label: 'Hair Growth',
                value: hairGrowth,
                onChanged: (val) => setState(() => hairGrowth = val),
              ),
              QuestionField(
                label: 'Weight Gain',
                value: weightGain,
                onChanged: (val) => setState(() => weightGain = val),
              ),
              QuestionField(
                label: 'Cycle (R/I)',
                options: const ['R', 'I'],
                value: cycle,
                onChanged: (val) => setState(() => cycle = val),
              ),
              QuestionField(
                label: 'Fast Food',
                value: fastFood,
                onChanged: (val) => setState(() => fastFood = val),
              ),
              QuestionField(
                label: 'Pimples',
                value: pimples,
                onChanged: (val) => setState(() => pimples = val),
              ),
              QuestionField(
                label: 'Hair Loss',
                value: hairLoss,
                onChanged: (val) => setState(() => hairLoss = val),
              ),
              QuestionField(
                label: 'Regular Exercise',
                value: regExercise,
                onChanged: (val) => setState(() => regExercise = val),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age (yrs)'),
                keyboardType: TextInputType.number,
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
                onChanged: (val) => age = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (Kg)'),
                keyboardType: TextInputType.number,
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
                onChanged: (val) => weight = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text('Predict'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
