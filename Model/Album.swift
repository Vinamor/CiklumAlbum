//
//  Album.swift
//  CiklumAlbum
//
//  Created by Ostap Romaniv on 25.07.2021.
//

import ObjectMapper

class Album: Mappable {

  var userId: Int?
  var id: Int?
  var title: String?
  var coverURL: String?

  required init?(map: Map) {}

  func mapping(map: Map) {
    userId <- map["userId"]
    id <- map["id"]
    title <- map["title"]
  }
}
