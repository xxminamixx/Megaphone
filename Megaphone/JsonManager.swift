//
//  JsonManager.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class JsonManager: NSObject {
    
    static let shared = JsonManager()
    /// ステージ配列
    var stages: Array<StageEntity>?
    /// スタンプ配列
    var stamps: Array<StampEntity>?
    
    override init() {
        super.init()
        stages = stageList()
        stamps = stampList()
    }
    
    /// jsonを読み込んでステージ配列を返す
    ///
    /// - Returns: ステージ配列
    func stageList() -> [StageEntity]? {
        let json = try! JSONSerialization.jsonObject(with: getResourceJson(name: ConstText.stageFileName)!,
                                                     options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        
        guard let stages = json.value(forKey: ConstText.stageKey) as! Array<Dictionary<String, String>>? else {
            return nil
        }
        
        var items: [StageEntity] = []
        for item in stages {
            let entity = StageEntity()
            entity.stageName = item[ConstText.stageKey]
            entity.imageName = item[ConstText.imageKey]
            items.append(entity)
        }
        
        return items
    }
    
    func stampList() -> [StampEntity]? {
        let json = try! JSONSerialization.jsonObject(with: getResourceJson(name: ConstText.stampFileName)!,
                                                     options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        
        guard let stages = json.value(forKey: ConstText.stampKey) as! Array<String>? else {
            return nil
        }
        
        var items: [StampEntity] = []
        for item in stages {
            let entity = StampEntity()
            entity.name = item
            items.append(entity)
        }
        
        return items
    }
    
    /// jsonデータをData型で返す
    ///
    /// - Parameter name: ファイル名
    /// - Returns: jsonをDataにしたもの
    private func getResourceJson(name:String) -> Data? {
        let bundlePath : String = Bundle.main.path(forResource: ConstText.resouce, ofType: ConstText.bundle)!
        let bundle = Bundle(path: bundlePath)!
        if let jsonPath : String = bundle.path(forResource: name, ofType: ConstText.json) {
            let fileHandle : FileHandle = FileHandle(forReadingAtPath: jsonPath)!
            let jsonData : Data = fileHandle.readDataToEndOfFile()
            return jsonData
        }
        return nil
    }
    
    
    /// ステージ個数を返す
    ///
    /// - Returns: jsonのパースに失敗していた場合0、成功していたらステージの個数を返す
    func stageCount() -> Int {
        guard let count = stages?.count else {
            return 0
        }
        return count
    }
    
    func stampCount() -> Int {
        guard let count = stamps?.count else {
            return 0
        }
        return count
    }

}
