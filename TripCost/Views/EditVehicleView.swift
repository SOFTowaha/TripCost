import SwiftUI

struct EditVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel: VehicleViewModel
    let vehicle: Vehicle

    @State private var cityMPG = ""
    @State private var highwayMPG = ""
    @State private var combinedMPG = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    vehicleInfoCard
                    mpgCard
                    Button {
                        saveChanges()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Changes")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
                        )
                        .foregroundStyle(.green)
                        .shadow(color: .green.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isFormValid)
                }
                .padding(24)
            }
            .background(
                Rectangle()
                    .fill(.thinMaterial)
                    .ignoresSafeArea()
            )
            .navigationTitle("Edit Vehicle")
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
            .onAppear {
                cityMPG = String(vehicle.cityMPG)
                highwayMPG = String(vehicle.highwayMPG)
                combinedMPG = String(vehicle.combinedMPG)
            }
        }
    }

    private var isFormValid: Bool {
        Double(cityMPG) != nil && Double(highwayMPG) != nil && Double(combinedMPG) != nil
    }

    private func saveChanges() {
        guard let city = Double(cityMPG), let highway = Double(highwayMPG), let combined = Double(combinedMPG) else { return }
        viewModel.updateVehicleMPG(vehicle, cityMPG: city, highwayMPG: highway, combinedMPG: combined)
        dismiss()
    }

    private var vehicleInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "car.fill")
                    .foregroundStyle(.blue)
                Text("Vehicle")
                    .font(.headline)
            }
            LabeledContent("Make", value: vehicle.make)
            LabeledContent("Model", value: vehicle.model)
            LabeledContent("Year", value: String(vehicle.year))
            LabeledContent("Fuel Type", value: vehicle.fuelType.rawValue)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var mpgCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "gauge.with.dots.needle.67percent")
                    .foregroundStyle(.green)
                Text("Edit Fuel Efficiency (MPG)")
                    .font(.headline)
            }
            TextField("City MPG", text: $cityMPG)
                .textFieldStyle(.roundedBorder)
            TextField("Highway MPG", text: $highwayMPG)
                .textFieldStyle(.roundedBorder)
            TextField("Combined MPG", text: $combinedMPG)
                .textFieldStyle(.roundedBorder)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}