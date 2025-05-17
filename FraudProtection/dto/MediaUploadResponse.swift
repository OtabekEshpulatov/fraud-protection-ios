//
//  MediaUploadResponse.swift
//  FraudProtection
//
//  Created by kebato OS on 05/05/25.
//

import Foundation
import Photos
import PhotosUI

struct MediaUploadResponse: Codable {
    let fileId: String
    let fileUrl: String
}

struct PostRequestDto: Codable {
    let title: String
    let body: String
    let mediaIds: [String]
    let regionId: String
}

struct RegionDto: Codable, Identifiable, Hashable, Equatable {
    let id: String
    let names: [RegionLocalizedName]
}

struct RegionLocalizedName: Codable,Hashable, Equatable {
    let locale: String
    let name: String
}

struct MediaFile: Identifiable {
    let id = UUID()
    let url: URL
}

