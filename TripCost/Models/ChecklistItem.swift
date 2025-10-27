import Foundation

struct ChecklistItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isDone: Bool
    var notes: String?

    init(id: UUID = UUID(), title: String, isDone: Bool = false, notes: String? = nil) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.notes = notes
    }
}
