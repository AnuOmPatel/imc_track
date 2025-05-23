import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:imc_track/network/requests/view_beat_by_emp_request.dart';
import 'package:imc_track/network/responses/view_beet_emp_wise_response/view_beats_by_emp_response.dart';

import '../../../network/retrofit/api_client.dart';

class ViewBeatByEmpController extends GetxController{
  RxBool loading = false.obs;
  RxSet<Polyline> beatPolylines = <Polyline>{}.obs;
  GoogleMapController? mapController;
  RxSet<Marker> beatMarkers = <Marker>{}.obs;
  final Map<PolylineId, BeatData> polylineToBeatMap = {};
  Rxn<LatLng> mapCenter = Rxn<LatLng>();

  @override
  void onInit() {
    super.onInit();
    final empId = Get.arguments['empid'];
    if (empId != null) {
      fetchBeatsForEmployee(empId);
    }
  }

  Future<void> fetchBeatsForEmployee(int empId) async {
    try {
      loading.value = true;

      final request = ViewBeatsByEmpRequest(
        action: "view_beets_by_employee",
        employeeId: empId,
      );

      final response = await ApiClient.apiService.getBeatsByEmpliyee(request);
      final jsonData = response is String ? jsonDecode(response) : response;
      final beatsByEmpResponse= ViewBeatsByEmpResponse.fromJson(jsonData);
      final List<BeatData> beatDataList = beatsByEmpResponse.result?.data ?? [];

      drawBeatPolylinesAndMarkers(beatDataList);
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch beats: $e");
    } finally {
      loading.value = false;
    }
  }


  Future<void> drawBeatPolylinesAndMarkers(List<BeatData> beats) async {
    Set<Polyline> polylines = {};
    Set<Marker> markers = {};
    //final List<EmployeeWithBeat> empList = [];

    for (var beat in beats) {
      final coordinates = beat.latLngData?.coordinates;
      if (coordinates != null && coordinates.isNotEmpty) {
        final List<LatLng> points = coordinates
            .expand((a) => a)
            .expand((b) => b)
            .map((point) => LatLng(point[1], point[0]))
            .toList();

        final polylineId = PolylineId("beat_${beat.beetId}");
        polylineToBeatMap[polylineId] = beat;

        if (points.isNotEmpty) {

          polylines.add(
            Polyline(
              polylineId: PolylineId("beat_${beat.beetId}"),
              points: points,
              width: 8,
              color: hexToColor(beat.color ?? "#FF0000"),

            ),
          );
          final midpoint = getMidPoint(points);
          mapCenter.value = midpoint;
          animateToCenter();
          print("map center${mapCenter.value}");
          markers.add(
            Marker(
              markerId: MarkerId("marker_${beat.beetId}"),
              position: midpoint,
              infoWindow: InfoWindow(title: beat.beetName ?? '', snippet: "${beat.distance.toString()} Mtrs"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta), // Optional: custom color
            ),
          );
        }
      }
    }

    print("Markers count: ${markers.length}");

    beatPolylines.value = polylines;
    beatMarkers.value = markers; // Update the beatMarkers observable
    //selectedBeatData.value = empList;
  }

  Color hexToColor(String hex) {
    // Remove the '#' if it exists
    hex = hex.replaceAll('#', '');

    // If it's 3 digits (e.g., 'EEE'), expand to 6 digits (e.g., 'EEEEEE')
    if (hex.length == 3) {
      hex = hex.split('').map((e) => e * 2).join('');
    }

    // Add 'FF' as the alpha value (fully opaque) if not present
    if (hex.length == 6) {
      hex = 'FF' + hex; // Adds full opacity
    }

    // Now parse the hex value into an integer and create a Color object
    return Color(int.parse('0x$hex'));
  }
  LatLng getMidPoint(List<LatLng> polyPoints) {
    double latSum = 0;
    double lngSum = 0;
    int totalPoints = polyPoints.length;

    for (LatLng point in polyPoints) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    return LatLng(latSum / totalPoints, lngSum / totalPoints);
  }
  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }
  /*void drawPolylines(List<BeatData> beats) {
    Set<Polyline> newPolylines = {};
    for (var beat in beats) {
      final coordinates = beat.latLngData?.coordinates;
      if (coordinates != null && coordinates.isNotEmpty) {
        final List<LatLng> points = coordinates
            .expand((a) => a)
            .expand((b) => b)
            .map((point) => LatLng(point[1], point[0]))
            .toList();

        if (points.isNotEmpty) {
          newPolylines.add(
            Polyline(
              polylineId: PolylineId("beat_${beat.beetId}_${beat.shiftStartTime}"),
              points: points,
              width: 6,
              color: hexToColor(beat.color ?? "#FF0000"),
            ),
          );
        }
      }
    }
    beatPolylines.value = newPolylines;
  }

 */

  @override
  void onClose() {
    mapController = null;
    super.onClose();
  }
  void animateToCenter() {
    final center = mapCenter.value;
    if (center != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: center, zoom: 18),
        ),
      );
    }
  }


}