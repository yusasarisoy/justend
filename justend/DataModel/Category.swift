//
//  Category.swift
//  justend
//
//  Created by Yuşa Sarısoy on 8.05.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String?
    @objc dynamic var color: String?
    let items = List<Item>()
}
