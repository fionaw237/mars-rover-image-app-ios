//
//  Enums.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 07/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation

enum RoverCodingKeys: String, CodingKey {
    case name, status
}

enum CameraCodingKeys: String, CodingKey {
    case name
}

enum PhotoCodingKeys: String, CodingKey {
    case sol, camera, rover, image = "img_src", earthDate = "earth_date"
}

enum RoverName: String {
    case Curiosity = "Curiosity", Opportunity = "Opportunity", Spirit = "Spirit"
    
    init(index: Int) {
        switch index {
        case 0:
            self = .Curiosity
        case 1:
            self = .Opportunity
        default:
            self = .Spirit
        }
    }
}
