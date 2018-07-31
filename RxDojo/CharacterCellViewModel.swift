//
//  CharacterCellViewModel.swift
//  RxTest
//
//  Created by Cyril Barthelet on 24/7/18.
//  Copyright © 2018 Outware. All rights reserved.
//

import Foundation
import RxSwift

public class CharacterCellViewModel: Hashable {
    
    private let character: Character
    private let showSpeciesObserver: AnyObserver<URL>
    
    public var name: String { return character.name }
    
    public var hashValue: Int = UUID().uuidString.hashValue
    
    init(character: Character, showSpeciesObserver: AnyObserver<URL>) {
        self.character = character
        self.showSpeciesObserver = showSpeciesObserver
    }
    
    func select() {
        showSpeciesObserver.onNext(character.speciesUrl)
    }
    
}

public func == (lhs: CharacterCellViewModel, rhs: CharacterCellViewModel) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
