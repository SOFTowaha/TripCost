import SwiftUI

struct CampingChecklistView: View {
    @Environment(SavedTripsViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let trip: SavedTrip

    @State private var items: [ChecklistItem] = []
    @State private var newItemTitle: String = ""
    @State private var isSharing: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Camping Checklist")
                    .font(.title2).bold()
                Spacer()
                Button {
                    shareChecklist()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .help("Share checklist as text")
            }
            .padding(.horizontal)

            HStack(spacing: 8) {
                TextField("Add an item", text: $newItemTitle)
                    .textFieldStyle(.roundedBorder)
                Button {
                    addItem()
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                .disabled(newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)

            List {
                ForEach($items) { $item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Toggle("", isOn: $item.isDone)
                            .toggleStyle(.checkbox)
                            .labelsHidden()
                            .frame(width: 24)
                        TextField("Item", text: $item.title)
                        Spacer()
                    }
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }
            .listStyle(.inset)

            HStack(spacing: 12) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Label("Close", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                Button {
                    save()
                } label: {
                    Label("Save", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding([.horizontal, .bottom])
        }
        .onAppear {
            items = trip.campingChecklist ?? []
        }
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

    private func save() {
        var updated = trip
        updated.campingChecklist = items
        viewModel.updateTrip(updated)
        dismiss()
    }

    private func shareChecklist() {
        #if os(macOS)
        let text = renderChecklistText(items)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
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
