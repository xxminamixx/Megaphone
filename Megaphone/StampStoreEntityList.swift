//
//  StampStoreEntityList.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/15.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

class StampStoreEntityList: Object {
    let stampList = List<StampStoreEntity>()
    dynamic var key: String?
}
