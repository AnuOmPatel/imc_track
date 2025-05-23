import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:imc_track/screens/mapviewunassigned/controller/unassigned_map_controller.dart';
import 'package:imc_track/widgets/drawer_nav.dart';

import '../../../routes/routes.dart';
import '../../../session_manager.dart';
import '../../../utils/appfonts.dart';

class UnAssignedBeatMapScreen extends StatelessWidget{

  final UnAssignedBeatMapController unAssignedBeatMapController =
  Get.put(UnAssignedBeatMapController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map View",style: AppFonts.Montserrat.copyWith(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              unAssignedBeatMapController.drawBeatPolylinesAndMarkers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await SessionManager.clearSession();
              Get.offAllNamed(Routes.loginScreen);
            },
          ),
        ],),
      drawer: DrawerWidget(),
      body: SafeArea(child: Obx((){
        return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(22.7196, 75.8577),
              zoom: 20,
            ),
            onMapCreated: (controller) {
              unAssignedBeatMapController.setMapController(controller);

              // Move the camera after map is created and center is ready
              final center = unAssignedBeatMapController.mapCenter.value;
              print("map center in screen ${center}");
              if (center != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: center, zoom: 18),
                  ),
                );
              }
            },
            onTap: (_) {
              // Clear selection on map tap
            },
            polylines: unAssignedBeatMapController.beatPolylines,
            markers: {
              ...unAssignedBeatMapController.beatMarkers.value,
            });
      })),
    );
  }
  
}