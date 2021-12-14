
import 'package:flutter/material.dart';

import 'widgets/custom_spinner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Align(
          alignment: Alignment.center,
          child: CustomLoadingWidget(),
        ),
      ),
    );
  }
}
