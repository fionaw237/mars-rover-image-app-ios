//
//  RoverDecodable+CoreDataClass.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(RoverDecodable)
public class RoverDecodable: NSManagedObject, Decodable {
    
    required convenience public init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "RoverDecodable", in: managedObjectContext) else {
                fatalError("Failed to decode RoverDecodable")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: RoverCodingKeys.self)
        do {
         name = try values.decode(String?.self, forKey:.name)
            status = try values.decode(String?.self, forKey:.status)
        } catch {
            print("Error in RoverDecodable")
        }
    }
}

enum RoverCodingKeys: String, CodingKey {
    case name, status
}
