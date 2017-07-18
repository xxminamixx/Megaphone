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
    var stages: Array<String>?
    
    override init() {
        super.init()
        stages = stageList()
    }
    
    /// jsonを読み込んでステージ配列を返す
    ///
    /// - Returns: ステージ配列
    func stageList() -> Array<String>? {
        let json = try! JSONSerialization.jsonObject(with: getResourceJson(name: "stage")!,
                                                     options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        
        guard let stages = json.value(forKey: "stage") as! Array<String>? else {
            return nil
        }
        
        // ステージ配列を返す
        return stages
    }
    
    /// jsonデータをData型で返す
    ///
    /// - Parameter name: ファイル名
    /// - Returns: jsonをDataにしたもの
    func getResourceJson(name:String) -> Data? {
        let bundlePath : String = Bundle.main.path(forResource: "Resource", ofType: "bundle")!
        let bundle = Bundle(path: bundlePath)!
        if let jsonPath : String = bundle.path(forResource: name, ofType: "json") {
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

}
