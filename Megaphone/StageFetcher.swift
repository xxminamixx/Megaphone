//
//  StageFetcher.swift
//  Megaphone
//
//  Created by 南　京兵 on 2018/01/05.
//  Copyright © 2018年 南　京兵. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class StageFetcher: NSObject {

    static func stageJson(completion: @escaping () -> Void) {
        
        Alamofire.request("https://dl.dropboxusercontent.com/s/r6ej1zl8q0bdvzs/stage.json?dl=0", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            
            guard let data = response.data else {
                return
            }
            
            JsonManager.shared.stageList(data: data, completion: completion)
        })
    }
    
    static func stageImage(url: String, completion: @escaping (UIImage) -> Void) {
        // サーバ側のURLがミスっているので現状はソースコードで修正
        let downloadURL = url.replacingOccurrences(of: ConstText.dropboxHost, with: ConstText.downloadHost)
        
        Alamofire.request(downloadURL).validate().responseImage{ response in
            switch response.result {
            case .success:
                guard let data = response.result.value else {
                    return
                }
                completion(data)
            case .failure:
                break
            }
        }
        
    }
    
}
