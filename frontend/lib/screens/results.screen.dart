import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:frontend/widgets/results_step_1.widget.dart';
import 'package:frontend/widgets/results_step_2.widget.dart';
import 'package:frontend/widgets/results_step_3.widget.dart';
import 'package:frontend/widgets/results_step_4.widget.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';

class ResultsScreen extends StatefulWidget {
  static const routeName = '/results';
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  CarouselController buttonCarouselController = CarouselController();
  int _pageIndex = 0;

  String get _pageTitle {
    switch (_pageIndex) {
      case 0:
        return 'Select Webpage';
      case 1:
        return 'Select Date Range';
      case 2:
        return 'Select Archives to compare';
      default:
        return 'Crawler Results';
    }
  }

  void _nextPage() {
    buttonCarouselController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  void _previousPage() {
    buttonCarouselController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  void _goToPage(int page) {
    buttonCarouselController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;

    return MainScaffold(
      title: _pageTitle,
      childWidget: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            CarouselSlider(
              items: [
                ResultsStep1(
                  pageIndex: _pageIndex,
                  nextPage: _nextPage,
                ),
                ResultsStep2(
                  pageIndex: _pageIndex,
                  nextPage: _nextPage,
                  previousPage: _previousPage,
                ),
                ResultsStep3(
                  pageIndex: _pageIndex,
                  nextPage: _nextPage,
                  previousPage: _previousPage,
                ),
                ResultsStep4(
                  pageIndex: _pageIndex,
                  previousPage: _previousPage,
                )
              ],
              carouselController: buttonCarouselController,
              options: CarouselOptions(
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  autoPlay: false,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.95,
                  height: deviceHeight * 0.82,
                  aspectRatio: 16 / 9,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _pageIndex = index;
                    });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
