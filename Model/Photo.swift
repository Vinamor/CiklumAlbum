//
//  Photo.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ObjectMapper
import ReactiveSwift

class Photo: Mappable {
  var albumId: Int?
  var id: Int?
  var url: String?
  var thumbnailURL: String?

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    albumId <- map["albumId"]
    id <- map["id"]
    url <- map["url"]
    thumbnailURL <- map["thumbnailUrl"]
  }
}
