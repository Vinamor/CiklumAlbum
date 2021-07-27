//
//  Extension.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import UIKit

extension UIImageView {
  public func imageFromUrl(urlString: String?) {
    guard image == nil else { return }
    if let urlString = urlString, let url = URL(string: urlString) {
      let session = URLSession(configuration: .ephemeral)
      let downloadTask = session.downloadTask(with: url) { [weak self] (url, _, _) in
        if let url = url {
          if let data = try? Data(contentsOf: url) {
            DispatchQueue.main.async {
              self?.image = UIImage(data: data)
              print("Loaded image")
            }
          }
        }
      }
      downloadTask.resume()
    }
  }
}
