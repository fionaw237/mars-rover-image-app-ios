//
//  Models.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 01/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation

struct PhotosResponse: Decodable {
    var photos: [PhotoDto]
}

struct PhotoDto: Decodable {
    let sol: Int
    let camera: Camera
    let image: String?
    let rover: Rover
    let earthDate: String
    
    private enum CodingKeys: String, CodingKey {
        case sol, camera, rover, image = "img_src", earthDate = "earth_date"
    }
    
    init(_ photo: Photo) {
        let cameraName = photo.camera ?? ""
        let roverName = photo.rover ?? ""
        let status = photo.status ?? ""
        sol = Int(photo.sol)
        camera = Camera(name: cameraName)
        image = photo.image
        rover = Rover(name: roverName, status: status)
        earthDate = ""
    }
}

struct Rover: Decodable {
    let name: String
    let status: String
}

struct Camera: Decodable, Hashable {
    let name: String
}
