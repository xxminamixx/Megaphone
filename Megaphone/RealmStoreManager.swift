//
//  RealmStoreManager.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/01.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import RealmSwift

class RealmStoreManager: NSObject {
    
    // MARK: LabelEntity
    
    /// エンティティを永続化
    ///
    /// - Parameter object: ステージごとのLabel情報がまとまったEntity
    static func addLabelEntity(object: LabelOfStageEntity) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }
    
    // 指定したキーを持つEntityを削除
    static func deleteLabelEntity(key: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(listLabelEntity().filter("key == %@", key))
        }
    }
    
    
    /// 永続化しているEntityを配列で返す
    ///
    /// - Returns: LabelOfStageEntity配列
    static private func listLabelEntity() -> Results<LabelOfStageEntity> {
        let realm = try! Realm()
        return realm.objects(LabelOfStageEntity.self)
    }
    
    
    /// 配列の個数を返す
    ///
    /// - Returns: 配列個数
    static func countLalbeEntity() -> Int {
        return RealmStoreManager.listLabelEntity().count
    }
    
    
    /// 指定したステージのEntityを取り出す
    ///
    /// - Parameter key: ステージ名
    /// - Returns: 指定したステージのEntity
    static func picLabelEntity(key: String) -> LabelOfStageEntity? {
        if RealmStoreManager.listLabelEntity().filter("key == %@", key).count > 0 {
            guard let result = RealmStoreManager.listLabelEntity().filter("key == %@", key).first else {
                return nil
            }
            
            return result
        } else {
            return nil
        }
    }
    
    // MARK: StampEntity
    
    static func addStampEntity(object: StampStoreEntityList) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }
    
    // 指定したキーを持つEntityを削除
    static func deleteStampEntity(key: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(listStampEntity().filter("key == %@", key))
        }
    }
    
    
    /// 永続化しているEntityを配列で返す
    ///
    /// - Returns: LabelOfStageEntity配列
    static private func listStampEntity() -> Results<StampStoreEntityList> {
        let realm = try! Realm()
        return realm.objects(StampStoreEntityList.self)
    }
    
    
    /// 配列の個数を返す
    ///
    /// - Returns: 配列個数
    static func countStampEntity() -> Int {
        return RealmStoreManager.listStampEntity().count
    }
    
    
    /// 指定したステージのEntityを取り出す
    ///
    /// - Parameter key: ステージ名
    /// - Returns: 指定したステージのEntity
    static func picStampEntity(key: String) -> StampStoreEntityList? {
        if RealmStoreManager.listStampEntity().filter("key == %@", key).count > 0 {
            guard let result = RealmStoreManager.listStampEntity().filter("key == %@", key).first else {
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
