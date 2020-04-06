//
//  PhotoDecodable+CoreDataClass.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PhotoDecodable)
public class PhotoDecodable: NSManagedObject, Decodable {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "PhotoDecodable", in: managedObjectContext) else {
                fatalError("Failed to decode PhotoDecodable")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: PhotoCodingKeys.self)
        do {
            sol = try values.decode(Int16.self, forKey:.sol)
            camera = try values.decode(CameraDecodable?.self, forKey:.camera)
            image = try values.decode(String?.self, forKey:.image)
            rover = try values.decode(RoverDecodable?.self, forKey:.rover)
            earthDate = try values.decode(String?.self, forKey:.earthDate)
        } catch {
            print("Error in PhotoDecodable")
        }
    }
}

enum PhotoCodingKeys: String, CodingKey {
    case sol, camera, rover, image = "img_src", earthDate = "earth_date"
}
