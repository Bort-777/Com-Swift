//
//  Page.swift
//  ZbranevichComics
//
//  Created by user on 6/16/16.
//  Copyright © 2016 itransition. All rights reserved.
//

import Foundation
import RealmSwift

class Page: Object {
    
    dynamic var id: Int = 0
    dynamic var URL = ""
    let data = List<Media>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
// Specify properties to ignore (Realm won't persist these)
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
