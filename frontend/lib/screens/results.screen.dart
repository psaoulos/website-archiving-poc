import 'package:flutter/material.dart';
import 'package:frontend/models/crawler_address.model.dart';
import 'package:frontend/models/results_get_all_addresses_response.dart';
import 'package:frontend/services/results.services.dart';
import 'package:frontend/widgets/results_step_1.widget.dart';
import 'package:frontend/widgets/results_step_2.widget.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:frontend/widgets/main_scaffold.widget.dart';

class ResultsScreen extends StatefulWidget {
  static const routeName = '/results';
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  CarouselController buttonCarouselController = CarouselController();
  late DateTime startDate;
  late DateTime endDate;
  AllAddressesResponse? allAddresses;
  CrawlerAddress? selectedAddress;
  int _pageIndex = 0;

  String get _pageTitle {
    switch (_pageIndex) {
      case 0:
        return 'Select Webpage';
      case 1:
        return 'Select Date Range';
      case 2:
        return 'Select Archives';
      default:
        return 'Crawler Results';
    }
  }

  void getAllAddresses() {
    ResultsApiService.getAllAddresses().then((value) {
      if (value.success) {
        setState(() {
          allAddresses = value;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                'Could not fetch all addresses from Backend, please check Backend logs.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red),
        );
      }
    });
  }

  @override
  void initState() {
    getAllAddresses();
    super.initState();
  }

  void _onDateSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange &&
        args.value.startDate != null &&
        args.value.endDate != null) {
      setState(() {
        startDate = args.value.startDate;
        endDate = args.value.endDate;
      });
    }
  }

  void nextPage() {
    buttonCarouselController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  void previousPage() {
    buttonCarouselController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  void selectAddress(CrawlerAddress address) {
    setState(() {
      selectedAddress = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData mode = Theme.of(context);
    bool isDarkMode = mode.brightness == Brightness.dark;
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return MainScaffold(
      title: _pageTitle,
      childWidget: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            CarouselSlider(
              items: [
                allAddresses != null
                    ? ResultsStep1(
                        width: deviceWidth,
                        height: deviceHeight * 0.7,
                        nextPage: nextPage,
                        allAddresses:
                            allAddresses?.addresses as List<CrawlerAddress>,
                        selectAddress: selectAddress,
                      )
                    : Container(),
                ResultsStep2(
                  width: deviceWidth * 0.95,
                  height: deviceHeight * 0.95,
                  onDateSelectionChanged: _onDateSelectionChanged,
                  nextPage: nextPage,
                  previousPage: previousPage,
                ),
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
