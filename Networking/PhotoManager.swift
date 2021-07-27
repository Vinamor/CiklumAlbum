//
//  PhotoManager.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 26.07.2021.
//

import UIKit

protocol PhotoManagerType {
  func downloadImage(from imageURLString: String?, completion: @escaping (UIImage?) -> Void)
}

class PhotoManager: PhotoManagerType {
  func downloadImage(from imageURLString: String?, completion: @escaping (UIImage?) -> Void) {
    guard let urlString = imageURLString, let url = URL(string: urlString) else { return }
    let session = URLSession(configuration: .default)
    let downloadTask = session.downloadTask(with: url) { (url, _, _) in
      guard let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
        completion(nil)
        return
      }
      completion(image)
    }
    downloadTask.resume()
  }
}
