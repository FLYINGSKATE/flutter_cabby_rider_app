import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cabby_rider_app/AllScreens/search_screen.dart';
import 'package:cabby_rider_app/AllWidgets/Divider.dart';
import 'package:cabby_rider_app/AllWidgets/progress_dialog.dart';
import 'package:cabby_rider_app/Assistants/assistantMethods.dart';
import 'package:cabby_rider_app/DataHandler/appData.dart';
import 'package:cabby_rider_app/Models/placePredictions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {

  static const String idScreen = "mainscreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight =0;
  double searchContainerHeight = 332.0;

  bool drawerOpen = true;

  void displayRequestContainer(){
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;

    });
  }


  static const colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 30.0,
    fontFamily: 'Signatara',
  );

  resetApp(){
    setState(() {
      drawerOpen  = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0.0;
      bottomPaddingOfMap = 230.0;

      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();

  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState((){
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    
    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition,zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCordinateAddress(position,context);
    print("This is your address :: "+address);


    locatePosition();
    
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: Text("Cabby"),
      ),
      drawer:Container(
        color:Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png",height: 65.0,width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Profile Name",style: TextStyle(fontSize: 16.0,fontFamily: "Bolt Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Visit Profile"),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              DividerWidget(),

              SizedBox(height: 12.0,),

              ListTile(
                leading: Icon(Icons.history),
                title: Text("History",style: TextStyle(fontSize: 15.0),),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Visit Profile",style: TextStyle(fontSize: 15.0),),
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text("About",style: TextStyle(fontSize: 15.0),),
              ),


            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType:MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,

            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 100.0;
              });

            },
          ),

    //HamburgerButton for Drawer
          Positioned(
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: (){
                if(drawerOpen){
                    scaffoldKey.currentState.openDrawer();
                }
                else{
                    resetApp();
                }

              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,0.7,
                      )
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerOpen) ? Icons.menu:Icons.close,color: Colors.black,),
                  radius: 20.0,
                ),
              ),
            ),
          ),


          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0),topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7),
                    )
                  ]
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0,),
                      Text("Hi There,",style: TextStyle(fontSize: 12.0),),
                      Text('Where to?',style: TextStyle(fontSize: 20.0,fontFamily: "Bolt Bold"),),
                      SizedBox(height: 20.0,),

                      GestureDetector(
                        onTap: () async{
                          var res = await Navigator.push(context,MaterialPageRoute(builder:(context)=>SearchScreen()));
                          if(res =="obtainDirection"){
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius:6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7,0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search,color:Colors.blue,),
                                SizedBox(width: 10.0,),
                                Text("Search Drop Off")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.0,),
                      Row(
                        children: [
                          Icon(Icons.home,color:Colors.grey),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  Provider.of<AppData>(context).pickUpLocation!=null
                                  ?Provider.of<AppData>(context).pickUpLocation.placeName
                                  :"Add Home"),
                              SizedBox(height: 4.0,),
                              Text("Your living home address",style: TextStyle(color: Colors.grey[200],fontSize:12.0),)
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 24.0,),

                      DividerWidget(),

                      SizedBox(height: 24.0,),

                      Row(
                        children: [
                          Icon(Icons.work,color:Colors.grey),
                          SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(height: 4.0,),
                              Text("Your office address",style: TextStyle(color: Colors.grey[200],fontSize:12.0),)
                            ],
                          )
                        ],
                      ),

                      SizedBox(height: 24.0,),
                    ],
                  ),
                )
              ),
            ),
          ),
          
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(16.0),topLeft: Radius.circular(16.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7,0.7),
                      )
                    ]
                  ),
                child: Padding(
                  padding:EdgeInsets.symmetric(vertical:17.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("images/taxi.png",height: 70.0,width: 80.0,),
                              SizedBox(width: 16.0,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Car",style: TextStyle(fontSize: 18.0,fontFamily: "Bolt Semibold"),),
                                  Text((tripDirectionDetails!=null)? tripDirectionDetails.distanceText:'',style: TextStyle(fontSize: 16.0,color: Colors.grey,fontFamily: "Bolt Semibold"),)
                                ],
                              ),
                              Expanded(
                                child: Container(),),
                              Text(
                                ((tripDirectionDetails!=null) ? '\$${AssistantMethods.calculateFares((tripDirectionDetails))}': ''),style: TextStyle(fontFamily: "Bolt Semibold"),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0,),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt,size: 18.0,color: Colors.black54,),
                            SizedBox(width: 16.0,),
                            Text("Cash"),
                            SizedBox(width: 6.0,),
                            Icon(Icons.keyboard_arrow_down,color: Colors.black54,size: 16.0,),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0,),

                      Padding(
                          padding:EdgeInsets.symmetric(horizontal: 20.0),
                          child: RaisedButton(
                            onPressed: (){
                              displayRequestContainer();
                            },
                            color: Theme.of(context).accentColor,
                            child: Padding(
                              padding: EdgeInsets.all(17.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Request",style: TextStyle(fontSize: 2.0,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Icon(FontAwesomeIcons.taxi,color: Colors.white,size: 26.0,)
                                ],
                              ),
                            ),
                          ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
    Positioned(
      bottom: 0.0,
      left:0.0,
      right: 0.0,
      child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            spreadRadius: 0.5,
            blurRadius: 16.0,
            color:Colors.black54,
            offset:Offset(0.7,0.7),
          ),
          ],
        ),
          height: requestRideContainerHeight,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                SizedBox(height: 12.0,),
                SizedBox(
                  width: double.infinity,
                  child: AnimatedTextKit(
                  animatedTexts: [
                      ColorizeAnimatedText(
                      'Requesting a Ride....',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                      textAlign: TextAlign.center,
                      ),
                      ColorizeAnimatedText(
                      'Please Wait....',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                      textAlign: TextAlign.center,
                      ),
                      ColorizeAnimatedText(
                      'Finding a Driver...',
                      textStyle: colorizeTextStyle,
                      colors: colorizeColors,
                      textAlign: TextAlign.center,
                      ),
                  ],
                  isRepeatingAnimation: true,
                  onTap: () {
                    print("Tap Event");
                  },
      ),
    ),
    SizedBox(height: 22.0,),
    Container(
      height: 60.0,
      width: 60.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26.0),
        border:Border.all(width: 2.0,color:Colors.grey[300]),
      ),
      child: Icon(Icons.close,size:26.0),
    ),
    SizedBox(height: 10.0,),
    Container(
      width: double.infinity,
      child: Text("Cancel Ride",textAlign: TextAlign.center,style: TextStyle(fontSize:12.0 ),),
    )
            ],
            ),
          ),
      ),
    ),
        ],
      ),
    );
  }


  Future<void> getPlaceDirection() async {
    var initialPos = Provider.of<AppData>(context,listen:false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context,listen:false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude,initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude,finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context)=>ProgressDialog(message: "Please Wait",));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(pickUpLatLng,dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });




    Navigator.pop(context);

    print("This is Encoded Points ::");
    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult = polylinePoints.decodePolyline(details.encodedPoints);
    if(decodedPolyLinePointsResult.isEmpty){
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(pointLatLng.latitude,pointLatLng.longitude));
      });
    }

    setState(() {
      Polyline polyLine = Polyline(
        color:Colors.pink,
        polylineId:PolylineId("PolylineID"),
        jointType:JointType.round,
        points:pLineCoordinates,
        width:5,
        startCap: Cap.roundCap,
        endCap:Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyLine);

    });

    LatLngBounds latLngBounds;
    if(pickUpLatLng.latitude > dropOffLatLng.latitude && pickUpLatLng.longitude > dropOffLatLng.longitude){
      latLngBounds = LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    }
    else if(pickUpLatLng.longitude > dropOffLatLng.longitude){
      latLngBounds = LatLngBounds(southwest: LatLng(pickUpLatLng.latitude,dropOffLatLng.longitude),northeast: LatLng(dropOffLatLng.latitude,pickUpLatLng.longitude));
    }
    else if(pickUpLatLng.latitude > dropOffLatLng.latitude){
      latLngBounds = LatLngBounds(southwest: LatLng(dropOffLatLng.latitude,pickUpLatLng.longitude),northeast: LatLng(pickUpLatLng.latitude,dropOffLatLng.longitude));
    }
    else{
      latLngBounds = LatLngBounds(southwest: pickUpLatLng,northeast: dropOffLatLng);
    }
    newGoogleMapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    
    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: initialPos.placeName,snippet: "my Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow: InfoWindow(title: initialPos.placeName,snippet: "DropOff Location"),
        position: dropOffLatLng,
        markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickUpLocMarker);
      markersSet.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
      circleId: CircleId("pickUpId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
