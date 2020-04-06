//
//  PhotoDecodable+CoreDataProperties.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoDecodable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoDecodable> {
        return NSFetchRequest<PhotoDecodable>(entityName: "PhotoDecodable")
    }

    @NSManaged public var sol: Int16
    @NSManaged public var image: String?
    @NSManaged public var earthDate: String?
    @NSManaged public var camera: CameraDecodable?
    @NSManaged public var rover: RoverDecodable?

}
