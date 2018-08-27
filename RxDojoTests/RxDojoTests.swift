//
//  RxDojoTests.swift
//  RxDojoTests
//
//  Created by Cyril Barthelet on 31/7/18.
//  Copyright © 2018 Outware. All rights reserved.
//

import XCTest
import RxDojo

class RxDojoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCharacter() {
        if let path = Bundle.main.path(forResource: "Character", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let response = try JSONDecoder().decode(CharactersResponse.self, from: data)
                XCTAssertEqual(response.characters.count, 1)
                
                let character = response.characters.first!
                XCTAssertEqual(character.name, "Luke Skywalker")
                XCTAssertEqual(character.speciesUrl, URL(string: "https://swapi.co/api/species/1/")!)
            } catch {
                print("Failed to load JSON")
            }
        }
    }
    
}
