nonisolated struct GlobalOperation: Sendable {
    var status: GlobalOperationStatus
    var title: String
    var systemImage: String
    var completed: Int
    var total: Int
    var failed: Int
}
