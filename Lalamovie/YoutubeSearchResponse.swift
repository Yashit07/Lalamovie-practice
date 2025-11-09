//
//  YoutubeSearchResponse.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 09/11/25.
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [ItemProperties]?
}

struct ItemProperties: Codable {
    let id: IdProperties?
}

struct IdProperties: Codable {
    let videoId: String?
}
