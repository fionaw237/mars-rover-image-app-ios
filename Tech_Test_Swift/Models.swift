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
    let camera: Camera
    let img_src: String?
    let rover: Rover
}

struct Rover: Decodable {
    let name: String
    let status: String
}

struct Camera: Decodable {
    let name: String
}
