//
//  PhotoListViewModel.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import UIKit
import ReactiveSwift

protocol PhotoListViewModelType {
  var reloadItemSignal: Signal<Int?, Never> { get }
  var refreshSignal: Signal<Void, Never> { get }
  var navigateSignal: Signal<PhotoDetailsViewModelType, Never> { get }
  func getItems() -> [PhotoCellViewModelType]
  func navigateToDetailedPhoto(with item: PhotoCellViewModelType)
}

class PhotoListViewModel: PhotoListViewModelType {
  var (reloadItemSignal, reloadItemPipe) = Signal<Int?, Never>.pipe()
  var (refreshSignal, refreshPipe) = Signal<Void, Never>.pipe()
  var (navigateSignal, navigatePipe) = Signal<PhotoDetailsViewModelType, Never>.pipe()

  private let networkingManager: NetworkingManagerType
  private let photoManager = PhotoManager()

  private var items: [PhotoCellViewModelType] = []
  private var (lifetime, token) = Lifetime.make()

  init(albumId: Int, networkingManager: NetworkingManagerType) {
    self.networkingManager = networkingManager
    networkingManager.fetchPhotos(for: albumId) { [weak self] photos, error in
      self?.items = photos.compactMap { PhotoCellViewModel(photo: $0) }
      self?.refreshPipe.send(value: {}())
      self?.bindToUpdates()
    }
  }

  func getItems() -> [PhotoCellViewModelType] {
    return items
  }

  func navigateToDetailedPhoto(with item: PhotoCellViewModelType) {
  let viewModel = PhotoDetailsViewModel(imageURL: item.fullsizeImageURL, photoManager: photoManager)

    navigatePipe.send(value: viewModel)
  }

  private func bindToUpdates() {
    items.forEach { photo in
      photo.image.producer.take(during: lifetime).filter { $0 != nil }.startWithValues { [weak self] _ in
        self?.reloadItemPipe.send(value: photo.id)
      }
    }
  }
}
