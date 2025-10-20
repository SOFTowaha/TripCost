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
    @State private var isSelectingStart = true
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var searchVM = SearchViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                mapView

                VStack(spacing: 0) {
                    // Apple Maps style search card
                    VStack(spacing: 0) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                                .font(.title2)
                            TextField("Search for a place or address", text: $searchVM.query)
                                .textFieldStyle(.plain)
                                .font(.title3)
                                .padding(.vertical, 8)
                                .onChange(of: searchVM.query) { _, newValue in
                                    searchVM.updateQuery(newValue)
                                }
                            if searchVM.isLoading == true {
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                            if !searchVM.query.isEmpty {
                                Button {
                                    searchVM.query = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(NSColor.windowBackgroundColor))
                                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                        .padding(.top, 18)
                        .padding(.horizontal, 32)

                        // Results dropdown
                        if !searchVM.suggestions.isEmpty && !searchVM.query.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(searchVM.suggestions, id: \ .self) { suggestion in
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
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
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
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(NSColor.windowBackgroundColor))
                                    .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                            )
                            .frame(maxWidth: 600, maxHeight: 320)
                            .padding(.horizontal, 32)
                        }
                    }
                    // End search card

                    locationSelectionCard
                        .padding(.top, 16)

                    Spacer()

                    if locationViewModel.startLocation != nil && locationViewModel.endLocation != nil {
                        actionButtons
                            .padding(.bottom, 20)
                    }
                }
                .padding(.bottom, 0)
            }
            .navigationTitle("Trip Calculator")
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

    // Replace 'mapView' computed var with:
    private var mapView: some View {
        let handlePick: (MKMapItem) -> Void = { item in
            if let coord = item.placemark.coordinate as CLLocationCoordinate2D? {
                if isSelectingStart {
                    locationViewModel.setStartLocation(coord)
                } else {
                    locationViewModel.setEndLocation(coord)
                }
                locationViewModel.region.center = coord
            }
        }
        return ZStack(alignment: .topLeading) {
            MapTapViewRepresentable(
                region: $locationViewModel.region,
                onTap: { coordinate in
                    if isSelectingStart {
                        locationViewModel.setStartLocation(coordinate)
                    } else {
                        locationViewModel.setEndLocation(coordinate)
                    }
                },
                route: locationViewModel.route
            )
            SearchBarOverlay(
                searchVM: searchVM,
                onPick: handlePick
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }


    private var locationSelectionCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Select Locations")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Clear/Reset button
                if locationViewModel.startLocation != nil || locationViewModel.endLocation != nil {
                    Button {
                        locationViewModel.clearRoute()
                        searchVM.query = "" // Clear search too
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset")
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
            
            LocationInputRow(
                icon: "a.circle.fill",
                color: .green,
                title: "Start Location",
                address: locationViewModel.startAddress,
                isSelected: isSelectingStart,
                action: { 
                    isSelectingStart = true
                    searchVM.query = "" // Clear search when switching
                }
            )

            Divider()

            LocationInputRow(
                icon: "b.circle.fill",
                color: .red,
                title: "End Location",
                address: locationViewModel.endAddress,
                isSelected: !isSelectingStart,
                action: { 
                    isSelectingStart = false
                    searchVM.query = "" // Clear search when switching
                }
            )

            if locationViewModel.isLoadingRoute {
                Divider()
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
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showRoutePreview = true
            } label: {
                HStack {
                    Image(systemName: "map")
                    Text("Preview Route")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(locationViewModel.route == nil)
            .opacity(locationViewModel.route == nil ? 0.6 : 1.0)

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
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Calculate Cost")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(locationViewModel.route == nil)
            .opacity(locationViewModel.route == nil ? 0.6 : 1.0)
        }
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .transition(AnimationConstants.Transitions.scale)
        .animation(AnimationConstants.bouncy, value: locationViewModel.route != nil)
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
                    if searchVM.isLoading == true {
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
                    ForEach(searchVM.suggestions, id: \ .self) { suggestion in
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
