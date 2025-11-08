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

struct Title: Decodable, Identifiable, Hashable {
    var id: Int?
    var title: String?
    var name: String?
    var overview: String?
    var posterPath: String?
    
    static var preiviewTtiles = [
        Title(id: 1, title: "Chennai Express", name: "Chennai Express", overview: "A movie about a train journey", posterPath: Constants.testTitleURL),
        Title(id: 2, title: "Pulp Fiction", name: "Pulp Fiction", overview: "A movie about Pulp Fiction", posterPath: Constants.testTitleURL2),
        Title(id: 3, title: "The Dark Knight", name: "The Dark Knight", overview: "A movie about Batman", posterPath: Constants.testTitleURL3)
    ]
}
