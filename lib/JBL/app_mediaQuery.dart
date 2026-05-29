import 'package:flutter/material.dart';

class AppMediaQuery {
  final BuildContext context;

  AppMediaQuery(this.context);

  double w(double percent) =>
      MediaQuery.of(context).size.width * percent / 100;

  double h(double percent) =>
      MediaQuery.of(context).size.height * percent / 100;
}
