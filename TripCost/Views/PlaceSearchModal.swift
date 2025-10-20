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
                    .fontWeight(.bold)
                Spacer()
                Button(action: { searchVM.query = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.title2)
                TextField("Search for a place or address", text: $searchVM.query)
                    .textFieldStyle(.plain)
                    .font(.title3)
                    .padding(.vertical, 12)
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
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Single-column results with glass design
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
                                HStack(spacing: 14) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.title3)
                                    VStack(alignment: .leading, spacing: 3) {
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
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.clear)
                                )
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            if suggestion != searchVM.suggestions.last {
                                Divider()
                                    .padding(.leading, 50)
                                    .opacity(0.5)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                .frame(maxWidth: 600, maxHeight: 360)
                .padding(.horizontal, 28)
            }
            Spacer()
        }
        .frame(minWidth: 400, maxWidth: 600, minHeight: 400, maxHeight: 600)
        .background(.thinMaterial)
    }
}