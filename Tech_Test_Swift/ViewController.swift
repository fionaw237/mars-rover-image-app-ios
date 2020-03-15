//
//  ViewController.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 04/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var photos: [PhotoDto] = [
        PhotoDto(camera: "Curiosity" , image: "https://i.picsum.photos/id/301/200/300.jpg", rover: "rover 1", status: "active"),
        PhotoDto(camera: "Curiosity" , image: "https://i.picsum.photos/id/301/200/300.jpg", rover: "rover 2", status: "active"),
        PhotoDto(camera: "Curiosity" , image: "https://i.picsum.photos/id/301/200/300.jpg", rover: "rover 3", status: "inactive"),
        PhotoDto(camera: "Curiosity" , image: "https://i.picsum.photos/id/301/200/300.jpg", rover: "rover 4", status: "active"),
        PhotoDto(camera: "Curiosity" , image: "https://i.picsum.photos/id/301/200/300.jpg", rover: "rover 5", status: "active")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photo = photos[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PhotoTableViewCell", for: indexPath) as! PhotoTableViewCell
        cell.setPhotoProperties(photo)
        return cell
    }
}

