//
//  FetchStoreEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2018/01/22.
//  Copyright © 2018年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

class FetchStoreEntity: Object {
    /// 一度フェッチしたStageEntityを永続化する用のエンティティ
    let stageEntity = List<StageEntity>()
}
