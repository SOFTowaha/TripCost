//
//  MapSelectionView.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapSelectionView: View {
    @Bindable var locationViewModel: LocationViewModel
    @Bindable var calculatorViewModel: TripCalculatorViewModel
    @Bindable var vehicleViewModel: VehicleViewModel

    @State private var showRoutePreview = false
    @State private var showCostBreakdown = false
    @State private var showFromSearch = false
    @State private var showToSearch = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var fromSearchVM = SearchViewModel()
    @State private var toSearchVM = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                mapView

                VStack(spacing: 0) {
                    // Side-by-side 'From' and 'To' cards with glass design
                    HStack(spacing: 16) {
                        Button(action: { showFromSearch = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "a.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("From")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(locationViewModel.startAddress.isEmpty ? "Choose starting point" : locationViewModel.startAddress)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: { showToSearch = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "b.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("To")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(locationViewModel.endAddress.isEmpty ? "Choose destination" : locationViewModel.endAddress)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 32)

                    Spacer()

                    if locationViewModel.startLocation != nil && locationViewModel.endLocation != nil {
                        actionButtons
                            .padding(.bottom, 20)
                    }
                }
                .sheet(isPresented: $showFromSearch) {
                    PlaceSearchModal(
                        title: "From",
                        searchVM: fromSearchVM,
                        onPick: { item in
                            let coord = item.placemark.coordinate
                            locationViewModel.setStartLocation(coord) {
                                // Reset calculation when route changes
                                calculatorViewModel.tripRoute = nil
                            }
                            locationViewModel.region.center = coord
                            showFromSearch = false
                        }
                    )
                }
                .sheet(isPresented: $showToSearch) {
                    PlaceSearchModal(
                        title: "To",
                        searchVM: toSearchVM,
                        onPick: { item in
                            let coord = item.placemark.coordinate
                            locationViewModel.setEndLocation(coord) {
                                // Reset calculation when route changes
                                calculatorViewModel.tripRoute = nil
                            }
                            locationViewModel.region.center = coord
                            showToSearch = false
                        }
                    )
                }
            }
            .navigationTitle("Trip Calculator")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        resetAll()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                            Text("Reset")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(locationViewModel.startLocation == nil && locationViewModel.endLocation == nil)
                    .opacity((locationViewModel.startLocation == nil && locationViewModel.endLocation == nil) ? 0.5 : 1.0)
                }
            }
            .sheet(isPresented: $showRoutePreview) {
                RoutePreviewView(
                    locationViewModel: locationViewModel,
                    calculatorViewModel: calculatorViewModel
                )
            }
            .sheet(isPresented: $showCostBreakdown) {
                CostBreakdownView(
                    calculatorViewModel: calculatorViewModel,
                    vehicleViewModel: vehicleViewModel
                )
            }
        }
    }

    private var mapView: some View {
        Map(
            position: $cameraPosition,
            bounds: MapCameraBounds(minimumDistance: 500, maximumDistance: 5_000_000)
        ) {
            // Show pins for selected start/end
            if let start = locationViewModel.startLocation {
                Annotation("Start", coordinate: start) {
                    Image(systemName: "a.circle.fill").foregroundStyle(.green)
                }
            }
            if let end = locationViewModel.endLocation {
                Annotation("End", coordinate: end) {
                    Image(systemName: "b.circle.fill").foregroundStyle(.red)
                }
            }

            // Optionally draw route polyline if available
            if let route = locationViewModel.route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .onAppear {
            // Keep camera centered on current region center
            cameraPosition = .region(locationViewModel.region)
        }
        .onChange(of: locationViewModel.region.center.latitude) { _, _ in
            cameraPosition = .region(locationViewModel.region)
        }
        .onChange(of: locationViewModel.region.center.longitude) { _, _ in
            cameraPosition = .region(locationViewModel.region)
        }
    }


    private var locationSelectionCard: some View {
        VStack(spacing: 12) {
            HStack {

                // Clear/Reset button with glass design
                if locationViewModel.startLocation != nil || locationViewModel.endLocation != nil {
                    Button {
                        locationViewModel.clearRoute()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
                .opacity(0.5)

            LocationInputRow(
                icon: "a.circle.fill",
                color: .green,
                title: "Start Location",
                address: locationViewModel.startAddress,
                isSelected: true,
                action: { }
            )

            Divider()
                .opacity(0.5)

            LocationInputRow(
                icon: "b.circle.fill",
                color: .red,
                title: "End Location",
                address: locationViewModel.endAddress,
                isSelected: false,
                action: { }
            )

            if locationViewModel.isLoadingRoute {
                Divider()
                    .opacity(0.5)
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Calculating route...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Preview Route button with glass design
            Button {
                showRoutePreview = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "map")
                        .font(.title3)
                    Text("Preview Route")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                )
                .foregroundStyle(.blue)
                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(locationViewModel.route == nil)
            .opacity(locationViewModel.route == nil ? 0.5 : 1.0)

            // Calculate Cost button with glass design
            Button {
                // Bind route into calculator VM
                if let route = locationViewModel.route {
                    calculatorViewModel.tripRoute = TripRoute(
                        startLocation: locationViewModel.startLocation ?? locationViewModel.region.center,
                        endLocation: locationViewModel.endLocation ?? locationViewModel.region.center,
                        startAddress: locationViewModel.startAddress,
                        endAddress: locationViewModel.endAddress,
                        distance: route.distance,
                        expectedTravelTime: route.expectedTravelTime,
                        route: route
                    )
                }
                showCostBreakdown = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.title3)
                    Text("Calculate Cost")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
                )
                .foregroundStyle(.green)
                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(locationViewModel.route == nil)
            .opacity(locationViewModel.route == nil ? 0.5 : 1.0)
        }
        .padding(.horizontal, 32)
        .transition(AnimationConstants.Transitions.scale)
        .animation(AnimationConstants.bouncy, value: locationViewModel.route != nil)
    }
    
    private func resetAll() {
        // Clear location data
        locationViewModel.clearRoute()
        
        // Clear calculator data
        calculatorViewModel.reset()
        
        // Reset search view models
        fromSearchVM.query = ""
        fromSearchVM.suggestions = []
        toSearchVM.query = ""
        toSearchVM.suggestions = []
        
        // Reset camera position
        cameraPosition = .automatic
        
        print("🔄 All data reset")
    }
}

struct LocationInputRow: View {
    let icon: String
    let color: Color
    let title: String
    let address: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(address.isEmpty ? "Tap map to set current region" : address)
                        .font(.subheadline)
                        .foregroundStyle(address.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct SearchBarOverlay: View {
    @Bindable var searchVM: SearchViewModel
    var onPick: (MKMapItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // macOS style search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.title2)

                ZStack(alignment: .trailing) {
                    TextField("Search for a place or address", text: $searchVM.query)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .padding(.vertical, 6)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                        .onChange(of: searchVM.query) { _, newValue in
                            searchVM.updateQuery(newValue)
                        }

                    // Use correct binding for isLoading
                    if searchVM.isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .padding(.trailing, 32)
                    }

                    if !searchVM.query.isEmpty {
                        Button {
                            searchVM.query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Results dropdown directly below search
            if !searchVM.suggestions.isEmpty && !searchVM.query.isEmpty {
                VStack(spacing: 0) {
                    ForEach(searchVM.suggestions, id: \.self) { suggestion in
                        Button {
                            Task {
                                if let item = await searchVM.resolve(suggestion) {
                                    onPick(item)
                                    searchVM.query = "" // Clear search after selection
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.primary)

                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.system(size: 12))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if suggestion != searchVM.suggestions.last {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.windowBackgroundColor))
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
                .frame(maxWidth: 480, maxHeight: 220)
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: 500)
    }
}
