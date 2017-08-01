//
//  RealmManager.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/01.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import RealmSwift

class RealmManager: NSObject {
    
    
    /// エンティティを永続化
    ///
    /// - Parameter object: ステージごとのLabel情報がまとまったEntity
    func add(object: LabelOfStageEntity) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }

}
