//
//  RealmManager.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 09/11/24.
//

import Foundation
import RealmSwift
class RealmManager {
    
    static var shared: RealmManager {
        return .init()
    }
    
    // Realm instance
    let realm: Realm
    
    // Initialization method
    init() {
        // Set up Realm configuration with schema version reset
        let config = Realm.Configuration(
            schemaVersion: 0,  // Reset schema version to 0 for fresh start
            migrationBlock: nil // No migration needed
        )
        
        // Set the default Realm configuration
        Realm.Configuration.defaultConfiguration = config
        
        // Initialize Realm with the new configuration
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error)")
        }
    }
}

