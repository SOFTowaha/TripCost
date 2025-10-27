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
                                .padding(12)
                                .modifier(GlassCardModifier(config: .init(cornerRadius: 14)))
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            viewModel.deleteTrip(viewModel.savedTrips[index])
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .tcGlassBackground()
            .navigationTitle("Saved Trips")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // For now, just refresh
                        viewModel.loadTrips()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
//                    .labelStyle(.iconOnly)
                    .controlSize(.small)
//                    .buttonStyle(.borderless)
                    .help("Refresh")
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
                if trip.numberOfPeople > 1 {
                    Label("Split: \(trip.numberOfPeople) people, \(trip.currency.symbol)\(String(format: "%.2f", trip.costPerPerson))/person", systemImage: "person.3.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
    @State private var isEditing = false
    @State private var editedPeople: Int = 1
    @State private var editedCostPerPerson: Double = 0
    @State private var checklistCount: (done: Int, total: Int) = (0, 0)

    var fuelCost: Double {
        // Default values for fuel price and unit (customize if you want to persist these per trip)
        let fuelPrice = 3.50
        let fuelPriceUnit: String = "perGallon" // or "perLiter"
        if trip.vehicle.fuelType == .electric { return 0 }
        let distanceInMiles = trip.route.distanceInMiles()
        let mpg = trip.vehicle.combinedMPG
        let gallonsNeeded = distanceInMiles / mpg
        let litersPerGallon = 3.78541
        let cost: Double
        if fuelPriceUnit == "perGallon" {
            cost = gallonsNeeded * fuelPrice
        } else {
            cost = (gallonsNeeded * litersPerGallon) * fuelPrice
        }
        return cost
    }
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

                // Route Info (read-only)
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Route Details", systemImage: "map")
                            .font(.headline)
                        Divider()
                        HStack {
                            Image(systemName: "a.circle.fill")
                                .foregroundStyle(.green)
                            Text(trip.route.startAddress.isEmpty ? "Start Location" : trip.route.startAddress)
                                .font(.body)
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "b.circle.fill")
                                .foregroundStyle(.red)
                            Text(trip.route.endAddress.isEmpty ? "End Location" : trip.route.endAddress)
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

                // Vehicle Info (read-only)
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

                // Cost Breakdown (editable split cost)
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Cost Breakdown", systemImage: "dollarsign.circle")
                            .font(.headline)
                        Divider()
                        HStack {
                            Text("Fuel Cost")
                                .font(.body)
                            Spacer()
                            Text("\(trip.currency.symbol)\(String(format: "%.2f", fuelCost))")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
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
                        if isEditing {
                            HStack {
                                Text("Split Among")
                                    .font(.body)
                                Spacer()
                                Stepper(value: $editedPeople, in: 1...100, step: 1) {
                                    Text("\(editedPeople) people")
                                }
                                .frame(width: 160)
                            }
                            HStack {
                                Text("Per Person")
                                    .font(.body)
                                Spacer()
                                Text("\(trip.currency.symbol)\(String(format: "%.2f", trip.cost / Double(editedPeople))) /person")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        } else if trip.numberOfPeople > 1 {
                            HStack {
                                Text("Split Among")
                                    .font(.body)
                                Spacer()
                                Text("\(trip.numberOfPeople) people")
                                    .font(.body)
                                Text("\(trip.currency.symbol)\(String(format: "%.2f", trip.costPerPerson))/person")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
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
                    .modifier(GlassCardModifier(config: .init(cornerRadius: 20)))
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
                
                // Weather
                if let weather = trip.destinationWeather {
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Destination Weather", systemImage: "cloud.sun.fill")
                                .font(.headline)
                            Divider()
                            HStack(spacing: 24) {
                                // Temperature & icon
                                HStack(spacing: 16) {
                                    Image(systemName: weather.sfSymbol)
                                        .font(.system(size: 48))
                                        .foregroundStyle(.cyan)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(Int(weather.temperatureInFahrenheit))°F")
                                            .font(.system(size: 32, weight: .bold))
                                        Text("\(Int(weather.temperature))°C")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // Condition details
                                VStack(alignment: .trailing, spacing: 8) {
                                    Text(weather.condition)
                                        .font(.headline)
                                    Text(weather.description.capitalized)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    if let humidity = weather.humidity {
                                        HStack(spacing: 4) {
                                            Image(systemName: "humidity.fill")
                                                .font(.caption)
                                            Text("\(humidity)%")
                                                .font(.caption)
                                        }
                                        .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }

                // Camping Checklist summary + link
                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Camping Checklist", systemImage: "checklist")
                                .font(.headline)
                            Spacer()
                            NavigationLink {
                                CampingChecklistView(trip: trip)
                            } label: {
                                Label("Open", systemImage: "square.and.pencil")
                            }
                            .buttonStyle(.automatic)
                            .controlSize(.small)
                        }
                        Divider()
                        let list = trip.campingChecklist ?? []
                        let total = list.count
                        let done = list.filter{ $0.isDone }.count
                        if total == 0 {
                            Text("No items yet. Click Open to start your checklist.")
                                .foregroundStyle(.secondary)
                        } else {
                            HStack {
                                ProgressView(value: Double(done), total: Double(total))
                                    .frame(maxWidth: 260)
                                Text("\(done)/\(total) done")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 4)
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(list.prefix(3)) { item in
                                    HStack(spacing: 8) {
                                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(item.isDone ? .green : .secondary)
                                        Text(item.title)
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .font(.subheadline)
                                }
                                if total > 3 {
                                    Text("+ \(total - 3) more…")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)

                // Actions
                HStack(spacing: 16) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    if isEditing {
                        Button {
                            // Save changes
                            var updatedTrip = trip
                            updatedTrip.numberOfPeople = editedPeople
                            updatedTrip.costPerPerson = trip.cost / Double(editedPeople)
                            viewModel.updateTrip(updatedTrip)
                            isEditing = false
                        } label: {
                            Label("Save", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            isEditing = true
                            editedPeople = trip.numberOfPeople
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
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
                    
                    ScrollView {
                        Text(generateShareText())
                            .font(.body)
                            .textSelection(.enabled)
                            .padding()
                            .background(.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(maxHeight: 260)
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
                
                #if os(macOS)
                if #available(macOS 13.0, *) {
                    ShareLink(item: generateShareText()) {
                        Label("Share…", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                #endif
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
        var splitText = ""
        if trip.numberOfPeople > 1 {
            splitText = "👥 Split: \(trip.numberOfPeople) people, \(trip.currency.symbol)\(String(format: "%.2f", trip.costPerPerson))/person\n"
        }
        var checklistBlock = ""
        let list = trip.campingChecklist ?? []
        if !list.isEmpty {
            let rendered = list.map { item in
                "- [\(item.isDone ? "x" : " ")] \(item.title)"
            }.joined(separator: "\n")
            checklistBlock = "\n🧭 Camping Checklist\n\(rendered)\n"
        }
        var weatherBlock = ""
        if let weather = trip.destinationWeather {
            weatherBlock = "\n☀️ Weather at Destination\n🌡️ \(Int(weather.temperatureInFahrenheit))°F (\(Int(weather.temperature))°C)\n\(weather.condition) - \(weather.description.capitalized)\n"
            if let humidity = weather.humidity {
                weatherBlock += "💧 Humidity: \(humidity)%\n"
            }
        }
        return """
        🚗 \(trip.name)
        
        📅 Date: \(dateStr)
        🗺️ Route: \(trip.route.startAddress) → \(trip.route.endAddress)
        📏 Distance: \(distance) miles
        🚙 Vehicle: \(trip.vehicle.displayName)
        💰 Total Cost: \(trip.currency.symbol)\(cost)
        \(splitText)
        \(trip.notes ?? "")
        \(weatherBlock)\(checklistBlock)
        """
    }
    
    private func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generateShareText(), forType: .string)
        #endif
    }
}
