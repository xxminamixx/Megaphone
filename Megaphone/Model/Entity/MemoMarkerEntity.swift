//
//  MemoMarkerEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/10/10.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

class MemoMarkerEntity: Object {
    dynamic var pointX: CGFloat = 0.0
    dynamic var pointY: CGFloat = 0.0
    dynamic var text: String?
}
