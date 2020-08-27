//
//  Photo+CoreDataClass.swift
//  Mars_Rover_Images
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject, Decodable {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedObjectContext) else {
                fatalError("Error creating entity for Photo")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: PhotoCodingKeys.self)
        do {
            sol = try values.decode(Int16.self, forKey:.sol)
            camera = try values.decode(Camera?.self, forKey:.camera)
            image = try values.decode(String?.self, forKey:.image)
            rover = try values.decode(Rover?.self, forKey:.rover)
            earthDate = try values.decode(String?.self, forKey:.earthDate)
        } catch {
            print("Error decoding Photo")
        }
    }
}
