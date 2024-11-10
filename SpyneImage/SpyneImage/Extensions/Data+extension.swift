//
//  Data+extension.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 10/11/24.
//

import Foundation
// MARK: - Data Extension to Append Multipart Form Data
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
