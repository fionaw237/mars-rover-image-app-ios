//
//  ViewController.swift
//  Mars_Rover_Images
//
//  Created by Fiona Wilson on 04/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var earthDateLabel: UILabel!
    @IBOutlet weak var solTextField: UITextField!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var cameraPicker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var roverSelector: UISegmentedControl!
    
    let networkManager = NetworkManager()
    var photoManager = PhotoManager(
        context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSolTextField()
        configureTapGesture()
        Task {
            await fetchData(sol: photoManager.defaultSol, rover: photoManager.chosenRover.rawValue)
        }
    }
    
    //MARK: Methods handling fetching of data
    
    private func fetchData(sol: Int, rover: String) async {
        photoManager.fetchLocalData(sol, rover)
        if photoManager.allPhotos.isEmpty {
            await fetchDataRemotely(sol, rover)
        } else {
            setUpCameraPicker()
            configureNumberOfPhotosLabel()
            configureEarthDateLabel()
            tableView.reloadData()
        }
    }

    private func fetchDataRemotely(_ sol: Int, _ rover: String) async {
        activityIndicator.startAnimating()
        numberOfPhotosLabel.isHidden = true
        do {
            let result = try await networkManager.fetchData(sol: sol, rover: rover, context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            handleDataFetched(result: result)
        } catch let error {
            guard let message = (error as? DataFetchError)?.rawValue else {
                return
            }
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
            present(alertController, animated: true)
            numberOfPhotosLabel.text = "Unable to dsplay images."
            activityIndicator.stopAnimating()
            numberOfPhotosLabel.isHidden = false
            photoManager.allPhotos = []
        }
    }
    
    private func handleDataFetched(result: [Photo]) {
        handleDataFetchSuccess(result)
        activityIndicator.stopAnimating()
        numberOfPhotosLabel.isHidden = false
    }
    
    private func handleDataFetchSuccess(_ photos: [Photo]) {
        photoManager.setPhotoArrays(photos)
        setUpCameraPicker()
        configureNumberOfPhotosLabel()
        configureEarthDateLabel()
        tableView.reloadData()
    }
    
    private func clearDisplayedData() {
        photoManager.resetData()
        earthDateLabel.text = ""
        tableView.reloadData()
        cameraPicker.reloadAllComponents()
    }
    
    // MARK: Methods for handling tap gesture
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotosViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    // MARK: Methods for configuring sol and earth date labels
    
    private func configureNumberOfPhotosLabel() {
        numberOfPhotosLabel.text = photoManager.numberOfPhotosInfoMessage
    }
    
    private func configureEarthDateLabel() {
        earthDateLabel.text = photoManager.earthDateLabelText
    }
    
    // MARK: Changing rover
    
    @IBAction func roverSelected(_ sender: Any) {
        photoManager.chosenRover = RoverName(index: roverSelector.selectedSegmentIndex)
        clearDisplayedData()
        Task {
            await fetchData(sol: photoManager.currentSol, rover: photoManager.chosenRover.rawValue)
        }
    }
}


//MARK: Table view methods
extension PhotosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoManager.displayedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        cell.setPhotoProperties(photoManager.displayedPhotos[indexPath.row])
        return cell
    }
}


// MARK: Picker view methods
extension PhotosViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func setUpCameraPicker() {
        cameraPicker.reloadAllComponents()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return photoManager.cameraNames.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return photoManager.cameraNames[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        photoManager.handleSelectedCameraChanged(photoManager.cameraNames[row])
        tableView.reloadData()
        configureNumberOfPhotosLabel()
    }
}


// MARK: Methods for sol text field
extension PhotosViewController: UITextFieldDelegate {
    
    private func configureSolTextField() {
        solTextField.text = "\(photoManager.defaultSol)"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newSol = solTextField.text, let newSolInt = Int(newSol) else {return}
        if !photoManager.isSolInputValid(newSolInt) {
            handleInvalidSolInput()
        } else if photoManager.changeFromCurrentSol(newSolInt)  {
            Task {
                await handleValidSolInput(newSolInt)
            }
        }
    }
    
    private func handleValidSolInput(_ newSol: Int) async {
        photoManager.setCurrentSol(newSol)
        clearDisplayedData()
        await fetchData(sol: newSol, rover: photoManager.chosenRover.rawValue)
    }
    
    private func handleInvalidSolInput() {
        numberOfPhotosLabel.text = photoManager.numberOfPhotosInfoMessageInvalidSol
        clearDisplayedData()
    }
}
