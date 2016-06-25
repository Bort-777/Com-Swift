//
//  Book.swift
//  ZbranevichComics
//
//  Created by user on 6/20/16.
//  Copyright © 2016 itransition. All rights reserved.
//

import Foundation
import RealmSwift

class Book: Object {
    
    dynamic var id : Int = 0
    dynamic var name : String = ""
    let page = List<Page>()
    
    override static func primaryKey() -> String? {
        return "id"
    }

    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
