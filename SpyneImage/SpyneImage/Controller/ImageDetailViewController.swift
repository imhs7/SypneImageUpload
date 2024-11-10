//
//  ImageDetailViewController.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 09/11/24.
//

import Foundation
import UIKit

final class ImageDetailViewController: UIViewController {
    
    private var imageView = UIImageView()
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.imageView = UIImageView(image: image)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView() /// Setup the image view to display the selected image
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFit
        
    }
}
