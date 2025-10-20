//
//  SearchViewModel.swift
//  TripCost
//
//  Created by Syed Omar Faruk Towaha on 2025-10-20.
//

import Foundation
import MapKit

@MainActor
@Observable
class SearchViewModel: NSObject, MKLocalSearchCompleterDelegate {
    var query = ""
    var suggestions: [MKLocalSearchCompletion] = []
    var isSearching = false
    var errorMessage: String?
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address // or .pointOfInterest, .query
    }

    func updateQuery(_ text: String) {
        query = text
        completer.queryFragment = text
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> MKMapItem? {
        isSearching = true
        defer { isSearching = false }
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            return response.mapItems.first
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
