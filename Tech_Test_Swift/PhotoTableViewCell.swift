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
        cameraName.text = photo.camera.name
        roverName.text = photo.rover.name
        roverStatus.text = photo.rover.status
        if let url = URL(string: photo.img_src!) {
            photoImage.load(url: url)
        }
    }
}
