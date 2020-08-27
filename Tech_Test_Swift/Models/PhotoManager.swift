//
//  PhotoManager.swift
//  Tech_Test_Swift
//
//  Created by Fiona on 27/08/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation
import CoreData

struct PhotoManager {
    
    var context: NSManagedObjectContext? = nil
    
    let defaultSol = 1
    var currentSol = 1
    let minSol = 1
    let maxSol = 2500
    
    var allPhotos: [Photo] = [] {
        didSet {
            cameraNames = Array(Set(allPhotos.map {$0.camera?.name ?? ""}))
            if cameraNames.count > 1 {
                cameraNames.insert("All", at: 0)
            }
        }
    }
    
    var displayedPhotos: [Photo] = []
    var cameraNames: [String] = []
    var chosenRover = RoverName.Curiosity
    
    var numberOfPhotosInfoMessage: String {
        let photoString = displayedPhotos.count == 1 ? "photo" : "photos"
        return "\(displayedPhotos.count) \(photoString) found"
    }
    
    var numberOfPhotosInfoMessageInvalidSol: String {
        return "Please enter a sol between \(minSol) and \(maxSol)"
    }
    
    var earthDateLabelText: String {
        return allPhotos.count > 0 ? (allPhotos[0].earthDate ?? "") : ""
    }
    
    mutating func resetData() {
        displayedPhotos = []
        allPhotos = []
        cameraNames = []
    }
    
    mutating func setCurrentSol(_ value: Int) {
        currentSol = value
    }
    
    mutating func setPhotoArrays(_ data: [Photo]) {
        allPhotos = data
        displayedPhotos = data
    }
    
    mutating func handleSelectedCameraChanged(_ cameraName: String) {
        switch cameraName {
        case "All":
            displayedPhotos = allPhotos
        default:
            displayedPhotos = allPhotos.filter { $0.camera?.name ?? "" == cameraName }
        }
    }
    
    func isSolInputValid(_ input: Int) -> Bool {
        return (minSol...maxSol).contains(input)
    }
    
    func changeFromCurrentSol(_ input: Int) -> Bool {
        return input != currentSol
    }
    
    mutating func fetchLocalData(_ sol: Int, _ rover: String) {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        let solPredicate = NSPredicate(format: "%K == \(sol)", #keyPath(Photo.sol))
        let roverPredicate = NSPredicate(format: "%K == \"\(rover)\"", #keyPath(Photo.rover.name))
        request.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: [solPredicate, roverPredicate])
        do {
            let data = try context?.fetch(request) ?? []
            setPhotoArrays(data)
          } catch let error as NSError {
            print("Error fetching local data \(error), \(error.userInfo)")
            resetData()
          }
    }
}
