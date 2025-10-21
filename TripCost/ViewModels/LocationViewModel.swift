//
//  LocationViewModel.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation
import MapKit
import CoreLocation
import Combine

@MainActor
@Observable
class LocationViewModel: NSObject, CLLocationManagerDelegate {
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var startLocation: CLLocationCoordinate2D?
    var endLocation: CLLocationCoordinate2D?
    var startAddress: String = ""
    var endAddress: String = ""
    var route: MKRoute?
    var isLoadingRoute = false
    var errorMessage: String?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationPermission()
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        region.center = location.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    func setStartLocation(_ coordinate: CLLocationCoordinate2D, resetCalculation: @escaping () -> Void = {}, calculatorViewModel: TripCalculatorViewModel? = nil) {
        startLocation = coordinate
        print("📍 Start location set: \(coordinate.latitude), \(coordinate.longitude)")
        
        // Clear route when changing location
        route = nil
        resetCalculation()
        
        Task {
            await fetchAddress(for: coordinate, isStart: true)
            // If end location already exists, calculate route
            if endLocation != nil {
                print("🔄 Calculating route (start set after end)")
                await calculateRoute(calculatorViewModel: calculatorViewModel)
            }
        }
    }
    
    func setEndLocation(_ coordinate: CLLocationCoordinate2D, resetCalculation: @escaping () -> Void = {}, calculatorViewModel: TripCalculatorViewModel? = nil) {
        endLocation = coordinate
        print("📍 End location set: \(coordinate.latitude), \(coordinate.longitude)")
        
        // Clear route when changing location
        route = nil
        resetCalculation()
        
        Task {
            await fetchAddress(for: coordinate, isStart: false)
            // If start location already exists, calculate route
            if startLocation != nil {
                print("🔄 Calculating route (end set after start)")
                await calculateRoute(calculatorViewModel: calculatorViewModel)
            }
        }
    }
    
    private func fetchAddress(for coordinate: CLLocationCoordinate2D, isStart: Bool) async {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let address = [placemark.name, placemark.locality, placemark.administrativeArea]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                
                if isStart {
                    startAddress = address
                } else {
                    endAddress = address
                }
            }
        } catch {
            errorMessage = "Failed to fetch address: \(error.localizedDescription)"
        }
    }
    
    func calculateRoute(calculatorViewModel: TripCalculatorViewModel? = nil) async {
        guard let start = startLocation, let end = endLocation else { return }
        
        isLoadingRoute = true
        defer { isLoadingRoute = false }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            route = response.routes.first
            print("✅ Route calculated successfully: \(route?.distance ?? 0) meters")
            
            // Update calculator's tripRoute if available
            if let route = route, let calculator = calculatorViewModel {
                let tripRoute = TripRoute(
                    startLocation: start,
                    endLocation: end,
                    startAddress: startAddress,
                    endAddress: endAddress,
                    distance: route.distance,
                    expectedTravelTime: route.expectedTravelTime,
                    route: route
                )
                calculator.tripRoute = tripRoute
                print("✅ TripRoute updated in calculator: \(tripRoute.distanceInMiles()) miles")
            }
        } catch {
            errorMessage = "Failed to calculate route: \(error.localizedDescription)"
            print("❌ Route calculation failed: \(error.localizedDescription)")
        }
    }
    
    func clearRoute() {
        startLocation = nil
        endLocation = nil
        startAddress = ""
        endAddress = ""
        route = nil
        errorMessage = nil
    }
}
