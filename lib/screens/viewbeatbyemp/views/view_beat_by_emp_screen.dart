import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:imc_track/screens/viewbeatbyemp/controller/view_beat_by_emp_controller.dart';

import '../../../routes/routes.dart';
import '../../../session_manager.dart';

class ViewBeatByEmpScreen extends StatelessWidget{


  final ViewBeatByEmpController viewBeatByEmpController=Get.put(ViewBeatByEmpController());
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final empId = args['empid'];

    return Scaffold(
      appBar: AppBar(title: Text("Beat by Emp"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
             // createdBeatController.onInit();
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
      body: SafeArea(child: Obx((){
        return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(22.7196, 75.8577),
              zoom: 20,
            ),
            onMapCreated: (controller) {
              viewBeatByEmpController.setMapController(controller);
              //viewBeatByEmpController.animateToCenter();
              final center = viewBeatByEmpController.mapCenter.value;
              print("map center in screen ${center}");
           /*   if (center != null) {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: center, zoom: 18),
                  ),
                );
              }*/
            },
            polylines: viewBeatByEmpController.beatPolylines,
            markers: {
              ...viewBeatByEmpController.beatMarkers.value,
            });
      })),
    );
  }

}