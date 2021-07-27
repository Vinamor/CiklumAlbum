//
//  AlbumCellViewModel.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ReactiveSwift
import UIKit

protocol AlbumCellViewModelType {
  var id: Int? { get }
  var title: String { get }
  var image: Property<UIImage?> { get }
  var urlString: String? { get }
}

class AlbumCellViewModel: AlbumCellViewModelType {
  var id: Int?
  var title: String
  var image: Property<UIImage?>
  var urlString: String?

  private let photoManger = PhotoManager()
  private var (lifetime, token) = Lifetime.make()
  private let mutableImage: MutableProperty<UIImage?> = MutableProperty(nil)

  init(album: Album) {
    self.id = album.id
    self.title = album.title ?? ""
    self.urlString = nil

    image = Property(mutableImage)
    photoManger.downloadImage(from: album.coverURL) { [weak self] in
      self?.mutableImage.value = $0
    }
  }
}
