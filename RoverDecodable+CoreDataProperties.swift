//
//  RoverDecodable+CoreDataProperties.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData


extension RoverDecodable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoverDecodable> {
        return NSFetchRequest<RoverDecodable>(entityName: "RoverDecodable")
    }

    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var photo: PhotoDecodable?

}
