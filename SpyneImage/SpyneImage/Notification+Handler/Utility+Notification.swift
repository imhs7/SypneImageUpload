//
//  NotificationHandler.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 10/11/24.
//

import Foundation
import NotificationCenter

// MARK: -  Notification Permission
extension CameraViewController {
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

// MARK: - UNUserNotificationCenterDelegate
extension ImageCollectionController: UNUserNotificationCenterDelegate {
    
    // This method will be called when a notification is delivered to the app while it's in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Show the notification even if the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Optional: Handle when a notification is tapped by the user (app goes to background or is opened from notification)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // You can handle the action here if needed (e.g., open a specific view)
        print("Notification tapped: \(response.notification.request.identifier)")
        completionHandler()
    }
}

// MARK: - Schedule Notification
extension ImageCollectionController {
    func sendUploadSuccessNotification() {
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Upload Complete"
        content.body = "Your image has been successfully uploaded."
        content.sound = .default
        
        // Create a trigger to show the notification immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create a request with a unique identifier
        let request = UNNotificationRequest(identifier: "uploadSuccessNotification", content: content, trigger: trigger)
        
        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
}
