//
//  StampStoreEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/15.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

class StampStoreEntity: Object {
    dynamic var name: String?
    dynamic var pointX: CGFloat = 0.0
    dynamic var pointY: CGFloat = 0.0
    dynamic var width: CGFloat = 0.0
    dynamic var height: CGFloat = 0.0
}
