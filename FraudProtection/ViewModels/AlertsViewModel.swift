// ... existing code ...

import Foundation

@MainActor
class AlertsViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var isLoading = false
    @Published var error: String?

    init() {
        Task {
            await fetchAlerts()
        }
    }

    func fetchAlerts() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        // TODO: Replace with real API call
        await Task.sleep(500_000_000) // Simulate network delay

        // Mock data for now
        alerts = [
            Alert(
                id: UUID().uuidString,
                title: "Suspicious Activity Detected",
                body: "We detected suspicious activity on your account.",
                mediaIds: [
                    .init(id: "1", url: "https://via.placeholder.com/150")
                ],
                createdAt: Date().timeIntervalSince1970 - 3600
            ),
            Alert(
                id: UUID().uuidString,
                title: "New Security Update",
                body: "A new security update is available.",
                mediaIds: [],
                createdAt: Date().timeIntervalSince1970 - 7200
            )
        ]
    }
}

// ... existing code ...