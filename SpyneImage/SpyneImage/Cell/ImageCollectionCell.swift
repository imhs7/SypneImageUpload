//
//  ImageCollectionCell.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 09/11/24.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var imageTapped: (() -> Void)?
    var labelTapAction: (() -> Void)?
    var uploadInProgress: Bool = false {
        didSet {
            updateUIForUploadState()
        }
    }
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Upload"
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        return label
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewAndConstraints()
        addGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Configure the cell with the image
    func configure(with image: UIImage?, isUploaded: Bool) {
        imageView.image = image
        label.isHidden = isUploaded // Hide the label permanently if the image has already been uploaded
    }
    
    // Hide the label permanently after successful upload
    func hideLabelPermanently() {
        label.isHidden = true
    }
}

// MARK: - Layout Views and Constraints
extension ImageCollectionViewCell {
    private func setupViewAndConstraints() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(activityIndicator) // Add the activity indicator to the cell
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true

        // Set the image view to take the full width and height minus the label height
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8)
        ])

        // Set the label just below the image view
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Set the activity indicator's position
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

//MARK: - Private Methods
private extension ImageCollectionViewCell {
    func addGestureRecognizers() {
        // Image Tap Gesture
        let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTappedAction))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTapGestureRecognizer)
        
        // Label Tap Gesture
        let labelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(labelTapGestureRecognizer)
    }
    
    // MARK: - Update UI for upload state
    func updateUIForUploadState() {
        if uploadInProgress {
            // Show activity indicator and hide the label
            activityIndicator.startAnimating()
            label.isHidden = true
        } else {
            // Hide activity indicator and show the label if the upload is not in progress
            activityIndicator.stopAnimating()
            label.isHidden = false
        }
    }
}

// MARK: - Tap Handling
extension ImageCollectionViewCell {
    
    @objc func imageTappedAction() {
        imageTapped?()
    }
    
    @objc private func labelTapped() {
        labelTapAction?()
    }
}
