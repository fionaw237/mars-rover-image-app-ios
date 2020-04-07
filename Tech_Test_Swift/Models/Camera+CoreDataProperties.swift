//
//  Camera+CoreDataProperties.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 06/04/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//
//

import Foundation
import CoreData


extension Camera {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Camera> {
        return NSFetchRequest<Camera>(entityName: "Camera")
    }

    @NSManaged public var name: String?
    @NSManaged public var photo: Photo?

}
