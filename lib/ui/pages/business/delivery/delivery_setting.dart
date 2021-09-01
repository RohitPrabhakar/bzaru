import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class ListItem {
  int value;
  String name;

  ListItem(this.value, this.name);
}

class DeliverySetting extends StatefulWidget {
  @override
  _DeliverySettingState createState() => _DeliverySettingState();
}

class _DeliverySettingState extends State<DeliverySetting> {
  bool isSwitched = false;

  List<ListItem> _distanceItems = [
    ListItem(1, "1 km                          "),
    ListItem(2, "5 km                          "),
    ListItem(3, "10 km                         "),
    ListItem(4, "15 km                         "),
  ];

  List<ListItem> _deliveryItems = [
    ListItem(1, "20 rs                          "),
    ListItem(2, "50 rs                          "),
    ListItem(3, "100 rs                         "),
    ListItem(4, "150 rs                         "),
  ];

  List<DropdownMenuItem<ListItem>> _distanceMenuItems;
  List<DropdownMenuItem<ListItem>> _deliveryMenuItems;
  ListItem _selectedDistanceItem;
  ListItem _selectedDeliveryItem;

  void initState() {
    super.initState();
    _distanceMenuItems = buildDropDownMenuItems(_distanceItems);
    _deliveryMenuItems=buildDropDownMenuItems(_deliveryItems);
    _selectedDistanceItem = _distanceMenuItems[0].value;
    _selectedDeliveryItem=_deliveryMenuItems[0].value;
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    TextStyle _textStyle = TextStyle(
        color: Colors.black, fontSize: 19, fontWeight: FontWeight.w600);
    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.delivery),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pick Up",
                style: _textStyle,
              ),
              Switch(
                value: isSwitched,
                activeColor: Theme.of(context).primaryColor,
                activeTrackColor: Colors.black12,
                onChanged: (value) {
                  setState(() {
                    // isSwitched = value;
                    isSwitched = !isSwitched;
                  });
                },
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 14,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Text("Home Delivery", style: _textStyle),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                          "Select if delivery is available by your side add the price for different locations"),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 3,
                child: Switch(
                  value: !isSwitched,
                  activeColor: Theme.of(context).primaryColor,
                  activeTrackColor: Colors.black12,
                  onChanged: (value) {
                    setState(() {
                      // isSwitched = value;
                      isSwitched = !isSwitched;
                    });
                  },
                  // activeTrackColor: Colors.lightGreenAccent,
                  // activeColor: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Column(
            children: [
              Text("Maximum home delivery radius",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400 ),),
              SizedBox(height: 10,),
              Card(
                elevation: 10,
                child: Container(

                  height: 35,
                  width: MediaQuery.of(context).size.width / 2.1,

                  child: Center(
                    child: DropdownButton<ListItem>(

                        underline: Container(),
                        isDense: true,
                        dropdownColor: Colors.white,
                        value: _selectedDistanceItem,
                        items: _distanceMenuItems,
                        icon: Icon(Icons.keyboard_arrow_down_rounded,size: 25,color: Theme.of(context).primaryColor,),
                        onChanged: (value) {
                          setState(() {
                            _selectedDistanceItem = value;
                          });
                        }),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Column(
            children: [
              Text("Flat delivery changes",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400 ),),
              SizedBox(height: 10,),
              Card(
                elevation: 10,
                child: Container(

                  height: 35,
                  width: MediaQuery.of(context).size.width / 2.1,

                  child: Center(
                    child: DropdownButton<ListItem>(
                        underline: Container(),
                        isDense: true,
                        value: _selectedDeliveryItem,
                        items: _deliveryMenuItems,
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.keyboard_arrow_down_rounded,size: 25,color: Theme.of(context).primaryColor,),
                        onChanged: (value) {
                          setState(() {
                            _selectedDeliveryItem = value;
                          });
                        }),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Center(
              child: CupertinoButton.filled(
                onPressed: () {},
                child: Text("Done"),
              ),
            ),
          ),
        ],
      ).pH(20),
    );
  }
}
