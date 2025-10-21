import SwiftUI

struct SavedTripsView: View {
    @Environment(SavedTripsViewModel.self) private var viewModel
    @State private var showingAddTrip = false
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.savedTrips.isEmpty {
                    ContentUnavailableView {
                        Label("No Saved Trips", systemImage: "car.circle")
                    } description: {
                        Text("Save your trips to view and share them later.")
                    }
                } else {
                    ForEach(viewModel.savedTrips) { trip in
                        NavigationLink {
                            SavedTripDetailView(trip: trip)
                        } label: {
                            SavedTripRow(trip: trip)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            viewModel.deleteTrip(viewModel.savedTrips[index])
                        }
                    }
                }
            }
            .navigationTitle("Saved Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // For now, just refresh
                        viewModel.loadTrips()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct SavedTripRow: View {
    let trip: SavedTrip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.headline)
                    
                    Text("\(trip.route.startAddress) → \(trip.route.endAddress)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(trip.currency.symbol)\(String(format: "%.2f", trip.cost))")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(trip.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
            
            HStack(spacing: 12) {
                Label(trip.vehicle.displayName, systemImage: "car.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(String(format: "%.1f", trip.route.distanceInMiles())) mi", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct SavedTripDetailView: View {
    @Environment(SavedTripsViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    let trip: SavedTrip
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(trip.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(trip.date.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // Route Info
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Route Details", systemImage: "map")
                            .font(.headline)
                        
                        Divider()
                        
                        HStack {
                            Image(systemName: "a.circle.fill")
                                .foregroundStyle(.green)
                            Text(trip.route.startAddress)
                                .font(.body)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "b.circle.fill")
                                .foregroundStyle(.red)
                            Text(trip.route.endAddress)
                                .font(.body)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                                .foregroundStyle(.blue)
                            Text("\(String(format: "%.1f", trip.route.distanceInMiles())) miles")
                                .font(.body)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.orange)
                            Text(formatTime(trip.route.expectedTravelTime))
                                .font(.body)
                            Spacer()
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // Vehicle Info
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Vehicle", systemImage: "car.fill")
                            .font(.headline)
                        
                        Divider()
                        
                        Text(trip.vehicle.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("Fuel Type:")
                                .foregroundStyle(.secondary)
                            Text(trip.vehicle.fuelType.rawValue)
                        }
                        
                        HStack {
                            Text("Combined MPG:")
                                .foregroundStyle(.secondary)
                            Text("\(String(format: "%.1f", trip.vehicle.combinedMPG))")
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // Cost Breakdown
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Cost Breakdown", systemImage: "dollarsign.circle")
                            .font(.headline)
                        
                        Divider()
                        
                        HStack {
                            Text("Total Cost")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(trip.currency.symbol)\(String(format: "%.2f", trip.cost))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        
                        if !trip.additionalCosts.isEmpty {
                            Divider()
                            Text("Additional Costs")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(trip.additionalCosts) { cost in
                                HStack {
                                    Text(cost.name)
                                    Spacer()
                                    Text("\(trip.currency.symbol)\(String(format: "%.2f", cost.amount))")
                                }
                                .font(.body)
                            }
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)
                
                // Notes
                if let notes = trip.notes, !notes.isEmpty {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Notes", systemImage: "note.text")
                                .font(.headline)
                            
                            Divider()
                            
                            Text(notes)
                                .font(.body)
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                
                // Actions
                HStack(spacing: 16) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share Trip", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Button(role: .destructive) {
                        viewModel.deleteTrip(trip)
                        dismiss()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.vertical)
        }
        .navigationTitle("Trip Details")
        .sheet(isPresented: $showShareSheet) {
            ShareTripView(trip: trip)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct ShareTripView: View {
    let trip: SavedTrip
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Share Trip")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Share your trip details with friends")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Trip Summary")
                        .font(.headline)
                    
                    Text(generateShareText())
                        .font(.body)
                        .textSelection(.enabled)
                        .padding()
                        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    copyToClipboard()
                } label: {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func generateShareText() -> String {
        let dateStr = trip.date.formatted(date: .long, time: .omitted)
        let distance = String(format: "%.1f", trip.route.distanceInMiles())
        let cost = String(format: "%.2f", trip.cost)
        
        return """
        🚗 \(trip.name)
        
        📅 Date: \(dateStr)
        🗺️ Route: \(trip.route.startAddress) → \(trip.route.endAddress)
        📏 Distance: \(distance) miles
        🚙 Vehicle: \(trip.vehicle.displayName)
        💰 Total Cost: \(trip.currency.symbol)\(cost)
        
        \(trip.notes ?? "")
        """
    }
    
    private func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generateShareText(), forType: .string)
        #endif
    }
}
