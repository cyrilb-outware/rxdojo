//
//  ViewController.swift
//  RxTest
//
//  Created by Cyril Barthelet on 24/7/18.
//  Copyright © 2018 Outware. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private let cellReuseIdentifier = "CharacterTableViewCell"
    
    var viewModel = ViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    private let disposeBag = DisposeBag()
    
    var dataSource: [CharacterCellViewModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        searchTextField.delegate = self
        
        searchTextField.rx.text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .bind(to: viewModel.searchValue)
            .disposed(by: disposeBag)
        
        viewModel.titleObservable
            .subscribe(onNext: { [weak self] in self?.title = $0 })
            .disposed(by: disposeBag)
        
        viewModel.cellViewModelsObservable
            .subscribe(onNext: { [weak self] in self?.dataSource = $0 })
            .disposed(by: disposeBag)
        
        viewModel.errorObservable
            .subscribe(onNext: { [weak self] error in
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                    self?.viewModel.refresh()
                }))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.showSpeciesObservable
            .subscribe(onNext: { [weak self] birthYear in
                let alert = UIAlertController(title: birthYear, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    // TableView

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSource[indexPath.row].select()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! CharacterTableViewCell
        cell.viewModel = dataSource[indexPath.row]
        return cell
    }
    
    // TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }

}

class CharacterTableViewCell: UITableViewCell {
    var viewModel: CharacterCellViewModel? {
        didSet {
            textLabel?.text = viewModel?.name ?? ""
        }
    }
}
