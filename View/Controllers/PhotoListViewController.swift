//
//  PhotoListViewController.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ReactiveSwift
import UIKit

class PhotoListViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  
  var viewModel: PhotoListViewModelType?

  private let itemsPerRow: CGFloat = 3

  private var (lifetime, token) = Lifetime.make()

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark
    collectionView.automaticallyAdjustsScrollIndicatorInsets = false
    collectionView.register(UINib(nibName: "PhotoCell", bundle: Bundle.main),
                                 forCellWithReuseIdentifier: "PhotoCell")
    viewModel?.reloadItemSignal
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .observeValues { [weak self] in
        self?.reloadItem(for: $0)
      }
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
        self?.navigateToPhotoDetailsViewController(with: $0)
      }
  }

  private func reloadItem(for itemId: Int?) {
    guard let itemId = itemId, let index = viewModel?.getItems().firstIndex(where: { $0.id == itemId }) else { return
    }
    collectionView.performBatchUpdates {
      collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
  }

  // MARK: - Navigation

  private func navigateToPhotoDetailsViewController(with viewModel: PhotoDetailsViewModelType) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let controller = storyboard.instantiateViewController(identifier: "PhotoDetailViewController") as? PhotoDetailViewController else { return }
    controller.viewModel = viewModel

    self.navigationController?.pushViewController(controller, animated: true)
  }

}

extension PhotoListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let viewModel = viewModel else { return 0 }
    return viewModel.getItems().count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell, let photo = viewModel?.getItems()[indexPath.row] else {
      return UICollectionViewCell()
    }

    cell.bind(viewModel: photo)

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let selectedItem = viewModel?.getItems()[indexPath.row] else {
      return
    }
    viewModel?.navigateToDetailedPhoto(with: selectedItem)
  }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {

  private var padding: CGFloat {
    return 8
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let size = UIScreen.main.bounds.width / itemsPerRow - padding

    return CGSize(width: size, height: size)
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
