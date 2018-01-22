//
//  StageEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

// jsonパース用のエンティティ
struct StageList: Codable {
    var stage: [StageEntity]?
}

class StageEntity: Object, Codable {
    dynamic var stage: String?
    dynamic var url: String?
}
