//
//  JsonManager.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class JsonManager: NSObject {
    
    
    /// jsonを読み込んでステージ配列を返す
    ///
    /// - Returns: ステージ配列
    static func stageList() -> Array<String>? {
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
    static func getResourceJson(name:String) -> Data? {
        let bundlePath : String = Bundle.main.path(forResource: "Resources", ofType: "bundle")!
        let bundle = Bundle(path: bundlePath)!
        if let jsonPath : String = bundle.path(forResource: name, ofType: "json") {
            let fileHandle : FileHandle = FileHandle(forReadingAtPath: jsonPath)!
            let jsonData : Data = fileHandle.readDataToEndOfFile()
            return jsonData
        }
        return nil
    }

}
