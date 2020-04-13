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
    
    var managedObjectContext: NSManagedObjectContext!
    var allPhotos: [Photo] = []
    var displayedPhotos: [Photo] = []
    var cameraNames: [String] = []
    let defaultSol = 1
    var currentSol = 1
    let minSol = 1
    let maxSol = 2500
    var chosenRover = RoverName.Curiosity
    let apiRequest = APIRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setManagedObjectContext()
        configureSolTextField()
        configureTapGesture()
        fetchData(sol: defaultSol, rover: chosenRover.rawValue, context: managedObjectContext)
    }
    
    private func setManagedObjectContext() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate?.persistentContainer.viewContext
    }
    
    //MARK: Methods handling fetching of data
    
    private func fetchData(sol: Int, rover: String, context: NSManagedObjectContext) {
        let fetchedPhotos = getLocalData(sol, rover)
        if fetchedPhotos.isEmpty {
            fetchDataRemotely(sol, rover, context)
        } else {
            allPhotos = fetchedPhotos
            displayedPhotos = allPhotos
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
            return try managedObjectContext.fetch(request)
          } catch let error as NSError {
            print("Error fetching local data \(error), \(error.userInfo)")
            return []
          }
    }

    private func fetchDataRemotely(_ sol: Int, _ rover: String, _ context: NSManagedObjectContext) {
        activityIndicator.startAnimating()
        numberOfPhotosLabel.isHidden = true
        apiRequest.fetchData(sol: sol, rover: rover, context: context) { (result) in
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
    
    private func clearDisplayedData() {
        displayedPhotos = []
        allPhotos = []
        cameraNames = []
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
        let photoString = displayedPhotos.count == 1 ? "photo" : "photos"
        numberOfPhotosLabel.text = "\(displayedPhotos.count) \(photoString) found"
    }
    
    private func configureEarthDateLabel() {
        earthDateLabel.text = allPhotos.count > 0 ? allPhotos[0].earthDate : ""
    }
    
    // MARK: Changing rover
    
    @IBAction func roverSelected(_ sender: Any) {
        chosenRover = RoverName(index: roverSelector.selectedSegmentIndex)
        clearDisplayedData()
        fetchData(sol: currentSol, rover: chosenRover.rawValue, context: managedObjectContext)
    }
}


//MARK: Table view methods
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        cell.setPhotoProperties(displayedPhotos[indexPath.row])
        return cell
    }
}


// MARK: Picker view methods
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func setUpCameraPicker() {
        cameraNames = Array(Set(allPhotos.map {$0.camera?.name ?? ""}))
        if cameraNames.count > 1 {
            cameraNames.insert("All", at: 0)
        }
        cameraPicker.reloadAllComponents()
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
            displayedPhotos = allPhotos.filter { $0.camera?.name ?? "" == selectedCamera }
        }
        tableView.reloadData()
        configureNumberOfPhotosLabel()
    }
}


// MARK: Methods for sol text field
extension ViewController: UITextFieldDelegate {
    
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
        fetchData(sol: newSol, rover: chosenRover.rawValue, context: managedObjectContext)
    }
    
    private func handleInvalidSolInput() {
        numberOfPhotosLabel.text = "Please enter a sol between \(minSol) and \(maxSol)"
        clearDisplayedData()
    }
}
