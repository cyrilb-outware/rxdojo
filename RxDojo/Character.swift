//
//  Character.swift
//  RxTest
//
//  Created by Cyril Barthelet on 26/7/18.
//  Copyright © 2018 Outware. All rights reserved.
//

import Foundation

// Testable
public struct Character: Codable {
    public let name: String
    public let speciesUrl: URL
    
    private enum CodingKeys: String, CodingKey {
        case name
        case speciesUrl = "species"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        // Species is an url array that should always contain one url. Hard fail if not the case
        speciesUrl = try URL(string: values.decode([String].self, forKey: .speciesUrl).first!)!
    }
}

public struct CharactersResponse: Codable {
    public let characters: [Character]
    
    private enum CodingKeys: String, CodingKey {
        case characters = "results"
    }
}
