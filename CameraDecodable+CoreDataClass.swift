//
//  CameraDecodable+CoreDataClass.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CameraDecodable)
public class CameraDecodable: NSManagedObject, Decodable {

    required convenience public init(from decoder: Decoder) throws {
           guard let contextUserInfoKey = CodingUserInfoKey.context,
               let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
               let entity = NSEntityDescription.entity(forEntityName: "CameraDecodable", in: managedObjectContext) else {
                   fatalError("Failed to decode CameraDecodable")
           }
           self.init(entity: entity, insertInto: managedObjectContext)
           let values = try decoder.container(keyedBy: CameraCodingKeys.self)
           do {
            name = try values.decode(String?.self, forKey:.name)
           } catch {
               print("Error in CameraDecodable")
           }
       }
}


enum CameraCodingKeys: String, CodingKey {
    case name
}
