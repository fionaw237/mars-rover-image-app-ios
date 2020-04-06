//
//  Rover+CoreDataClass.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Rover)
public class Rover: NSManagedObject, Decodable {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Rover", in: managedObjectContext) else {
                fatalError("Failed to create entity for Rover")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: RoverCodingKeys.self)
        do {
         name = try values.decode(String?.self, forKey:.name)
            status = try values.decode(String?.self, forKey:.status)
        } catch {
            print("Error decoding Rover")
        }
    }
}

enum RoverCodingKeys: String, CodingKey {
    case name, status
}
