//
//  Message.swift
//  FraudProtection
//
//  Created by kebato OS on 05/05/25.
//


import Foundation

struct Message: Identifiable {
    let id = UUID()  // Unique identifier for Identifiable conformance
    let content: String
}
