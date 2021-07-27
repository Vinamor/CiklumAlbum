//
//  AlbumViewController.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ReactiveSwift
import UIKit

class AlbumListViewController: UIViewController {

  @IBOutlet private weak var collectionView: UICollectionView!

  private var viewModel: AlbumListViewModelType?
  private let (lifetime, token) = Lifetime.make()
  private let itemsPerRow: CGFloat = 2

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark
    collectionView.register(UINib(nibName: "AlbumCell", bundle: Bundle.main),
                                 forCellWithReuseIdentifier: "AlbumCell")
    viewModel = AlbumListViewModel(networkingManager: NetworkingManager())
    viewModel?.refreshSignal
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.collectionView.reloadData()
      }
    viewModel?.navigateSignal
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.navigateToPhotosViewController(with: $0)
      }
    viewModel?.reloadItemSignal
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.reloadItem(for: $0)
      }
  }

  @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
    viewModel?.refreshContent()
  }


  private func reloadItem(for itemId: Int?) {
    guard let itemId = itemId, let index = viewModel?.getItems().firstIndex(where: { $0.id == itemId }) else { return
    }
    collectionView.performBatchUpdates {
      collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
  }


  // MARK: - Navigation

  private func navigateToPhotosViewController(with viewModel: PhotoListViewModelType) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let controller = storyboard.instantiateViewController(identifier: "PhotoListViewController") as? PhotoListViewController else {
      print("Could not instantiate \(PhotoListViewController.self)")
      return
    }
    controller.viewModel = viewModel
    self.navigationController?.pushViewController(controller, animated: true)
  }

}

extension AlbumListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let viewModel = viewModel else { return 0 }
    return viewModel.getItems().count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell, let album = viewModel?.getItems()[indexPath.row] else {
      return UICollectionViewCell()
    }

    cell.bind(viewModel: album)

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let selectedItem = viewModel?.getItems()[indexPath.row], let itemId = selectedItem.id else {
      return
    }
    viewModel?.navigateToPhotos(by: itemId)
  }

}

extension AlbumListViewController: UICollectionViewDelegateFlowLayout {

  private var padding: CGFloat {
    return 16
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let size = UIScreen.main.bounds.width / itemsPerRow - padding * 2

    return CGSize(width: size, height: size + size / 3)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: padding, left: padding, bottom: 0, right: padding)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return padding / 2
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return padding / 2
  }
}

