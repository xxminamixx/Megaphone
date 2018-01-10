//
//  StageEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

// jsonパース用のエンティティ
struct StageList: Codable {
    var stage: [StageEntity]?
}

struct StageEntity: Codable {
    var stage: String?
    var url: String?
}
