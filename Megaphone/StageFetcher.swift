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

    static func stageJson(completion: @escaping (Data) -> [StageEntity]) {
        
        Alamofire.request("", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            
            guard let data = response.data else {
                return
            }
            
            completion(data)
            
        })
        
    }
    
}
