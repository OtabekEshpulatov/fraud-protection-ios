// ... existing code ...

import SwiftUI

struct AlertsView: View {
    @StateObject private var viewModel = AlertsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.alerts.isEmpty {
                    ProgressView()
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.alerts.isEmpty {
                    Text("No alerts available.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.alerts) { alert in
                        NavigationLink(destination: AlertDetailView(alert: alert)) {
                            VStack(alignment: .leading) {
                                Text(alert.title)
                                    .font(.headline)
                                Text(alert.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(alert.body)
                                    .font(.body)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Alerts")
        }
    }
}

// ... existing code ...