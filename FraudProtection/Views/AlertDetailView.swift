//
//  AlertDetailView.swift
//  FraudProtection
//
//  Created by kebato OS on 06/05/25.
//


// ... existing code ...

import SwiftUI

struct AlertDetailView: View {
    let alert: Alert

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(alert.title)
                    .font(.title)
                    .bold()
                Text(alert.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(alert.body)
                    .font(.body)
                if !alert.mediaIds.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(alert.mediaIds) { media in
                                AsyncImage(url: URL(string: media.url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 200, height: 120)
                                .clipped()
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Alert Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ... existing code ...