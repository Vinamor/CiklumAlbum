//
//  PhotoDetailViewController.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ReactiveSwift
import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate{

  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

  var viewModel: PhotoDetailsViewModelType?
  private let (lifetime, token) = Lifetime.make()

  override func viewDidLoad() {
    super.viewDidLoad()
    overrideUserInterfaceStyle = .dark
    scrollView.delegate = self
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 10.0
    viewModel?.image.producer
      .take(during: lifetime)
      .observe(on: UIScheduler())
      .startWithValues { [weak self] in
        self?.activityIndicator.isHidden = $0 != nil
        self?.imageView.image = $0
        $0 == nil ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
    }
  }

  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

}
