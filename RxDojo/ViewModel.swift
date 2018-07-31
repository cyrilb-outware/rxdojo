//
//  ViewModel.swift
//  RxTest
//
//  Created by Cyril Barthelet on 24/7/18.
//  Copyright © 2018 Outware. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel {

    private let apiService = ApiService()
    
    var titleObservable: Observable<String> { return titleVariable.asObservable() }
    private let titleVariable = Variable<String>("")
    
    var cellViewModelsObservable: Observable<[CharacterCellViewModel]> {
        return Observable.combineLatest(cellViewModelsVariable.asObservable(), searchValue.asObservable())
            { (cells, search) in
                cells.filter { cell in
                    guard !search.isEmpty else { return true }
                    return cell.name.lowercased().contains(search.lowercased())
                }
            }
            .distinctUntilChanged()
    }
    private let cellViewModelsVariable = Variable<[CharacterCellViewModel]>([])
    
    var errorObservable: Observable<String> {
        return errorVariable.asObservable()
            .filter { $0 != nil }
            .map { _ in "Oops! An error occured." }
    }
    private let errorVariable = Variable<Error?>(nil)
    
    let searchValue = Variable("")
    
    var showSpeciesObservable: Observable<String> {
        return showSpeciesSubject
            .flatMapLatest { [weak self] url -> Observable<String> in
                guard let strongSelf = self else { return Observable.never() }
                return strongSelf.speciesName(for: url)
            }
    }
    private let showSpeciesSubject = PublishSubject<URL>()
    
    private let disposeBag = DisposeBag()
    private var requestDisposable: Disposable?
    
    init() {
        refresh()
    }
    
    func refresh() {
        titleVariable.value = "Loading..."
        errorVariable.value = nil
        
        requestDisposable?.dispose()
        requestDisposable = apiService.characters()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] characters in
                    guard let strongSelf = self else { return }
                    strongSelf.titleVariable.value = "Star Wars Characters"
                    strongSelf.cellViewModelsVariable.value = characters.map { character in
                        CharacterCellViewModel(character: character,
                                               showSpeciesObserver: strongSelf.showSpeciesSubject.asObserver())
                    }
                },
                onError: { [weak self] error in
                    self?.errorVariable.value = error
                })
        requestDisposable?.disposed(by: disposeBag)
    }
    
    private func speciesName(for url: URL) -> Observable<String> {
        return apiService.species(url: url)
            .observeOn(MainScheduler.instance)
            .map { "I'm a \($0.name)!" }
    }

}
