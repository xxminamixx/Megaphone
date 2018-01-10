//
//  StageFetcher.swift
//  Megaphone
//
//  Created by 南　京兵 on 2018/01/05.
//  Copyright © 2018年 南　京兵. All rights reserved.
//

import UIKit
import Alamofire

class StageFetcher: NSObject {

    static func stageJson(completion: @escaping () -> Void) {
        
        Alamofire.request("https://dl.dropboxusercontent.com/s/r6ej1zl8q0bdvzs/stage.json?dl=0", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            
            guard let data = response.data else {
                return
            }
            
            JsonManager.shared.stageList(data: data, completion: completion)
        })
    }
    
    static func stageImage(url: String, completion: (Data) -> Void) {
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData(completionHandler: { response in
            
            guard let data = response.data else {
                return
            }
            
            // TODO: Data型からUIImageを生成するクロージャ
            print(data)
        })
        
    }
    
}
