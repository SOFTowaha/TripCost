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
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Route Preview")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
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
        .frame(height: 380)
        .mapStyle(.standard(elevation: .realistic))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
        .padding(24)
    }

    private var routeDetails: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                routeInfoCard
                directionsCard
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var routeInfoCard: some View {
        VStack(spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trip Overview")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text("Route details and estimates")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "map.fill")
                    .font(.title)
                    .foregroundStyle(.blue.opacity(0.5))
            }
            
            Divider()
                .opacity(0.5)
            
            VStack(spacing: 14) {
                RouteInfoRow(
                    icon: "road.lanes",
                    title: "Distance",
                    value: calculatorViewModel.distanceDisplay,
                    color: .blue
                )
                
                if let route = locationViewModel.route {
                    RouteInfoRow(
                        icon: "clock.fill",
                        title: "Estimated Time",
                        value: formatTime(route.expectedTravelTime),
                        color: .orange
                    )
                }
                
                RouteInfoRow(
                    icon: "location.circle.fill",
                    title: "From",
                    value: locationViewModel.startAddress,
                    color: .green
                )
                
                RouteInfoRow(
                    icon: "mappin.circle.fill",
                    title: "To",
                    value: locationViewModel.endAddress,
                    color: .red
                )
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }

    private var directionsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.title2)
                        .foregroundStyle(.purple)
                    Text("Turn-by-Turn Directions")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            
            if let route = locationViewModel.route {
                VStack(spacing: 0) {
                    ForEach(Array(route.steps.enumerated()), id: \.offset) { index, step in
                        DirectionStep(
                            stepNumber: index + 1,
                            instruction: step.instructions,
                            distance: formatDistance(step.distance)
                        )
                        
                        if index < route.steps.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                                .opacity(0.5)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
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
    var color: Color = .blue
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
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
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .purple.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Text("\(stepNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(instruction)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text(distance)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}
