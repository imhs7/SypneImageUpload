//
//  ImageCollectionController.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 08/11/24.
//

import UIKit
import RealmSwift
import UserNotifications

final class ImageCollectionController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView?
    private var viewModel: ImageCollectionViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ImageCollectionViewModel() // Initialize ViewModel
        if let viewModel = viewModel {
            bindViewModel(viewModel)
        } // Bind ViewModel and setup notification handler
        setupCollectionView()
        setupNavigationBar()
        UNUserNotificationCenter.current().delegate = self // Set the delegate for notifications
    }
}

//MARK: - Private methods
private extension ImageCollectionController {
    // MARK: - Bind ViewModel to View
    func bindViewModel(_ viewModel: ImageCollectionViewModel) {
        // Binding imagesUpdated closure to reload the collection view
        viewModel.imagesUpdated = { [weak self] in
            self?.collectionView?.reloadData()
        }
        
        // Binding showAlert closure to display success/error messages
        viewModel.showAlert = { [weak self] title, message in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true)
        }
        
        // Binding sendNotification closure to trigger the notification
        viewModel.sendNotification = { [weak self] in
            self?.sendUploadSuccessNotification()
        }
    }
    
    // MARK: - Setup Methods
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        if let collectionView = collectionView {
            view.addSubview(collectionView)
        }
        
        NSLayoutConstraint.activate([
            collectionView?.topAnchor.constraint(equalTo: view.topAnchor) ?? NSLayoutConstraint(),
            collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor) ?? NSLayoutConstraint(),
            collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor) ?? NSLayoutConstraint(),
            collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor) ?? NSLayoutConstraint()
        ])
    }
    
    func setupNavigationBar() {
        navigationItem.title = "Image Gallery"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewImage))
        navigationItem.rightBarButtonItem = addButton
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: - Actions
    @objc func addNewImage() {
        let viewController = CameraViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ImageCollectionController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfImages() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        // Get the image model at the given indexPath
        if let imageModel = viewModel?.images[indexPath.row],
           let thumbnailImage = viewModel?.getThumbnailData(at: indexPath) {
            // Pass both the thumbnail image and the isUploaded property
            cell.configure(with: thumbnailImage, isUploaded: imageModel.isUploaded)
        }
        
        cell.imageTapped = { [weak self] in
            self?.imageTapped(at: indexPath)
        }
        
        cell.labelTapAction = { [weak self] in
            self?.uploadTapped(at: indexPath)
        }
        return cell
    }
}
//MARK: - Private methods for tap actions
private extension ImageCollectionController {
    func imageTapped(at indexPath: IndexPath) {
        if let image = viewModel?.getImageData(at: indexPath) {
            let imageViewController = ImageDetailViewController(image: image)
            navigationController?.pushViewController(imageViewController, animated: true)
        }
    }
    
    func uploadTapped(at indexPath: IndexPath) {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }
        
        // Get the image model at the given indexPath
        guard let imageModel = viewModel?.images[indexPath.row] else { return }
        
        // If the image is already uploaded, we don't need to do anything
        if imageModel.isUploaded {
            // Optionally, show a message that the image has already been uploaded
            return
        }
        
        // Show the loader while uploading
        cell.uploadInProgress = true

        // Call the viewModel's uploadImage method, passing the closure to update the state
        viewModel?.uploadImage(at: indexPath, updateUploadState: { [weak self] in
            // Update the upload state once the upload completes
            cell.uploadInProgress = $0 // $0 is the Boolean indicating upload success or failure
        }, uploadCompletion: { [weak self] success in
            // If upload is successful, hide the label and mark the image as uploaded
            if success {
                cell.hideLabelPermanently()  // Hide the label permanently
                // Optionally, update the image model's `isUploaded` flag if it's not updated
                try? self?.viewModel?.realm.write {
                    imageModel.isUploaded = true
                }
            }
        })
    }
}
