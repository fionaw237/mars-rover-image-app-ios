//
//  ViewController.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 04/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var earthDateLabel: UILabel!
    @IBOutlet weak var solTextField: UITextField!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var cameraPicker: UIPickerView!
    
    var allPhotos: [PhotoDto] = []
    var displayedPhotos: [PhotoDto] = []
    var cameraNames: [String] = []
    let defaultSol = 1
    var currentSol = 1
    let minSol = 1
    let maxSol = 2500
    let chosenRover = "Curiosity"
    let apiRequest = APIRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSolTextField()
        configureTapGesture()
        fetchData(sol: defaultSol, rover: chosenRover)
    }
    
    //MARK: Methods handling fetching of data
    
    private func fetchData(sol: Int, rover: String) {
        numberOfPhotosLabel.text = "Fetching images for sol \(sol)..."
        apiRequest.fetchData(sol: sol, rover: chosenRover) { (result) in
            self.handleDataFetched(result: result)
        }
    }
    
    private func handleDataFetched(result: Result<[PhotoDto], Error>) {
        switch result {
        case .success(let photos):
            handleDataFetchSuccess(photos)
        case .failure(let error):
            handleDataFetchFailure(error)
        }
    }
    
    private func handleDataFetchSuccess(_ photos: [PhotoDto]) {
        allPhotos = photos
        displayedPhotos = allPhotos
        setUpCameraPicker()
        configureNumberOfPhotosLabel()
        configureEarthDateLabel()
        tableView.reloadData()
    }
    
    private func handleDataFetchFailure(_ error: Error) {
        numberOfPhotosLabel.text = error.localizedDescription
    }
    
    //MARK: TableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        cell.setPhotoProperties(displayedPhotos[indexPath.row])
        return cell
    }
    
    // MARK: Picker view methods
    
    private func setUpCameraPicker() {
        self.cameraNames = Array(Set(allPhotos.map {$0.camera.name}))
        self.cameraNames.insert("All", at: 0)
        self.cameraPicker.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cameraNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cameraNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCamera = cameraNames[row]
        switch selectedCamera {
        case "All":
            displayedPhotos = allPhotos
        default:
            displayedPhotos = allPhotos.filter { $0.camera.name == selectedCamera }
        }
        tableView.reloadData()
        configureNumberOfPhotosLabel()
    }
    
    // MARK: Methods for handling tap gesture
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    // MARK: Methods for configuring sol and earth date labels
    
    private func configureNumberOfPhotosLabel() {
        numberOfPhotosLabel.text = "\(displayedPhotos.count) photo(s) found."
    }
    
    private func configureEarthDateLabel() {
        earthDateLabel.text = allPhotos.count > 0 ? allPhotos[0].earthDate : ""
    }
    
    // MARK: Methods for sol text field
    
    private func configureSolTextField() {
        solTextField.text = "\(defaultSol)"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newSol = solTextField.text, let newSolInt = Int(newSol) else {return}
        if !(minSol...maxSol).contains(newSolInt) {
            handleInvalidSolInput()
        } else if newSolInt != currentSol {
            handleValidSolInput(newSolInt)
        }
    }
    
    private func handleValidSolInput(_ newSol: Int) {
        currentSol = newSol
        clearDisplayedData()
        fetchData(sol: newSol, rover: chosenRover)
    }
    
    private func handleInvalidSolInput() {
        numberOfPhotosLabel.text = "Please enter a sol between \(minSol) and \(maxSol)"
        clearDisplayedData()
    }
    
    private func clearDisplayedData() {
        displayedPhotos = []
        allPhotos = []
        cameraNames = []
        earthDateLabel.text = ""
        tableView.reloadData()
        cameraPicker.reloadAllComponents()
    }
}

