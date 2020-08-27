//
//  Photo+CoreDataProperties.swift
//  Mars_Rover_Images
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var sol: Int16
    @NSManaged public var image: String?
    @NSManaged public var earthDate: String?
    @NSManaged public var camera: Camera?
    @NSManaged public var rover: Rover?

}
