import 'package:cabby_rider_app/DataHandler/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier{
  Address pickUpLocation,dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress){
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress){
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }

}