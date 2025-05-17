//
//  NoSpacingLabelStyle.swift
//  FraudProtection
//
//  Created by kebato OS on 06/05/25.
//
import SwiftUI

struct NormalSpacingLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) { // 👈 zero spacing
            configuration.icon
            configuration.title
        }
    }
}
