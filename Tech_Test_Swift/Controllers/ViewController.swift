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
    
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var cameraNames: [String] = []
    var currentSol = 1
    let minSol = 1
    let maxSol = 2500
    let chosenRover = "Curiosity"
    let apiRequest = APIRequest()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Photo> = {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Photo.camera.name), ascending: true)]
        request.predicate = solPredicate()
        
        let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: request,
        managedObjectContext: managedObjectContext,
        sectionNameKeyPath: nil,
        cacheName: nil)

        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    private func solPredicate() -> NSPredicate {
        return NSPredicate(format: "%K == \(currentSol)", #keyPath(Photo.sol))
    }
    
    private func solAndCameraPredicate(cameraName: String) -> NSCompoundPredicate {
        let cameraPredicate = NSPredicate(format: "%K.%K == \(cameraName)", #keyPath(Photo.camera), #keyPath(Camera.name))
        return NSCompoundPredicate(andPredicateWithSubpredicates: [solPredicate(), cameraPredicate])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSolTextField()
        configureTapGesture()
        fetchData(sol: currentSol, rover: chosenRover, context: managedObjectContext)
    }
    
    private func reloadDisplayedData() {
        configureNumberOfPhotosLabel()
        configureEarthDateLabel()
        setUpCameraPicker()
        tableView.reloadData()
    }
    
    //MARK: Methods handling fetching of data
    
    private func fetchData(sol: Int, rover: String, context: NSManagedObjectContext) {
        currentSol = sol
        do {
            fetchedResultsController.fetchRequest.predicate = solPredicate()
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        if fetchedResultsController.fetchedObjects?.count ?? 0 == 0 {
            fetchDataRemotely(sol, rover, context)
        } else {
            reloadDisplayedData()
        }
    }
    
    private func fetchDataRemotely(_ sol: Int, _ rover: String, _ context: NSManagedObjectContext) {
        numberOfPhotosLabel.text = "Fetching images for sol \(sol)..."
        apiRequest.fetchData(sol: sol, rover: rover, context: context) { (result) in
            switch result {
            case .success:
                return
            case .failure(let error):
                self.numberOfPhotosLabel.text = error.localizedDescription
            }
        }
    }
    
    private func clearDisplayedData() {
        cameraNames = []
        earthDateLabel.text = ""
        do {
            fetchedResultsController.fetchRequest.predicate = NSPredicate.init(value: false)
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
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
        numberOfPhotosLabel.text = "\(fetchedResultsController.fetchedObjects?.count ?? 0) photo(s) found."
    }
    
    private func configureEarthDateLabel() {
        earthDateLabel.text = fetchedResultsController.fetchedObjects?.count ?? 0 > 0 ? fetchedResultsController.fetchedObjects![0].earthDate : ""
    }
}


//MARK: Table view methods
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {return 0}
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        cell.setPhotoProperties(fetchedResultsController.object(at: indexPath))
        return cell
    }
}


// MARK: Picker view methods
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    private func setUpCameraPicker() {
        cameraNames = Array( Set ( ( fetchedResultsController.fetchedObjects ?? [] ).map { $0.camera?.name ?? "" } ) )
        cameraNames.insert("All", at: 0)
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
        let selectedCamera = cameraNames.count > 0 ? cameraNames[row] : nil
        guard let cameraName = selectedCamera else {return}
        switch cameraName {
        case "All":
            fetchedResultsController.fetchRequest.predicate = solPredicate()
        default:
            fetchedResultsController.fetchRequest.predicate = solAndCameraPredicate(cameraName: cameraName)
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
        tableView.reloadData()
        configureNumberOfPhotosLabel()
    }
}

// MARK: Methods for sol text field
extension ViewController: UITextFieldDelegate {
    
    private func configureSolTextField() {
        solTextField.text = "\(currentSol)"
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
        fetchData(sol: newSol, rover: chosenRover, context: managedObjectContext)
    }
    
    private func handleInvalidSolInput() {
        numberOfPhotosLabel.text = "Please enter a sol between \(minSol) and \(maxSol)"
        clearDisplayedData()
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reloadDisplayedData()
        print("DID CHANGE CONTENT")
    }
}

