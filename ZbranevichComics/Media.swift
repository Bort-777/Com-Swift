//
//  Media.swift
//  ZbranevichComics
//
//  Created by user on 6/25/16.
//  Copyright © 2016 itransition. All rights reserved.
//

import Foundation
import RealmSwift

class Media: Object {
    
    dynamic var id = 0
    dynamic var x : Float = 0.0
    dynamic var y : Float = 0.0
    dynamic var width : Float = 0.0
    dynamic var height : Float = 0.0
    
    func setFrame(rect: CGRect) {
        self.x = Float(rect.minX)
        self.y = Float(rect.minY)
        self.width = Float(rect.width)
        self.height = Float(rect.height)

    }
    
    func setLocalURL(id: Int) {
        //TODO: save local
        self.id = id
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
