//
//  AlbumCell.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ReactiveSwift
import ReactiveCocoa
import UIKit

class AlbumCell: UICollectionViewCell {

  @IBOutlet private weak var title: UILabel!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

  private var (lifetime, token) = Lifetime.make()

  func bind(viewModel: AlbumCellViewModelType) {
    (lifetime, token) = Lifetime.make()
    title.text = viewModel.title
    viewModel.image.producer
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .startWithValues { [weak self] in
        self?.activityIndicator.isHidden = $0 != nil
        self?.imageView.image = $0
        $0 != nil ? self?.activityIndicator.stopAnimating() : self?.activityIndicator.startAnimating()
      }
  }

}
