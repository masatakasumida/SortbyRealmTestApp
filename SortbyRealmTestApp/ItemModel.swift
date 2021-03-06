//
//  ItemModel.swift
//  SortbyRealmTestApp
//
//  Created by 住田雅隆 on 2022/04/07.
//

import UIKit
import RealmSwift

class ItemList: Object {
    let list = List<Item>()
}

class Item: Object {
    @objc dynamic var title: String = ""
    
    @objc dynamic var checkMark: Bool = false
}
