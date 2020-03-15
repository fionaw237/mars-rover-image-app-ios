//
//  PhotoTableViewCell.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 15/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var roverName: UILabel!
    @IBOutlet weak var roverStatus: UILabel!
    
    func setPhotoProperties(_ photo: PhotoDto) {
        cameraName.text = photo.camera
        roverName.text = photo.rover
        roverStatus.text = photo.status
        if let url = URL(string: photo.image) {
            photoImage.load(url: url)
        }
    }
}
