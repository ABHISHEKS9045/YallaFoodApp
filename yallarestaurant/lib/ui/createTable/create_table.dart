import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodie_restaurant/constants.dart';
import 'package:foodie_restaurant/main.dart';
import 'package:foodie_restaurant/model/TableModel.dart';
import 'package:foodie_restaurant/model/VendorModel.dart';
import 'package:foodie_restaurant/services/FirebaseHelper.dart';
import 'package:foodie_restaurant/services/helper.dart';
import 'package:foodie_restaurant/textformfield_widget.dart';

class CreateTable extends StatefulWidget {
  const CreateTable({Key? key}) : super(key: key);

  @override
  State<CreateTable> createState() => _CreateTableState();
}

class _CreateTableState extends State<CreateTable> {
  VendorModel? vendorModel;
  List<TableModel> bookTableList = [];
  List<TextEditingController> controllerList = [];
  final formKey = GlobalKey<FormState>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getVendor();
    getTable();
  }

  getVendor() async {
    vendorModel = await FireStoreUtils.getVendor(MyAppState.currentUser!.vendorID);
  }

  getTable() async {
    bookTableList = await FireStoreUtils.getTable(MyAppState.currentUser!.vendorID);
    bookTableList.sort((a, b) {
      return a.tableName.toString().compareTo(b.tableName.toString());
    });
    for (int i = 0; i < bookTableList.length; i++) {
      controllerList.add(TextEditingController(text: bookTableList[i].tableName));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Please click plus icon to create new table".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                            size: 36,
                          ),
                          onPressed: () {
                            DocumentReference documentReference = FireStoreUtils.firestore.collection(CREATETABLE).doc();
                            controllerList.add(TextEditingController());
                            bookTableList.add(TableModel(tableId: documentReference.id, tableName: ''));
                            print("controllerList${controllerList.length}");
                            print("bookTableList${bookTableList.length}");
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: bookTableList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            child: UnderLineTextFormFieldWidget(
                              controller: controllerList[index],
                              hintText: 'Enter table name'.tr(),
                              // initialValue: bookTableList[index].tableName,
                              suffix: IconButton(
                                icon: Icon(
                                  Icons.remove_circle,
                                  color: Color(COLOR_PRIMARY),
                                ),
                                onPressed: () async {
                                  print("index--->>$index");
                                  print("LIST--->>${bookTableList[index].tableName}");
                                  await showProgress(context, 'removing table...'.tr(), false);
                                  FireStoreUtils.removeTable(bookTableList[index], vendorModel!);
                                  controllerList.removeAt(index);
                                  bookTableList.removeAt(index);
                                  await hideProgress();
                                  setState(() {});
                                },
                              ),
                              validator: validateEmptyField,
                              onChanged: (String value) {
                                bookTableList[index].tableName = value;
                              },
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Visibility(
        visible: bookTableList.isEmpty ? false : true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15),
                backgroundColor: Color(COLOR_PRIMARY),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await showProgress(context, 'Adding table...'.tr(), false);
                  for (int i = 0; i < bookTableList.length; i++) {
                    FireStoreUtils.addTable(bookTableList[i], vendorModel!);
                  }
                  FocusManager.instance.primaryFocus?.unfocus();
                  await hideProgress();
                }
              },
              child: Text(
                'SUBMIT'.tr(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              )),
        ),
      ),
    );
  }
}
