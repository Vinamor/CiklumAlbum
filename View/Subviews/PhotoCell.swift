//
//  PhotoCell.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import UIKit
import ReactiveSwift

class PhotoCell: UICollectionViewCell {

  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  private var (lifetime, token) = Lifetime.make()

  func bind(viewModel: PhotoCellViewModelType) {
    (lifetime, token) = Lifetime.make()
    viewModel.image.producer
      .observe(on: UIScheduler())
      .take(during: lifetime)
      .startWithValues { [weak self] in
        self?.activityIndicator.isHidden = $0 != nil
        self?.imageView.image = $0
        $0 != nil ? self?.activityIndicator.stopAnimating() : self?.activityIndicator.startAnimating()
      }
  }
  
}
