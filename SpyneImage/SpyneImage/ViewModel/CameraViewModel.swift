//
//  CameraViewModel.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 10/11/24.
//

import UIKit
import AVFoundation
import RealmSwift
import UserNotifications

final class CameraViewModel: NSObject {
    
    // MARK: - Properties
    var navigateToImageCollection: (() -> Void)?
    var showAlert: ((_ title: String, _ message: String) -> Void)?
    var updateCameraStatus: ((_ status: Bool) -> Void)?
    
    private let imagePickerController = UIImagePickerController()
    
    override init() {
        super.init()
        imagePickerController.delegate = self
    }

    // Camera Handling
    func openCameraTapped(completion: @escaping (Bool) -> Void) {
        checkCameraPermission { granted in
            if granted {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    //Permission Check for camera
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }

    func presentCamera(from viewController: UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            viewController.present(imagePickerController, animated: true, completion: nil)
        } else {
            print("Camera is not available on this device.")
        }
    }
    
    func showPermissionAlert(from viewController: UIViewController) {
        let alert = UIAlertController(title: "Camera Permission Denied", message: "Please enable camera access in settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }

    // Gallery Handling
    func openGalleryTapped(from viewController: UIViewController) {
        checkIfImagesExist { [weak self] exists in
            if exists {
                self?.navigateToImageCollection?()
            } else {
                self?.showAlert?("No Images", "There are no images in the gallery.")
            }
        }
    }

    func checkIfImagesExist(completion: @escaping (Bool) -> Void) {
        do {
            let realm = try Realm()
            let images = realm.objects(ImageModel.self)
            completion(!images.isEmpty)
        } catch {
            print("Error fetching images from Realm: \(error)")
            completion(false)
        }
    }

    // Delete Handling
    func deleteAllImagesTapped() {
        cleanRealm()
        showAlert?("Success", "All images have been deleted.")
    }

    func cleanRealm() {
        do {
            let realm = try Realm()
            let allObjects = realm.objects(ImageModel.self)
            try realm.write {
                realm.delete(allObjects)
            }
        } catch {
            print("Error cleaning Realm: \(error)")
        }
    }
    
    // Notification Permission Request
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

//MARK: - Image Picker Delegate
extension CameraViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let pickedImage = info[.originalImage] as? UIImage {
                // Resize image to create a thumbnail
                let thumbnail = pickedImage.resizeImage(targetSize: CGSize(width: 100, height: 100))
                
                // Save image to the app's documents directory or temporary directory
                if let imageData = pickedImage.jpegData(compressionQuality: 1.0),
                   let thumbnailData = thumbnail?.jpegData(compressionQuality: 0.3) {
                    
                    // Get the file URL for the image
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let imageURL = documentsURL.appendingPathComponent(UUID().uuidString + ".jpg")
                    
                    // Save the image to the file system
                    do {
                        try imageData.write(to: imageURL)
                        
                        // Now create the ImageModel
                        let imageModel = ImageModel()
                        imageModel.imageData = imageData
                        imageModel.thumbnailData = thumbnailData
                        imageModel.uri = imageURL.absoluteString  // Store the URI (file path)
                        
                        // Save to Realm
                        try! RealmManager.shared.realm.write {
                            RealmManager.shared.realm.add(imageModel)
                        }
                    } catch {
                        print("Error saving image to file system: \(error)")
                    }
                }
                self.navigateToImageCollection?()
            }
        }
    }
    
    // Handle image picker cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
