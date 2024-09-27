import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';

class FlashHelper {
  static Future<Future<T?>> toast<T>(BuildContext context, String message) async {
    return showFlash<T>(
        context: context,
        duration: Duration(milliseconds: 2000),
        builder: (context, controller) {
          return FlashBar(
              margin: EdgeInsets.only(left: 24, right: 24),
              position: FlashPosition.top,
              backgroundColor: Colors.transparent,
              controller: controller,
              content: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16),
                height: 80,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    gradient: AppTheme.appTheme.containerGradient(),
                    boxShadow: AppTheme.appTheme.coloredBoxShadow()),
                child: Text(
                  message,
                  style: AppTheme.appTheme.headline1(
                      textColor: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 16),
                ),
              ));
        });
  }
}
