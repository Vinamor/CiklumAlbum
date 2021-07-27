//
//  PhotoCellViewModel.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import UIKit
import ReactiveSwift

protocol PhotoCellViewModelType {
  var id: Int? { get }
  var fullsizeImageURL: String? { get }
  var image: Property<UIImage?> { get }
}

class PhotoCellViewModel: PhotoCellViewModelType {
  var id: Int?
  var fullsizeImageURL: String?
  var image: Property<UIImage?>

  private let photoManger = PhotoManager()
  private var (lifetime, token) = Lifetime.make()
  private let mutableImage: MutableProperty<UIImage?> = MutableProperty(nil)

  init(photo: Photo) {
    self.id = photo.id
    self.fullsizeImageURL = photo.url

    image = Property(mutableImage)
    photoManger.downloadImage(from: photo.thumbnailURL) { [weak self] in
      self?.mutableImage.value = $0
    }
  }
}
