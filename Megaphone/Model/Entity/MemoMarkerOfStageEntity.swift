//
//  MemoMarkerOfStageEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/10/10.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

class MemoMarkerOfStageEntity: Object {
    let markerList = List<MemoMarkerEntity>()
    dynamic var key: String?
}
