//
//  Camera+CoreDataClass.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Camera)
public class Camera: NSManagedObject, Decodable {

    required convenience public init(from decoder: Decoder) throws {
           guard let contextUserInfoKey = CodingUserInfoKey.context,
               let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
               let entity = NSEntityDescription.entity(forEntityName: "Camera", in: managedObjectContext) else {
                   fatalError("Error creating entity for Camera")
           }
           self.init(entity: entity, insertInto: managedObjectContext)
           let values = try decoder.container(keyedBy: CameraCodingKeys.self)
           do {
            name = try values.decode(String?.self, forKey:.name)
           } catch {
               print("Error decoding Camera")
           }
       }
}


enum CameraCodingKeys: String, CodingKey {
    case name
}
