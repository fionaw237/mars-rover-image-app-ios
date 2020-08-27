//
//  PhotoTableViewCell.swift
//  Mars_Rover_Images
//
//  Created by Fiona Wilson on 15/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var cameraName: UILabel!
    @IBOutlet weak var roverName: UILabel!
    @IBOutlet weak var roverStatus: UILabel!
    
    func setPhotoProperties(_ photo: Photo) {
        cameraName.text = photo.camera?.name ?? ""
        roverName.text = photo.rover?.name ?? ""
        roverStatus.text = photo.rover?.status ?? ""
        if let url = URL(string: photo.image!) {
            photoImage.sd_setImage(with: url)
        }
    }
}
