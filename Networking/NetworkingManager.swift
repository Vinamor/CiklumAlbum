//
//  NetworkingManager.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import Alamofire
import AlamofireObjectMapper

private enum Requests: String {
  case albums = "https://jsonplaceholder.typicode.com/albums"
  case photos = "https://jsonplaceholder.typicode.com/photos"

  func url(with parameterName: String, value: String) -> URL? {
    switch self {
    case .albums: return URL(string: rawValue + "?" + parameterName + "=" + value)
    case .photos: return URL(string: rawValue + "?" + parameterName + "=" + value)
    }
  }
}

protocol NetworkingManagerType {
  func fetchAlbums(completion: @escaping ([Album], _ error: Error?) -> ())
  func fetchPhotos(for albumId: Int?, completion: @escaping ([Photo], _ error: Error?) -> ())
}

class NetworkingManager: NetworkingManagerType {

  func fetchAlbums(completion: @escaping ([Album], _ error: Error?) -> ()) {
    guard let url = URL(string: Requests.albums.rawValue) else {
      completion([], nil)
      return
    }
    AF.request(url, method: .get, encoding: URLEncoding.default)
      .responseJSON { response in
        switch response.result {
        case .success(let json):
          guard let jsons = json as? [[String : Any]] else {
            completion([], nil)
            return
          }
          let albums = jsons.compactMap { Album(JSON: $0) }
          let group = DispatchGroup()
          albums.forEach {
            group.enter()
            self.fetchPhotoInfo(for: $0) {
              group.leave()
            }
          }
          group.notify(queue: .main) {
            completion(albums, nil)
          }
        case .failure(let error):
          completion([], error)
        }
    }
  }

  func fetchPhotoInfo(for album: Album, completion: @escaping () -> Void) {
    guard let albumId = album.id, let url = Requests.photos.url(with: "albumId", value: "\(albumId)") else {
      return
    }
    AF.request(url, method: .get, encoding: URLEncoding.default).responseJSON { response in
      switch response.result {
      case .success(let json):
        guard let jsons = json as? [[String: Any]], let firstPhoto = jsons.first else {
          return
        }
        let photo = Photo(JSON: firstPhoto)
        album.coverURL = photo?.url
      default: break
      }
      completion()
    }
  }

  func fetchPhotos(for albumId: Int?, completion: @escaping ([Photo], _ error: Error?) -> ()) {
    guard let albumId = albumId, let url = Requests.photos.url(with: "albumId", value: "\(albumId)") else {
      completion([], nil)
      return
    }
    AF.request(url, method: .get, encoding: URLEncoding.default).responseJSON { response in
      switch response.result {
      case .success(let json):
        guard let jsons = json as? [[String: Any]] else {
          completion([], nil)
          return
        }
        let photos = jsons.compactMap { Photo(JSON: $0) }
        completion(photos, nil)
      case .failure(let error):
        completion([], error)
      }
    }
  }
}
