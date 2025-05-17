import Foundation

struct Message: Identifiable {
    let id = UUID()  // Unique identifier for Identifiable conformance
    let content: String
}
