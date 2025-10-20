//
//  MapTapViewRepresentable.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI
import MapKit

struct MapTapViewRepresentable: NSViewRepresentable { // macOS
    @Binding var region: MKCoordinateRegion
    var onTap: (CLLocationCoordinate2D) -> Void
    var route: MKRoute?

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapTapViewRepresentable
        init(_ parent: MapTapViewRepresentable) { self.parent = parent }

        @objc func handleTap(_ gesture: NSClickGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coord = mapView.convert(point, toCoordinateFrom: mapView)
            parent.onTap(coord)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.showsCompass = true
        map.showsZoomControls = true
        let tap = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        map.addGestureRecognizer(tap)
        return map
    }

    func updateNSView(_ map: MKMapView, context: Context) {
        if map.region.center.latitude != region.center.latitude ||
            map.region.center.longitude != region.center.longitude {
            map.setRegion(region, animated: true)
        }
        map.removeOverlays(map.overlays)
        if let route {
            map.addOverlay(route.polyline)
        }
        map.delegate = context.coordinator
    }
}

extension MapTapViewRepresentable.Coordinator {
    // Render route polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = NSColor.systemBlue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
