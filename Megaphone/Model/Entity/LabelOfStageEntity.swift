//
//  LabelOfStageEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/01.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

class LabelOfStageEntity: Object {
    let labelList = List<LabelEntity>()
    dynamic var key: String?
}
