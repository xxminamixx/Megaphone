//
//  RealmStoreManager.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/01.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import RealmSwift

// TOOD: 各種Entityごとに同じようなメソッドを作成しているのでジェネリクスにしたい
class RealmStoreManager: NSObject {
    
    // MARK: ジェネリック関数
    
    /// RealmのObjectEntityを保存
    ///
    /// - Parameter object: Objectを継承したEntity
    static func addEntity<T: Object>(object: T) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }

    
    /// 指定したtypeのEntityListを返却する
    ///
    /// - Parameter type: Entityの型を指定する
    /// - Returns: 指定されたEntityListを返却する
    static func entityList<T: Object>(type: T.Type) -> Results<T> {
        let realm = try! Realm()
        return realm.objects(type.self)
    }
    
    
    /// 指定したtypeのEntityListの長さを返す
    ///
    /// - Parameter type: Entityの型を指定する
    /// - Returns: 指定されたEntityListの長さを返す
    static func countEntity<T: Object>(type: T.Type) -> Int {
       return entityList(type: type).count
    }
    
    // TODO: filterを使っている関数をどう汎用化するか。このクラスが持つべきなのか使う側が管理するべきなのか考えたい
    
    
    /// 指定した型のEntityから任意のプロパティを指定してフィルタリングした配列を返却する
    ///
    /// - Parameters:
    ///   - type: Entityの型を指定する
    ///   - property: フィルタリングをしたいプロパティ名を指定する
    ///   - filter: フィルタリング条件を入力する(型がわからないのでAny型としている)
    /// - Returns: フィルタリングされたEntityが返却される
    static func filterEntityList<T: Object>(type: T.Type, property: String, filter: Any) -> Results<T> {
        return entityList(type: type).filter("%@ == %@", property, filter)
    }
    
    // MARK: LabelEntity
    
    // 指定したキーを持つEntityを削除
    static func deleteLabelEntity(key: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(entityList(type: LabelEntity.self).filter("key == %@", key))
        }
    }
    
    /// 指定したステージのEntityを取り出す
    ///
    /// - Parameter key: ステージ名
    /// - Returns: 指定したステージのEntity
    static func picLabelEntity(key: String) -> LabelOfStageEntity? {
        if entityList(type: LabelOfStageEntity.self).filter("key == %@", key).count > 0 {
            guard let result = entityList(type: LabelOfStageEntity.self).filter("key == %@", key).first else {
                return nil
            }
            
            return result
        } else {
            return nil
        }
    }
    
    // 指定したキーを持つEntityを削除
    static func deleteStampEntity(key: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(entityList(type: StageEntity.self).filter("key == %@", key))
        }
    }
    
    /// 指定したステージのEntityを取り出す
    ///
    /// - Parameter key: ステージ名
    /// - Returns: 指定したステージのEntity
    static func picStampEntity(key: String) -> StampStoreEntityList? {
        if entityList(type: StampStoreEntityList.self).filter("key == %@", key).count > 0 {
            guard let result = entityList(type: StampStoreEntityList.self).filter("key == %@", key).first else {
                return nil
            }
            
            return result
        } else {
            return nil
        }
    }
    
    // MARK: FetchEntity
    
    /// StageEntityが永続化されているかを返す。
    ///
    /// - Parameter name: ステージ名
    /// - Returns: 入力されたステージが永続化されているかのBOOL値
    static func isStoreStageName(stage: String) -> Bool {
        // TOOD: もうちょっといい実装がありそう
        for entity in entityList(type: FetchStoreEntity.self) {
            if entity.stageEntity?.stage == stage {
                return true
            }
        }
        return false
    }
    
    static func stageEntity(filter: String) -> Results<FetchStoreEntity> {
        return entityList(type: FetchStoreEntity.self).filter("stage == %@", filter)
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
