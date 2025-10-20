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

                VStack {
                    locationSelectionCard
                    Spacer()

                    if locationViewModel.startLocation != nil && locationViewModel.endLocation != nil {
                        actionButtons
                    }
                }
                .padding()
            }
            .navigationTitle("Trip Calculator")
//            .navigationBarTitleDisplayMode(.inline)
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
        .overlay(alignment: .top) {
            SearchBarOverlay(
                searchVM: searchVM,
                onPick: { item in
                    if let coord = item.placemark.coordinate as CLLocationCoordinate2D? {
                        if isSelectingStart {
                            locationViewModel.setStartLocation(coord)
                        } else {
                            locationViewModel.setEndLocation(coord)
                        }
                        // recenter map
                        locationViewModel.region.center = coord
                    }
                }
            )
            .padding()
        }
    }


    private var locationSelectionCard: some View {
        VStack(spacing: 12) {
            LocationInputRow(
                icon: "a.circle.fill",
                color: .green,
                title: "Start Location",
                address: locationViewModel.startAddress,
                isSelected: isSelectingStart,
                action: { isSelectingStart = true }
            )

            Divider()

            LocationInputRow(
                icon: "b.circle.fill",
                color: .red,
                title: "End Location",
                address: locationViewModel.endAddress,
                isSelected: !isSelectingStart,
                action: { isSelectingStart = false }
            )

            if locationViewModel.isLoadingRoute {
                ProgressView("Calculating route...")
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
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
            .disabled(locationViewModel.route == nil)
            .opacity(locationViewModel.route == nil ? 0.6 : 1.0)
        }
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
        VStack(spacing: 8) {
            // Native macOS search field style
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search for a place or address", text: $searchVM.query)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: searchVM.query) { _, newValue in
                        searchVM.updateQuery(newValue)
                    }
            }
            .padding(8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))

            if !searchVM.suggestions.isEmpty && !searchVM.query.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(searchVM.suggestions, id: \.self) { suggestion in
                            Button {
                                Task {
                                    if let item = await searchVM.resolve(suggestion) {
                                        onPick(item)
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title).font(.subheadline)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
                .frame(maxHeight: 240)
            }
        }
    }
}
