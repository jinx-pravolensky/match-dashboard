import 'package:flutter/material.dart';
import 'package:ns3_project/components/size_config.dart';
import 'package:ns3_project/components/text_format.dart';
import 'package:ns3_project/auth/components/component_form_login.dart'
    show ComponentFormLogin;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static String routeName = "/login-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(primary: true, body: LoginScreenBody());
  }
}

class LoginScreenBody extends StatefulWidget {
  const LoginScreenBody({super.key});

  @override
  State<LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<LoginScreenBody> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        children: <Widget>[
          // const SizedBox(height: 5),
          // Container(
          //   margin: const EdgeInsets.symmetric(horizontal: 20),
          //   child: HeadersApp(),
          // ),
          // const SizedBox(height: 60),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 5),
            child: const Text(
              'Sign In',
              textAlign: TextAlign.center,
              style: text26PrimaryBold,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 40),
            child: const Text(
              'Halo 👋, Selamat Datang di NS3',
              textAlign: TextAlign.center,
              style: text16PrimaryBold,
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/logo/Logo-app.png',
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 15, bottom: 15),
            child: const Text(
              'Silahkan Masuk Akun Anda',
              textAlign: TextAlign.center,
              style: text14PrimaryBold,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 25, right: 25),
            child: ComponentFormLogin(),
          ),
        ],
      ),
    );
  }
}
