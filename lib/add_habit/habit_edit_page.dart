import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timefly/add_habit/Icon_color.dart';
import 'package:timefly/app_theme.dart';
import 'package:timefly/blocs/habit/habit_bloc.dart';
import 'package:timefly/blocs/habit/habit_event.dart';
import 'package:timefly/models/complete_time.dart';
import 'package:timefly/models/habit.dart';
import 'package:timefly/models/habit_color.dart';
import 'package:timefly/models/habit_icon.dart';
import 'package:timefly/models/habit_peroid.dart';
import 'package:timefly/utils/uuid.dart';
import 'package:timefly/widget/custom_edit_field.dart';

class HabitEditPage extends StatefulWidget {
  @override
  _HabitEditPageState createState() => _HabitEditPageState();
}

class _HabitEditPageState extends State<HabitEditPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  String _habitIcon;
  Color _habitColor;

  List<CompleteTime> completeTimes = [];
  List<CompleteDay> completeDays = [];

  List<HabitPeroid> habitPeroids = [];

  String _name = '';
  String _mark = '';

  AnimationController fontAnimationController;
  AnimationController bottonAnimationController;

  @override
  void initState() {
    List<HabitIcon> icons = HabitIcon.getIcons();
    _habitIcon = icons[Random().nextInt(icons.length - 1)].icon;

    List<HabitColor> colors = HabitColor.getBackgroundColors();
    _habitColor = colors[Random().nextInt(colors.length - 1)].color;

    completeTimes = CompleteTime.getCompleteTimes();
    completeDays = CompleteDay.getCompleteDays();

    habitPeroids = HabitPeroid.getHabitPeroids();

    fontAnimationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    fontAnimationController.forward(from: 0.5);

    bottonAnimationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration(milliseconds: 500), () {
      bottonAnimationController.forward();
    });

    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        bool keybordShow = MediaQuery.of(context).viewInsets.bottom > 0;
        if (keybordShow) {
          bottonAnimationController.reverse();
        } else {
          bottonAnimationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    fontAnimationController.dispose();
    bottonAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.appTheme.cardBackgroundColor(),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            children: [
              barView(),
              Expanded(
                child: Container(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 20),
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: _habitColor.withOpacity(0.3),
                                    offset: Offset(0, 7),
                                    blurRadius: 10)
                              ], shape: BoxShape.circle, color: _habitColor),
                              width: 60,
                              height: 60,
                              child: Image.asset(_habitIcon),
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              height: 60,
                              width: 30,
                              child: InkWell(
                                onTap: () async {
                                  Map<String, dynamic> result =
                                      await showDialog(
                                          context: context,
                                          barrierColor: Colors.black87,
                                          builder: (context) {
                                            return IconAndColorPage(
                                                selectedIcon: _habitIcon,
                                                selectedColor: _habitColor);
                                          });
                                  if (result != null) {
                                    setState(() {
                                      _habitIcon = result['icon'];
                                      _habitColor = result['color'];
                                    });
                                  }
                                },
                                child: SvgPicture.asset(
                                  'assets/images/bianji.svg',
                                  color: Colors.black,
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      CustomEditField(
                        maxLines: 1,
                        maxLength: 10,
                        initValue: '',
                        hintText: '名字 ...',
                        hintTextStyle: AppTheme.appTheme.textStyle(
                            textColor: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        textStyle: AppTheme.appTheme.textStyle(
                            textColor: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        containerDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: AppTheme.appTheme
                                .containerBackgroundColor()
                                .withOpacity(0.6)),
                        numDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(3, 3),
                                  blurRadius: 6)
                            ]),
                        numTextStyle: TextStyle(
                            color: Color(0xFF5C5EDD),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        onValueChanged: (value) {
                          _name = value;
                          print('change');
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 18, top: 8),
                        child: Text(
                          '时段',
                          style: AppTheme.appTheme.textStyle(
                              textColor: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ),
                      timeView(),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 18),
                        child: Text(
                          '周期',
                          style: AppTheme.appTheme.textStyle(
                              textColor: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ),
                      periodChooseView(),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 18),
                        child: Text(
                          '每${HabitPeroid.getPeroid(currentPeroid)}完成次数',
                          style: AppTheme.appTheme.textStyle(
                              textColor: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ),
                      completeCountView(),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 18, top: 8),
                        child: Text(
                          '提醒时间',
                          style: AppTheme.appTheme.textStyle(
                              textColor: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ),
                      timeReminderView(),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(left: 18, top: 16),
                        child: Text(
                          '写一句话鼓励自己',
                          style: AppTheme.appTheme.textStyle(
                              textColor: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        ),
                      ),
                      CustomEditField(
                        maxLength: 50,
                        initValue: _mark,
                        hintText: '千里之行，始于足下 ...',
                        hintTextStyle: AppTheme.appTheme.textStyle(
                            textColor: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                        textStyle: AppTheme.appTheme.textStyle(
                            textColor: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 16),
                        minHeight: 100,
                        containerDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: AppTheme.appTheme
                                .containerBackgroundColor()
                                .withOpacity(0.6)),
                        numDecoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(3, 3),
                                  blurRadius: 6)
                            ]),
                        numTextStyle: TextStyle(
                            color: Color(0xFF5C5EDD),
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        onValueChanged: (value) {
                          _mark = value;
                        },
                      ),
                      SizedBox(
                        height: 82,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              if (_name.length == 0) {
                Fluttertoast.showToast(
                    msg: '请输入名字',
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Color(0xFF738AE6),
                    gravity: ToastGravity.CENTER);
                return;
              }
              Habit habit = Habit(
                  id: Uuid().generateV4(),
                  name: _name,
                  iconPath: _habitIcon,
                  mainColor: _habitColor.value,
                  mark: _mark,
                  period: currentPeroid,
                  doNum: getCurrentCount(),
                  completeTime: completeTimes
                      .where((element) => element.isSelect)
                      .first
                      .time,
                  completeDays: currentPeroid == 1
                      ? completeDays
                          .where((element) => element.isSelect)
                          .map((e) => e.day)
                          .toList()
                      : [],
                  remindTimes: remindTime == null
                      ? []
                      : [
                          '${_twoDigits(remindTime.hour)}:${_twoDigits(remindTime.minute)}'
                        ],
                  createTime: DateTime.now().millisecondsSinceEpoch,
                  completed: false,
                  records: []);
              BlocProvider.of<HabitsBloc>(context).add(HabitsAdd(habit));
              Navigator.of(context).pop(habit);
            },
            child: ScaleTransition(
              scale: CurvedAnimation(
                  parent: bottonAnimationController,
                  curve: Curves.fastOutSlowIn),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(bottom: 32),
                height: 55,
                width: 220,
                decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Color(0xFF738AE6).withOpacity(0.5),
                          offset: const Offset(5.1, 4.0),
                          blurRadius: 16.0),
                    ],
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFF738AE6),
                        Color(0xFF5C5EDD),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(35))),
                child: Text(
                  '保存',
                  style: AppTheme.appTheme.textStyle(
                      textColor: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget barView() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      height: 60 + MediaQuery.of(context).padding.top,
      child: Row(
        children: [
          Expanded(
              child: Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: SvgPicture.asset(
                'assets/images/fanhui.svg',
                color: Colors.black,
                width: 30,
                height: 30,
              ),
            ),
          )),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '新建习惯',
                style: AppTheme.appTheme.textStyle(
                    textColor: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget timeView() {
    return Container(
      margin: EdgeInsets.only(top: 6),
      height: 48,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
        itemBuilder: (context, index) {
          CompleteTime completeTime = completeTimes[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                completeTimes.forEach((element) {
                  element.isSelect = false;
                });
                completeTime.isSelect = true;
              });
            },
            child: AnimatedContainer(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 16),
              width: 68,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Color(0xFF5C5EDD), width: 1.5),
                  color:
                      completeTime.isSelect ? Color(0xFF5C5EDD) : Colors.white),
              child: Text(
                CompleteTime.getTime(completeTime.time),
                style: AppTheme.appTheme.textStyle(
                    textColor: completeTime.isSelect
                        ? Colors.white
                        : Color(0xFF5C5EDD),
                    fontWeight: FontWeight.normal,
                    fontSize: 15),
              ),
              duration: Duration(milliseconds: 300),
            ),
          );
        },
        itemCount: completeTimes.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  int currentPeroid = HabitPeroid.day;

  Widget periodChooseView() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 6),
          height: 48,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            itemBuilder: (context, index) {
              HabitPeroid habitPeroid = habitPeroids[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    habitPeroids.forEach((element) {
                      element.isSelect = false;
                    });
                    habitPeroid.isSelect = true;
                    currentPeroid = habitPeroid.peroid;
                  });
                },
                child: AnimatedContainer(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 16),
                  width: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    border: Border.all(color: Color(0xFF5C5EDD), width: 1.5),
                    color:
                        habitPeroid.isSelect ? Color(0xFF5C5EDD) : Colors.white,
                  ),
                  child: Text(
                    HabitPeroid.getPeroid(habitPeroid.peroid),
                    style: AppTheme.appTheme.textStyle(
                        textColor: habitPeroid.isSelect
                            ? Colors.white
                            : Color(0xFF5C5EDD),
                        fontWeight: FontWeight.normal,
                        fontSize: 15),
                  ),
                  duration: Duration(milliseconds: 300),
                ),
              );
            },
            itemCount: habitPeroids.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
        currentPeroid == HabitPeroid.week
            ? Container(
                height: 58,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  itemBuilder: (context, index) {
                    CompleteDay completeDay = completeDays[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          completeDay.isSelect = !completeDay.isSelect;
                        });
                      },
                      child: AnimatedContainer(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 16),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Color(0xFF5C5EDD), width: 1.5),
                            color: completeDay.isSelect
                                ? Color(0xFF5C5EDD)
                                : Colors.white),
                        child: Text(
                          CompleteDay.getDay(completeDay.day),
                          style: AppTheme.appTheme.textStyle(
                              textColor: completeDay.isSelect
                                  ? Colors.white
                                  : Color(0xFF5C5EDD),
                              fontWeight: FontWeight.normal,
                              fontSize: 13),
                        ),
                        duration: Duration(milliseconds: 300),
                      ),
                    );
                  },
                  itemCount: completeDays.length,
                  scrollDirection: Axis.horizontal,
                ),
              )
            : SizedBox()
      ],
    );
  }

  int countByDay = 1;
  int countByWeek = 7;
  int countByMonth = 15;

  int getCurrentCount() {
    int count = 0;
    switch (currentPeroid) {
      case 0:
        count = countByDay;
        break;
      case 1:
        count = countByWeek;
        break;
      case 2:
        count = countByMonth;
        break;
    }
    return count;
  }

  void setCurrentCount(int count) {
    switch (currentPeroid) {
      case 0:
        countByDay = count;
        break;
      case 1:
        countByWeek = count;
        break;
      case 2:
        countByMonth = count;
        break;
    }
  }

  Widget completeCountView() {
    return Container(
      margin: EdgeInsets.only(left: 32, top: 8),
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (getCurrentCount() == 1) {
                return;
              }
              setState(() {
                setCurrentCount(getCurrentCount() - 1);
                fontAnimationController.forward(from: 0.5);
              });
            },
            child: SvgPicture.asset(
              'assets/images/jian.svg',
              color: Colors.black,
              width: 32,
              height: 32,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 8, right: 8),
            width: 44,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                shape: BoxShape.rectangle,
                color: Color(0xFF5C5EDD)),
            child: AnimatedBuilder(
              builder: (context, child) {
                return Text(
                  '${getCurrentCount()}',
                  style: AppTheme.appTheme.textStyle(
                      textColor: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 23 * fontAnimationController.value),
                );
              },
              animation: CurvedAnimation(
                  parent: fontAnimationController, curve: Curves.elasticInOut),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                setCurrentCount(getCurrentCount() + 1);
                fontAnimationController.forward(from: 0.5);
              });
            },
            child: SvgPicture.asset(
              'assets/images/jia.svg',
              color: Colors.black,
              width: 32,
              height: 32,
            ),
          ),
        ],
      ),
    );
  }

  DateTime remindTime;

  Widget timeReminderView() {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 8),
      height: 40,
      child: Row(
        children: [
          remindTime == null
              ? SizedBox()
              : Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 16),
                  width: 68,
                  height: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      color: Color(0xFF5C5EDD)),
                  child: Text(
                    '${_twoDigits(remindTime.hour)}:${_twoDigits(remindTime.minute)}',
                    style: AppTheme.appTheme.textStyle(
                        textColor: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                ),
          GestureDetector(
            onTap: () async {
              DateTime dateTime = await showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    DateTime currentTime = DateTime.now();
                    return Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                AppTheme.appTheme.addHabitSheetBgLight(),
                                AppTheme.appTheme.addHabitSheetBgDark()
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20))),
                        height: 318,
                        child: Column(
                          children: [
                            Container(
                              height: 230,
                              child: CupertinoTheme(
                                data: CupertinoThemeData(
                                    textTheme: CupertinoTextThemeData(
                                        dateTimePickerTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18))),
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.time,
                                  onDateTimeChanged: (time) {
                                    currentTime = time;
                                  },
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16, bottom: 32),
                              height: 40,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(currentTime);
                                },
                                child: SvgPicture.asset(
                                  'assets/images/duigou.svg',
                                  width: 35,
                                  height: 35,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ));
                  });
              if (dateTime == null) {
                return;
              }
              setState(() {
                remindTime = dateTime;
              });
            },
            child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 8),
                child: SvgPicture.asset(
                  'assets/images/jia.svg',
                  color: Colors.black,
                  width: 32,
                  height: 32,
                )),
          )
        ],
      ),
    );
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
