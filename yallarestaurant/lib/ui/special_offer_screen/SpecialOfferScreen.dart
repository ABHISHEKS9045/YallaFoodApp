import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/SpecialDiscountModel.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';

class SpecialOfferScreen extends StatefulWidget {
  const SpecialOfferScreen({Key? key}) : super(key: key);

  @override
  State<SpecialOfferScreen> createState() => _SpecialOfferScreenState();
}

class _SpecialOfferScreenState extends State<SpecialOfferScreen> {
  List<SpecialDiscountModel> specialModel = [];

  final description = TextEditingController();

  List<SpecialDiscountModel> specialDiscount = [];

  @override
  void initState() {
    getVendor();
    super.initState();
  }

  VendorModel? vendorModel;

  getVendor() async {
    vendorModel = await FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID);

    setState(() {
      if (vendorModel!.specialDiscount!.isEmpty) {
        specialDiscount = [
          SpecialDiscountModel(day: 'Monday', timeslot: []),
          SpecialDiscountModel(day: 'Tuesday', timeslot: []),
          SpecialDiscountModel(day: 'Wednesday', timeslot: []),
          SpecialDiscountModel(day: 'Thursday', timeslot: []),
          SpecialDiscountModel(day: 'Friday', timeslot: []),
          SpecialDiscountModel(day: 'Saturday', timeslot: []),
          SpecialDiscountModel(day: 'Sunday', timeslot: [])
        ];
      } else {
        specialDiscount = vendorModel!.specialDiscount!;
      }
      isSpecialSwitched = vendorModel!.specialDiscountEnable;
    });
  }

  List<String> discountType = ['Dine-In Discount', 'Delivery Discount'];
  List<String> type = [symbol, '%'];
  bool isSpecialSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(
                    "Special Discount amount",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
                  Switch(
                    value: isSpecialSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSpecialSwitched = value;
                      });
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ],
              ),
              Visibility(
                visible: isSpecialSwitched,
                child: ListView.builder(
                  itemCount: specialDiscount.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              specialDiscount[index].day.toString(),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  specialDiscount[index].timeslot!.add(Timeslot(from: '', to: '', discount: '', type: ''));
                                });
                              },
                              child: Icon(Icons.add_circle_sharp, color: Color(COLOR_PRIMARY), size: 36),
                            )
                          ],
                        ),
                        ListView.builder(
                          itemCount: specialDiscount[index].timeslot!.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index1) {
                            return Form(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            child: InkWell(
                                          onTap: () async {
                                            TimeOfDay? startTime = await _selectTime();
                                            setState(() {
                                              specialDiscount[index].timeslot![index1].from =
                                                  DateFormat('HH:mm').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startTime!.hour, startTime.minute));
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              border: Border.all(color: Color(0XFFB1BCCA)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  specialDiscount[index].timeslot![index1].from!.isEmpty ? 'Start Time' : specialDiscount[index].timeslot![index1].from.toString(),
                                                  style: TextStyle(
                                                      color: isDarkMode(context)
                                                          ? Color(0xFFFFFFFF)
                                                          : specialDiscount[index].timeslot![index1].from!.isEmpty
                                                              ? Colors.grey
                                                              : Colors.black,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                            child: InkWell(
                                          onTap: () async {
                                            TimeOfDay? startTime = await _selectTime();
                                            if (startTime!.format(context).toString() == "12:00 AM") {
                                              specialDiscount[index].timeslot![index1].to = DateFormat('HH:mm').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59));
                                            } else {
                                              setState(() {
                                                specialDiscount[index].timeslot![index1].to =
                                                    DateFormat('HH:mm').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, startTime.hour, startTime.minute));
                                              });
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              border: Border.all(color: Color(0XFFB1BCCA)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  specialDiscount[index].timeslot![index1].to!.isEmpty ? 'End Time' : specialDiscount[index].timeslot![index1].to.toString(),
                                                  style: TextStyle(
                                                      color: isDarkMode(context)
                                                          ? Color(0xFFFFFFFF)
                                                          : specialDiscount[index].timeslot![index1].to!.isEmpty
                                                              ? Colors.grey
                                                              : Colors.black,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                              textAlignVertical: TextAlignVertical.center,
                                              textInputAction: TextInputAction.next,
                                              initialValue: specialDiscount[index].timeslot![index1].discount,
                                              onChanged: (text) {
                                                setState(() {
                                                  specialDiscount[index].timeslot![index1].discount = text;
                                                });
                                              },
                                              cursorColor: Color(COLOR_PRIMARY),
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                hintText: 'Discount',
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(COLOR_PRIMARY)),
                                                ),
                                                hintStyle: TextStyle(
                                                  color: isDarkMode(context)
                                                      ? Color(0xFFFFFFFF)
                                                      : specialDiscount[index].timeslot![index1].to!.isEmpty
                                                          ? Colors.grey
                                                          : Colors.black,
                                                ),
                                                suffix: Text(specialDiscount[index].timeslot![index1].type == "amount" ? symbol : "%"),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0XFFB1BCCA)),
                                                  // borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              specialDiscount[index].timeslot!.removeAt(index1);
                                            });
                                          },
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              border: Border.all(color: Color(0XFFB1BCCA)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: DropdownButton<String>(
                                                underline: SizedBox(),
                                                value: specialDiscount[index].timeslot![index1].discountType == "dinein" ? "Dine-In Discount" : "Delivery Discount",
                                                onChanged: (newValue) {
                                                  if (newValue == "Dine-In Discount") {
                                                    setState(() {
                                                      specialDiscount[index].timeslot![index1].discountType = "dinein";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      specialDiscount[index].timeslot![index1].discountType = "delivery";
                                                    });
                                                  }
                                                  print(newValue);
                                                  print(specialDiscount[index].timeslot![index1].discountType);
                                                },
                                                style: TextStyle(
                                                  color: isDarkMode(context)
                                                      ? Color(0xFFFFFFFF)
                                                      : specialDiscount[index].timeslot![index1].to!.isEmpty
                                                          ? Colors.grey
                                                          : Colors.black,
                                                ),
                                                items: discountType.map((String user) {
                                                  return DropdownMenuItem<String>(
                                                    value: user,
                                                    child: new Text(
                                                      user,
                                                      style: new TextStyle(
                                                        color: isDarkMode(context)
                                                            ? Color(0xFFFFFFFF)
                                                            : specialDiscount[index].timeslot![index1].to!.isEmpty
                                                                ? Colors.grey
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                              border: Border.all(color: Color(0XFFB1BCCA)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: DropdownButton<String>(
                                                underline: SizedBox(),
                                                value: specialDiscount[index].timeslot![index1].type == "amount" ? symbol : "%",
                                                onChanged: (newValue) {
                                                  if (newValue == symbol) {
                                                    setState(() {
                                                      specialDiscount[index].timeslot![index1].type = "amount";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      specialDiscount[index].timeslot![index1].type = "percentage";
                                                    });
                                                  }
                                                  print(newValue);
                                                  print(specialDiscount[index].timeslot![index1].type);
                                                },
                                                style: TextStyle(
                                                  color: isDarkMode(context)
                                                      ? Color(0xFFFFFFFF)
                                                      : specialDiscount[index].timeslot![index1].to!.isEmpty
                                                          ? Colors.grey
                                                          : Colors.black,
                                                ),
                                                items: type.map((String user) {
                                                  return DropdownMenuItem<String>(
                                                    value: user,
                                                    child: new Text(
                                                      user,
                                                      style: new TextStyle(
                                                        color: isDarkMode(context)
                                                            ? Color(0xFFFFFFFF)
                                                            : specialDiscount[index].timeslot![index1].to!.isEmpty
                                                                ? Colors.grey
                                                                : Colors.black,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.only(top: 12, bottom: 12), backgroundColor: Color(COLOR_PRIMARY),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                color: Color(COLOR_PRIMARY),
              ),
            ),
          ),
          onPressed: () {
            if (MyAppState.currentUser!.vendorID.isEmpty) {
              final snackBar = SnackBar(
                content: const Text('Please add a restaurant first'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
              bool isEmptyField = false;
              specialDiscount.forEach((element) {
                var emptyList = element.timeslot!.where((element) => element.discount!.isEmpty || element.from!.isEmpty || element.to!.isEmpty);
                if (element.timeslot!.isNotEmpty && emptyList.isNotEmpty && !isEmptyField) {
                  final snackBar = SnackBar(
                    content: const Text('Please enter valid details'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  isEmptyField = true;
                }
              });
              if (!isEmptyField) {
                saveSpecialOffer();
              }
            }
          },
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode(context) ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  saveSpecialOffer() async {
    FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
    if (vendorModel != null) {
      vendorModel!.specialDiscount = specialDiscount;
      vendorModel!.specialDiscountEnable = isSpecialSwitched;

      await FireStoreUtils.updateVendor(vendorModel!).then((value) async {
        await showProgress(context, 'Update Special discount...', false);
        await hideProgress();
      });
    }
  }

  Future<TimeOfDay?> _selectTime() async {
    FocusScope.of(context).requestFocus(new FocusNode()); //remove focus
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      return newTime;
    }
    return null;
  }
}
