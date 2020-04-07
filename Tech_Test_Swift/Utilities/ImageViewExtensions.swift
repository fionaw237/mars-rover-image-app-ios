//
//  ImageViewExtensions.swift
//  Tech_Test_Swift
//
//  Created by Fiona Wilson on 15/03/2020.
//  Copyright © 2020 Fiona Wilson. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
