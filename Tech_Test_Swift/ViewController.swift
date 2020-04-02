//
//  ViewController.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 04/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var earthDateLabel: UILabel!
    @IBOutlet weak var solTextField: UITextField!
    
    var photos: [PhotoDto] = []
    let defaultSol = 1
    let chosenRover = "Curiosity"
    let apiRequest = APIRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSolTextField()
        configureTapGesture()
        fetchData(sol: defaultSol, rover: chosenRover)
    }
    
    // MARK: Methods for sol text field
    
    private func configureSolTextField() {
        solTextField.delegate = self
        solTextField.text = "\(defaultSol)"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        fetchData(sol: 5, rover: chosenRover)
    }
    
    // MARK: Methods for handling tap gesture
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    //MARK: Methods handling fetching of data
    
    fileprivate func fetchData(sol: Int, rover: String) {
        apiRequest.fetchData(sol: defaultSol, rover: chosenRover) { (result) in
            self.handleDataFetched(result: result)
        }
    }
    
    fileprivate func handleDataFetched(result: Result<[PhotoDto], Error>) {
        switch result {
        case .success(let photos):
            self.handleDataFetchSuccess(photos)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    fileprivate func handleDataFetchSuccess(_ photos: [PhotoDto]) {
        self.photos = photos
        self.earthDateLabel.text = self.photos.count > 0 ? self.photos[0].earthDate : ""
        self.tableView.reloadData()
    }
    
    //MARK: TableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        cell.setPhotoProperties(photos[indexPath.row])
        return cell
    }

}

