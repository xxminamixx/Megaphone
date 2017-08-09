//
//  RealmManager.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/01.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import RealmSwift

class LabelStoreManager: NSObject {
    
    
    /// エンティティを永続化
    ///
    /// - Parameter object: ステージごとのLabel情報がまとまったEntity
    static func add(object: LabelOfStageEntity) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }
    
    // 指定したキーを持つEntityを削除
    static func delete(key: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(list().filter("key == %@", key))
        }
    }
    
    
    /// 永続化しているEntityを配列で返す
    ///
    /// - Returns: LabelOfStageEntity配列
    static private func list() -> Results<LabelOfStageEntity> {
        let realm = try! Realm()
        return realm.objects(LabelOfStageEntity.self)
    }
    
    
    /// 配列の個数を返す
    ///
    /// - Returns: 配列個数
    static func count() -> Int {
        return LabelStoreManager.list().count
    }
    
    
    /// 指定したステージのEntityを取り出す
    ///
    /// - Parameter key: ステージ名
    /// - Returns: 指定したステージのEntity
    static func pic(key: String) -> LabelOfStageEntity? {
        if LabelStoreManager.list().filter("key == %@", key).count > 0 {
            guard let result = LabelStoreManager.list().filter("key == %@", key).first else {
                return nil
            }
            
            return result
        } else {
            return nil
        }
    }
    
    // MARK: Utility
    
    /// クロージャに更新処理を渡す
    ///
    /// - Parameter closure: 更新処理
    static func save(closure: () -> Void) {
        let realm = try! Realm()
        try! realm.write {
            closure()
        }
    }
    
}
