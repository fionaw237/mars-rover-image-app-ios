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
    
    var photos: [PhotoDto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photos = APIRequest().fetchData(sol: 1)
        
//        guard let url = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1&api_key=SosAw8PH06hY4UgdReSvYk0F0GfqFHPv0V9GWFK8") else {return}
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if error == nil {
//                guard let data = data else {return}
//                do {
//                    self.photos = try JSONDecoder().decode(PhotosResponse.self, from: data)
//                } catch let jsonError {
//                    print("Error Parsing json:", jsonError)
//                }
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//        }.resume()
        
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

