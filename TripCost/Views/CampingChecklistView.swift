import SwiftUI
import Foundation

struct CampingChecklistView: View {
    @Environment(SavedTripsViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let trip: SavedTrip

    @State private var items: [ChecklistItem] = []
    @State private var newItemTitle: String = ""
    @State private var isSharing: Bool = false
    @State private var searchText: String = ""
    @State private var selection = Set<UUID>()

    private var filteredItems: [ChecklistItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return items }
        return items.filter { $0.title.localizedCaseInsensitiveContains(q) || ($0.notes ?? "").localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Bar
            HStack(spacing: 12) {
                Text("Camping Checklist").font(TCTypography.title)
                Spacer()
                // Progress
                let done = items.filter { $0.isDone }.count
                let total = max(items.count, 1)
                ProgressView(value: Double(done), total: Double(total))
                    .frame(width: 180)
                    .help("\(done)/\(items.count) done")
                Text("\(done)/\(items.count)")
                    .font(TCTypography.caption)
                    .foregroundStyle(TCColor.textSecondary)
                // Share button
                Button { shareChecklist() } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(GlassButtonStyle())
            }
            .padding(.horizontal)

            // Add / Templates / Search
            HStack(spacing: 8) {
                TextField("Add an item", text: $newItemTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addItem() }
                Button(action: addItem) {
                    Label("Add", systemImage: "plus")
                }
                .buttonStyle(GlassButtonStyle())
                .keyboardShortcut(.return)
                Menu {
                    Button("Base Camping Kit") { insertTemplate(.base) }
                    Button("Cooking Kit") { insertTemplate(.cooking) }
                    Button("Hiking Essentials") { insertTemplate(.hiking) }
                } label: {
                    Label("Templates", systemImage: "list.bullet.rectangle")
                }
                .buttonStyle(GlassButtonStyle())
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass").foregroundStyle(TCColor.textSecondary)
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)
                        .frame(width: 220)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(TCColor.surfaceAlt.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(TCColor.divider, lineWidth: 1)
                )
            }
            .padding(.horizontal)

            // List of items (macOS feel)
            GroupBox {
                List {
                    ForEach(filteredItems) { item in
                        checklistRow(for: item)
                            .contextMenu {
                                Button(item.isDone ? "Mark as Not Done" : "Mark as Done") {
                                    toggleDone(item.id)
                                }
                                Divider()
                                Button(role: .destructive) { deleteById(item.id) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onMove(perform: moveFiltered)
                    .onDelete(perform: deleteFiltered)
                }
                .listStyle(.inset)
            }
            .tcGlassCard(cornerRadius: 14)
            .padding(.horizontal)

            // Bottom actions
            HStack(spacing: 12) {
                Button(role: .cancel) { dismiss() } label: {
                    Label("Close", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                Button(action: save) {
                    Label("Save", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding([.horizontal, .bottom])
        }
        .tcGlassBackground()
        .onAppear { items = trip.campingChecklist ?? [] }
        .navigationTitle("Checklist")
    }

    private func addItem() {
        let title = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        items.append(ChecklistItem(title: title))
        newItemTitle = ""
    }

    private func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    private func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func deleteById(_ id: UUID) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: idx)
        }
    }

    private func toggleDone(_ id: UUID) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items[idx].isDone.toggle()
        }
    }

    // Moving/deleting when filtered requires mapping indices back to the original items array
    private func moveFiltered(from source: IndexSet, to destination: Int) {
        let visible = filteredItems
        var originalIndices = IndexSet()
        for i in source { let id = visible[visible.index(visible.startIndex, offsetBy: i)].id
            if let idx = items.firstIndex(where: { $0.id == id }) { originalIndices.insert(idx) }
        }
        var destId: UUID?
        if destination < visible.count { destId = visible[visible.index(visible.startIndex, offsetBy: destination)].id }
        let dest = destId.flatMap { id in items.firstIndex(where: { $0.id == id }) } ?? items.endIndex
        items.move(fromOffsets: originalIndices, toOffset: dest)
    }

    private func deleteFiltered(at offsets: IndexSet) {
        let visible = filteredItems
        let ids = offsets.map { visible[visible.index(visible.startIndex, offsetBy: $0)].id }
        items.removeAll { ids.contains($0.id) }
    }

    private func save() {
        var updated = trip
        updated.campingChecklist = items
        viewModel.updateTrip(updated)
        dismiss()
    }

    private func shareChecklist() {
        #if os(macOS)
        let text = renderChecklistText(items)
        if #available(macOS 13.0, *) {
            // Prefer ShareLink in the UI layer; here we provide a quick copy fallback
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
        } else {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
        }
        #endif
    }

    private func renderChecklistText(_ items: [ChecklistItem]) -> String {
        var lines: [String] = ["🧭 Camping Checklist"]
        for item in items {
            lines.append("- [\(item.isDone ? "x" : " ")] \(item.title)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Row View
private extension CampingChecklistView {
    @ViewBuilder
    func checklistRow(for item: ChecklistItem) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Toggle("", isOn: Binding(get: {
                items.first(where: { $0.id == item.id })?.isDone ?? false
            }, set: { newValue in
                if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx].isDone = newValue }
            }))
            .toggleStyle(.checkbox)
            .labelsHidden()
            .frame(width: 24)

            TextField("Item", text: Binding(get: {
                items.first(where: { $0.id == item.id })?.title ?? ""
            }, set: { newValue in
                if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx].title = newValue }
            }))

            Spacer(minLength: 12)

            TextField("Notes", text: Binding(get: {
                items.first(where: { $0.id == item.id })?.notes ?? ""
            }, set: { newValue in
                if let idx = items.firstIndex(where: { $0.id == item.id }) { items[idx].notes = newValue.isEmpty ? nil : newValue }
            }))
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: 260)

            Button(role: .destructive) { deleteById(item.id) } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help("Delete item")
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Templates
private enum ChecklistTemplate { case base, cooking, hiking }

private extension CampingChecklistView {
    func insertTemplate(_ template: ChecklistTemplate) {
        let itemsToAdd: [String]
        switch template {
        case .base:
            itemsToAdd = [
                "Tent", "Sleeping bag", "Sleeping pad", "Pillow",
                "Headlamp/flashlight", "First aid kit", "Water bottle"
            ]
        case .cooking:
            itemsToAdd = [
                "Camp stove", "Fuel", "Lighter/Matches", "Cookset/Pot",
                "Utensils", "Mug", "Soap/Sponge"
            ]
        case .hiking:
            itemsToAdd = [
                "Map/Compass", "Snacks", "Extra water", "Rain jacket",
                "Extra layers", "Sun protection", "Multi-tool"
            ]
        }
        let newOnes = itemsToAdd.map { ChecklistItem(title: $0) }
        items.append(contentsOf: newOnes)
    }
}
