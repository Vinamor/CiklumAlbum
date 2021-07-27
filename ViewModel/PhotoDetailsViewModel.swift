//
//  PhotoDetailsViewModel.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ReactiveSwift
import UIKit

protocol PhotoDetailsViewModelType {
  var image: Property<UIImage?> { get }
}

class PhotoDetailsViewModel: PhotoDetailsViewModelType {

  var image: Property<UIImage?>

  private let imageURL: String?
  private let photoManager: PhotoManagerType
  private let mutableImage: MutableProperty<UIImage?> = MutableProperty(nil)

  init(imageURL: String?, photoManager: PhotoManagerType) {
    self.imageURL = imageURL
    self.photoManager = photoManager
    self.image = Property(mutableImage)
    photoManager.downloadImage(from: imageURL) { [weak self] in
      self?.mutableImage.value = $0
    }
  }
}
