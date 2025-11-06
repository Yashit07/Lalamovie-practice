//
//  Title.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 05/11/25.
//

import Foundation


struct APIObject: Decodable {
    var results: [Title] = []
}

struct Title: Decodable, Identifiable {
    var id: Int?
    var title: String?
    var name: String?
    var overview: String?
    var posterPath: String?
}
