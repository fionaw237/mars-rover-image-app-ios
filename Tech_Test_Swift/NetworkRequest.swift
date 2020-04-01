//
//  NetworkRequest.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 01/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation

protocol NetworkRequest {
     func fetchData(sol: Int, completion: @escaping (_ data: [PhotoDto]) -> Void)
}


class APIRequest: NetworkRequest {
    func fetchData(sol: Int, completion: @escaping ([PhotoDto]) -> Void) {
        
        let key = "SosAw8PH06hY4UgdReSvYk0F0GfqFHPv0V9GWFK8"
        
        guard let url = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=\(sol)&api_key=\(key)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                guard let data = data else {return}
                do {
                    let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(photosResponse.photos)
                    }
                } catch let jsonError {
                    print("Error Parsing json:", jsonError)
                }
            }
        }.resume()
    }
}
