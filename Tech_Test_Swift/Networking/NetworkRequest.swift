//
//  NetworkRequest.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 01/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation
import CoreData

protocol NetworkRequest {
    func fetchData(sol: Int, rover: String, context: NSManagedObjectContext, completion: @escaping (Result<[Photo], Error>) -> Void)
}

class APIRequest: NetworkRequest {
    
    struct PhotosResponse: Decodable {
        var photos: [Photo]
    }
    
    func fetchData(sol: Int, rover: String, context: NSManagedObjectContext, completion: @escaping (Result<[Photo], Error>) -> Void) {
        
        let baseUrl = "https://api.nasa.gov/mars-photos/api/v1/rovers/"
        let key = "SosAw8PH06hY4UgdReSvYk0F0GfqFHPv0V9GWFK8"
        
        guard let url = URL(string: "\(baseUrl)\(rover)/photos?sol=\(sol)&api_key=\(key)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if error == nil {
                    guard let data = data else {return}
                    let decoder = JSONDecoder()
                    decoder.userInfo[CodingUserInfoKey.context!] = context
                    do {
                        try decoder.decode(PhotosResponse.self, from: data)
                        do {
                            try context.save()
                        } catch let coreDataError {
                            completion(.failure(coreDataError))
                        }
                    } catch let jsonError {
                        completion(.failure(jsonError))
                    }
                } else {
                    completion(.failure(error!))
                }
            }
        }.resume()
    }
}
