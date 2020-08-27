//
//  ViewController.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 04/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var earthDateLabel: UILabel!
    @IBOutlet weak var solTextField: UITextField!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var cameraPicker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var roverSelector: UISegmentedControl!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let networkManager = NetworkManager()
    var photoManager = PhotoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSolTextField()
        configureTapGesture()
        fetchData(sol: photoManager.defaultSol, rover: photoManager.chosenRover.rawValue, context: context)
    }
    
    //MARK: Methods handling fetching of data
    
    private func fetchData(sol: Int, rover: String, context: NSManagedObjectContext) {
        let fetchedPhotos = getLocalData(sol, rover)
        if fetchedPhotos.isEmpty {
            fetchDataRemotely(sol, rover, context)
        } else {
            photoManager.allPhotos = fetchedPhotos
            photoManager.displayedPhotos = photoManager.allPhotos
            setUpCameraPicker()
            configureNumberOfPhotosLabel()
            configureEarthDateLabel()
            tableView.reloadData()
        }
    }
    
    private func getLocalData(_ sol: Int, _ rover: String) -> [Photo] {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        let solPredicate = NSPredicate(format: "%K == \(sol)", #keyPath(Photo.sol))
        let roverPredicate = NSPredicate(format: "%K == \"\(rover)\"", #keyPath(Photo.rover.name))
        request.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [solPredicate, roverPredicate])
        do {
            return try context.fetch(request)
          } catch let error as NSError {
            print("Error fetching local data \(error), \(error.userInfo)")
            return []
          }
    }

    private func fetchDataRemotely(_ sol: Int, _ rover: String, _ context: NSManagedObjectContext) {
        activityIndicator.startAnimating()
        numberOfPhotosLabel.isHidden = true
        networkManager.fetchData(sol: sol, rover: rover, context: context) { (result) in
            self.handleDataFetched(result: result)
        }
    }
    
    private func handleDataFetched(result: Result<[Photo], Error>) {
        switch result {
        case .success(let photos):
            handleDataFetchSuccess(photos)
        case .failure(let error):
            handleDataFetchFailure(error)
        }
        activityIndicator.stopAnimating()
        numberOfPhotosLabel.isHidden = false
    }
    
    private func handleDataFetchSuccess(_ photos: [Photo]) {
        photoManager.allPhotos = photos
        photoManager.displayedPhotos = photoManager.allPhotos
        setUpCameraPicker()
        configureNumberOfPhotosLabel()
        configureEarthDateLabel()
        tableView.reloadData()
    }
    
    private func handleDataFetchFailure(_ error: Error) {
        numberOfPhotosLabel.text = error.localizedDescription
    }
    
    private func clearDisplayedData() {
        photoManager.resetData()
        earthDateLabel.text = ""
        tableView.reloadData()
        cameraPicker.reloadAllComponents()
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
        numberOfPhotosLabel.text = photoManager.numberOfPhotosInfoMessage
    }
    
    private func configureEarthDateLabel() {
        earthDateLabel.text = photoManager.earthDateLabelText
    }
    
    // MARK: Changing rover
    
    @IBAction func roverSelected(_ sender: Any) {
        photoManager.chosenRover = RoverName(index: roverSelector.selectedSegmentIndex)
        clearDisplayedData()
        fetchData(sol: photoManager.currentSol, rover: photoManager.chosenRover.rawValue, context: context)
    }
}


//MARK: Table view methods
extension ViewController: UITableViewDataSource {
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
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
extension ViewController: UITextFieldDelegate {
    
    private func configureSolTextField() {
        solTextField.text = "\(photoManager.defaultSol)"
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let newSol = solTextField.text, let newSolInt = Int(newSol) else {return}
        if !photoManager.isSolInputValid(newSolInt) {
            handleInvalidSolInput()
        } else if photoManager.changeFromCurrentSol(newSolInt)  {
            handleValidSolInput(newSolInt)
        }
    }
    
    private func handleValidSolInput(_ newSol: Int) {
        photoManager.setCurrentSol(newSol)
        clearDisplayedData()
        fetchData(sol: newSol, rover: photoManager.chosenRover.rawValue, context: context)
    }
    
    private func handleInvalidSolInput() {
        numberOfPhotosLabel.text = photoManager.numberOfPhotosInfoMessageInvalidSol
        clearDisplayedData()
    }
}
