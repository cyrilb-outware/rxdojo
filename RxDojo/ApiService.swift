//
//  ApiService.swift
//  RxTest
//
//  Created by Cyril Barthelet on 26/7/18.
//  Copyright © 2018 Outware. All rights reserved.
//

import Foundation
import RxSwift

class ApiService {
    
    private let baseURL = "https://swapi.co/api/"
    
    func characters() -> Observable<[Character]> {
        let url = URL(string: self.baseURL + "people")!
        return requestObservable(CharactersResponse.self, with: url)
            .map { $0.characters }
    }
    
    func species(url: URL) -> Observable<Species> {
        return requestObservable(Species.self, with: url)
    }
    
    private func requestObservable<T>(_ type: T.Type, with url: URL) -> Observable<T> where T: Decodable {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return Observable.create { observer in
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    let response = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(response)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}
