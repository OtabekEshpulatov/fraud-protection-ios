//
//  AlertsView.swift
//  FraudProtection
//
//  Created by kebato OS on 06/05/25.
//


// ... existing code ...

import SwiftUI

struct AlertsView: View {
    @StateObject private var viewModel = AlertsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if viewModel.notifications.isEmpty {
                    Text("No alerts available.")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.notifications) { notification in
                        NavigationLink(destination: NotificationDetailView(notification: notification)
                            .environmentObject(viewModel)) {
                            VStack(alignment: .leading) {
                                Text(notification.title)
                                    .font(.headline)
                                Text(notification.body)
                                    .font(.body)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Alerts")
            .refreshable {
                await viewModel.fetchNotifications()
                await viewModel.fetchUnreadCount()
            }
        }
    }
}

struct NotificationDetailView: View {
    let notification: Notification
    @EnvironmentObject var viewModel: AlertsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(notification.title)
                    .font(.title)
                    .bold()
                Text(notification.body)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Notification Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.markAsRead(id: notification.id)
        }
    }
}

// ... existing code ...
