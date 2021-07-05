import 'package:cabby_rider_app/Assistants/requestAssistant.dart';
import 'package:cabby_rider_app/DataHandler/address.dart';
import 'package:cabby_rider_app/DataHandler/appData.dart';
import 'package:cabby_rider_app/Models/placePredictions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cabby_rider_app/configMaps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods{
  static Future<String> searchCordinateAddress(Position position,context) async {

    String placeAddress = "";
    String st1,st2,st3,st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if(response!='failed'){
      //placeAddress  = response["results"][0]["formatted_address"];
      st1 = response["result"][0]["address_components"][3]["long_name"];
      st1 = response["result"][0]["address_components"][4]["long_name"];
      st1 = response["result"][0]["address_components"][5]["long_name"];
      st1 = response["result"][0]["address_components"][6]["long_name"];
      placeAddress = st1+", "+st2+", "+st3+", "+st4;

      //placeAddress  = response["results"][0]["address_components"][3]["long_name"];
      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      Provider.of<AppData>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialPosition,LatLng finalPosition) async {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.latitude}&destination=&key=";

    var res = await RequestAssistant.getRequest(directionUrl);

    if(res=="failed"){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails){
    double timeTraveledFare = (directionDetails.durationValue/60)*0.20;
    double distanceTraveledFare = (directionDetails.distanceValue/1000)*0.20;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    //Local Currency
    //1$ = 74.55Rs
    //double totalLocalAmount = totalFareAmount * 74.55;

    return totalFareAmount.truncate();
  }

}