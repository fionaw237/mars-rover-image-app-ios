//
//  NetworkRequest.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 01/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation

protocol NetworkRequest {
    func fetchData(sol: Int) -> [PhotoDto]
}


class APIRequest: NetworkRequest {
    func fetchData(sol: Int) -> [PhotoDto] {
        return [PhotoDto(camera: Camera(name: "Camera Name") , img_src: "https://i.picsum.photos/id/301/200/300.jpg", rover: Rover(name: "Eva", status: "Sleepy"))]
    }
}
