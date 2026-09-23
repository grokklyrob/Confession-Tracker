import Foundation

@Observable
final class ConfessionsModel {
    var path: [EntryRoute] = []
    var pendingDeletionID: UUID?
    var now = Date()
}
