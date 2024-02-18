import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:dashboard/common/constants.dart';
import 'package:dashboard/controllers/BLoC/internet_cubit.dart';
import 'package:dashboard/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await getInitialUri().then((link) {
  //   initialLink = link;
  //   print('web view initial link: $initialLink');
  //   // return null;
  // });
  //Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InternetCubit()..checkInternetAvailability(),
      child: BlocConsumer<InternetCubit, InternetStates>(
        listener: (context, state) {
          
        },
        builder: (context, state) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(useMaterial3: true),
              home: AnimatedSplashScreen(
                  duration: 1500,
                  splash: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Image(image: AssetImage(splashLogoPath)),
                  ),
                  nextScreen: const WebViewApp()));
        },
      ),
    );
  }
}
