//
//  AlertControllerManager.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/03.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class AlertControllerManager {
    
    /// ボタンアクションをクロージャで受け取れるタイプのダイアログ
    ///
    /// - Parameters:
    ///   - title: タイトル
    ///   - message: メッセージ
    ///   - defaultAction: ボタン押下時の処理クロージャー
    /// - Returns: UIAlertController
    static func customActionAlert (title: String?, message: String, defaultAction: @escaping (_ action: UIAlertAction?) -> Void) -> UIAlertController {
        var alertController: UIAlertController
        if let title = title {
            alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        } else {
            alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        }
        
        let defaultAction = UIAlertAction(title: ConstText.ok, style: .default, handler: defaultAction)
        let cancelAction = UIAlertAction(title: ConstText.cancel, style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(defaultAction)
        
        return alertController
    }
    
    static func noActionAlert(title: String?, message: String) -> UIAlertController{
        var alertController: UIAlertController
        if let title = title {
            alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        } else {
            alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        }
        
        return alertController
    }
    
}
