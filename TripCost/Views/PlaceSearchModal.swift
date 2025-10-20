import SwiftUI
import MapKit

struct PlaceSearchModal: View {
    let title: String
    @Bindable var searchVM: SearchViewModel
    var onPick: (MKMapItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { searchVM.query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

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
            .padding(.horizontal, 24)
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
            .padding(.horizontal, 24)
            .padding(.bottom, 2)

            // Single-column results
            if !searchVM.suggestions.isEmpty && !searchVM.query.isEmpty {
                ScrollView {
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
                .padding(.horizontal, 24)
            }
            Spacer()
        }
        .frame(minWidth: 400, maxWidth: 600, minHeight: 400, maxHeight: 600)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 8)
        )
    }
}