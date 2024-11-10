//
//  ImageModel.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 08/11/24.
//

import Foundation
import RealmSwift

final class ImageModel: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var imageData: Data?  // This will hold the actual image data
    @objc dynamic var uri: String?  // This will hold the URI of the image
    @objc dynamic var thumbnailData: Data?  // This will hold the thumbnail data
    @objc dynamic var creationDate = Date()
    @objc dynamic var isUploaded = false  // New property to track upload status
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

