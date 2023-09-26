//
//  NetworkRequest.swift
//  Mars_Rover_Images
//
//  Created by Fiona Wilson on 01/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation
import CoreData

enum DataFetchError: String, Error {
    case urlCreation = "Could not create URL."
    case coreDataSave = "Error saving to Core Data."
    case decode = "Error decoding JSON."
    case server = "The server responded with an error."
}

struct NetworkManager {
    func fetchData(
        sol: Int,
        rover: String,
        context: NSManagedObjectContext
    ) async throws -> [Photo] {
        let baseUrl = "https://api.nasa.gov/mars-photos/api/v1/rovers/"
        let key = "SosAw8PH06hY4UgdReSvYk0F0GfqFHPv0V9GWFK8"
        
        guard let url = URL(string: "\(baseUrl)\(rover)/photos?sol=\(sol)&api_key=\(key)") else {
            throw DataFetchError.urlCreation
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw DataFetchError.server
        }
        
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.context!] = context
        
        do {
            let photosResponse = try decoder.decode(PhotoData.self, from: data)
            do {
                try context.save()
            } catch {
                throw DataFetchError.coreDataSave
            }
            return photosResponse.photos
        } catch {
            throw DataFetchError.decode
        }

    }
}
