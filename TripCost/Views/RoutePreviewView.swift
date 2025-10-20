//
//  RoutePreviewView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI
import MapKit

struct RoutePreviewView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var locationViewModel: LocationViewModel
    @Bindable var calculatorViewModel: TripCalculatorViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                routeMap
                routeDetails
            }
            .navigationTitle("Route Preview")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var routeMap: some View {
        Map(position: $cameraPosition) {
            if let start = locationViewModel.startLocation {
                Marker("Start", systemImage: "a.circle.fill", coordinate: start).tint(.green)
            }
            if let end = locationViewModel.endLocation {
                Marker("End", systemImage: "b.circle.fill", coordinate: end).tint(.red)
            }
            if let route = locationViewModel.route {
                MapPolyline(route.polyline).stroke(.blue, lineWidth: 5)
            }
        }
        .frame(height: 300)
        .mapStyle(.standard(elevation: .realistic))
    }

    private var routeDetails: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                routeInfoCard
                directionsCard
            }
            .padding()
        }
    }

    private var routeInfoCard: some View {
        VStack(spacing: 16) {
            RouteInfoRow(icon: "location.fill", title: "Distance", value: calculatorViewModel.distanceDisplay)
            if let route = locationViewModel.route {
                RouteInfoRow(icon: "clock.fill", title: "Estimated Time", value: formatTime(route.expectedTravelTime))
            }
            RouteInfoRow(icon: "arrow.triangle.turn.up.right.circle.fill", title: "From", value: locationViewModel.startAddress)
            RouteInfoRow(icon: "mappin.circle.fill", title: "To", value: locationViewModel.endAddress)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var directionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Directions").font(.headline)
            if let route = locationViewModel.route {
                ForEach(Array(route.steps.enumerated()), id: \.offset) { index, step in
                    DirectionStep(stepNumber: index + 1, instruction: step.instructions, distance: formatDistance(step.distance))
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    private func formatDistance(_ meters: Double) -> String {
        if calculatorViewModel.useMetric {
            return meters >= 1000 ? String(format: "%.1f km", meters / 1000) : String(format: "%.0f m", meters)
        } else {
            let miles = meters * 0.000621371
            if miles >= 0.1 { return String(format: "%.1f mi", miles) }
            let feet = meters * 3.28084
            return String(format: "%.0f ft", feet)
        }
    }
}

struct RouteInfoRow: View {
    let icon: String
    let title: String
    let value: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundStyle(.blue).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.subheadline).fontWeight(.medium)
            }
            Spacer()
        }
    }
}

struct DirectionStep: View {
    let stepNumber: Int
    let instruction: String
    let distance: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(stepNumber)")
                .font(.caption).fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(.blue, in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(instruction).font(.subheadline)
                Text(distance).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}
