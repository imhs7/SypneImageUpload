//
//  ViewController.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 09/11/24.
//

import UIKit

final class CameraViewController: UIViewController {
    
    private var openCameraButton = UIButton()
    private var openGalleryButton = UIButton()
    private var deleteAllImagesButton = UIButton()
    
    var viewModel: CameraViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CameraViewModel()
        viewModel?.navigateToImageCollection = { [weak self] in
            self?.navigateToImageCollectionController()
        }
        viewModel?.showAlert = { [weak self] title, message in
            self?.showAlert(title: title, message: message)
        }
        
        setGradientBackground()
        configureButtons()
        setupButtons()
        requestNotificationPermission()
    }
}

// MARK: - Setup Views
private extension CameraViewController {
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.purple.cgColor] // gradient colors
        gradientLayer.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupButtons() {
        // Add buttons to the view
        view.addSubview(openCameraButton)
        view.addSubview(openGalleryButton)
        view.addSubview(deleteAllImagesButton)
        
        // Add button constraints
        NSLayoutConstraint.activate([
            openCameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openCameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            openCameraButton.heightAnchor.constraint(equalToConstant: 50),
            openCameraButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            openGalleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openGalleryButton.topAnchor.constraint(equalTo: openCameraButton.bottomAnchor, constant: 20),
            openGalleryButton.heightAnchor.constraint(equalToConstant: 50),
            openGalleryButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        NSLayoutConstraint.activate([
            deleteAllImagesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAllImagesButton.topAnchor.constraint(equalTo: openGalleryButton.bottomAnchor, constant: 20),
            deleteAllImagesButton.heightAnchor.constraint(equalToConstant: 50),
            deleteAllImagesButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        //Set button actions
        setButtonActions()
    }
    
    func configureButtons() {
        openCameraButton = createStyledButton(title: "Open Camera", backgroundColor: .systemBlue, titleColor: .white)
        openGalleryButton = createStyledButton(title: "Open Gallery", backgroundColor: .systemGreen, titleColor: .white)
        deleteAllImagesButton = createStyledButton(title: "Delete All Images", backgroundColor: .systemRed, titleColor: .white)
    }
    
    func setButtonActions() {
        openCameraButton.addTarget(self, action: #selector(openCameraTapped), for: .touchUpInside)
        openGalleryButton.addTarget(self, action: #selector(openGalleryTapped), for: .touchUpInside)
        deleteAllImagesButton.addTarget(self, action: #selector(deleteAllImagesTapped), for: .touchUpInside)
    }
    
    func createStyledButton(title: String, backgroundColor: UIColor, titleColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = backgroundColor
        button.setTitleColor(titleColor, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        return button
    }
}

// MARK: - Actions
private extension CameraViewController {
    
    @objc func openCameraTapped() {
        viewModel?.openCameraTapped { [weak self] granted in
            if granted {
                self?.viewModel?.presentCamera(from: self!)
            } else {
                self?.viewModel?.showPermissionAlert(from: self!)
            }
        }
    }
    
    @objc func openGalleryTapped() {
        viewModel?.openGalleryTapped(from: self)
    }
    
    @objc func deleteAllImagesTapped() {
        viewModel?.deleteAllImagesTapped()
    }
    
    // MARK: - Navigation
    func navigateToImageCollectionController() {
        let imageCollectionController = ImageCollectionController()
        self.navigationController?.pushViewController(imageCollectionController, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
