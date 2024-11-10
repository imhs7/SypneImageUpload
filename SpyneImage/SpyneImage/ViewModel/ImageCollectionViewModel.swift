//
//  ImageCollectionViewModel.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 10/11/24.
//

import Foundation
import UIKit
import RealmSwift
import UserNotifications

final class ImageCollectionViewModel {

    
    // MARK: - Properties
    var realm: Realm
    var images: Results<ImageModel>!
    
    // Closure to notify the controller when images are updated (reload data)
    var imagesUpdated: (() -> Void)?
    
    // Closure to notify the controller to show an alert (e.g., success or failure messages)
    var showAlert: ((String, String) -> Void)?
    
    // Closure to send the notification request from ViewModel to ViewController
    var sendNotification: (() -> Void)?
    
    // MARK: - Initializer
    init() {
        self.realm = RealmManager.shared.realm
        fetchImages()
    }

    // MARK: - Fetch images from Realm
    private func fetchImages() {
        images = realm.objects(ImageModel.self).sorted(byKeyPath: "creationDate", ascending: false)
        imagesUpdated?()
    }

    // MARK: - Number of Images
    func numberOfImages() -> Int {
        return images.count
    }

    // MARK: - Get Image Thumbnail Data (for collection view cells)
    func getThumbnailData(at indexPath: IndexPath) -> UIImage? {
        let imageModel = images[indexPath.row]
        if let thumbnailData = imageModel.thumbnailData {
            return UIImage(data: thumbnailData)
        }
        return nil
    }

    // MARK: - Get Full Image Data (for viewing details)
    func getImageData(at indexPath: IndexPath) -> UIImage? {
        let imageModel = images[indexPath.row]
        if let imageData = imageModel.imageData {
            return UIImage(data: imageData)
        }
        return nil
    }

    // MARK: - Upload Image
    func uploadImage(
        at indexPath: IndexPath,
        updateUploadState: @escaping (Bool) -> Void,
        uploadCompletion: @escaping (Bool) -> Void
    ) {
        // Fetch the image model at the given indexPath
        let imageModel = images[indexPath.row]
        
        // Start the upload process (show loader)
        updateUploadState(true)
        
        // Simulate network upload (replace with actual upload logic)
        simulateImageUpload { [weak self] success in
            // After upload finishes, hide loader
            updateUploadState(false)
            
            if success {
                // Simulate success
                self?.showAlert?("Success", "Image uploaded successfully!")
                self?.sendNotification?()
                
                // Update the image model as uploaded
                try? self?.realm.write {
                    imageModel.isUploaded = true
                }
                // Notify the controller that the upload was successful
                uploadCompletion(true)
            } else {
                // Simulate failure
                self?.showAlert?("Error", "Failed to upload image. Please try again.")
                uploadCompletion(false)
            }
        }
    }
    
    // MARK: - Simulated Image Upload (for demonstration purposes)
    private func simulateImageUpload(completion: @escaping (Bool) -> Void) {
        // Simulate a delay to represent a network request (2 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Simulate success or failure randomly
            let success = Bool.random()
            completion(success)
        }
    }

    // MARK: - Send Upload Success Notification
    func sendUploadSuccessNotification() {
        sendNotification?()
    }
}
