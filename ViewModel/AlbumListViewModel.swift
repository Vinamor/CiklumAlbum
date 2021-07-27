//
//  AlbumListViewModel.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ReactiveSwift

protocol AlbumListViewModelType {
  var reloadItemSignal: Signal<Int?, Never> { get }
  var refreshSignal: Signal<Void, Never> { get }
  var navigateSignal: Signal<PhotoListViewModelType, Never> { get }

  func getItems() -> [AlbumCellViewModelType]
  func navigateToPhotos(by albumId: Int)
  func refreshContent()
}

class AlbumListViewModel: AlbumListViewModelType {

  var (reloadItemSignal, reloadItemPipe) = Signal<Int?, Never>.pipe()
  var (refreshSignal, refreshPipe) = Signal<Void, Never>.pipe()
  var (navigateSignal, navigatePipe) = Signal<PhotoListViewModelType, Never>.pipe()

  private let networkingManager: NetworkingManagerType
  private var items: [AlbumCellViewModelType] = []
  private var (lifetime, token) = Lifetime.make()

  init(networkingManager: NetworkingManagerType) {
    self.networkingManager = networkingManager
    requestAlbums()
  }

  func getItems() -> [AlbumCellViewModelType] {
    return items
  }

  func navigateToPhotos(by albumId: Int) {
    let viewModel = PhotoListViewModel(albumId: albumId, networkingManager: networkingManager)
    navigatePipe.send(value: viewModel)
  }

  func refreshContent() {
    requestAlbums()
  }

  private func requestAlbums() {
    networkingManager.fetchAlbums { [weak self] albums, error in
      self?.items = albums.map { AlbumCellViewModel(album: $0) }
      self?.refreshPipe.send(value: {}())
      self?.bindToUpdates()
    }
  }

  private func bindToUpdates() {
    items.forEach { photo in
      photo.image.producer.take(during: lifetime).filter { $0 != nil }.startWithValues { [weak self] _ in
        self?.reloadItemPipe.send(value: photo.id)
      }
    }
  }

}
