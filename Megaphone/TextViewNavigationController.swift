    //
//  TextViewNavigationController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/28.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
    
//protocol TextViewNavigationDelegate {
//    func relayText(text: String?, completion: () -> Void)
//}

class TextViewNavigationController: UINavigationController {
    
    static let nibName = "TextViewNavigationController"
//    var textViewDelegate: TextViewNavigationDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

//        if let viewController = self.navigationController?.childViewControllers.first as? TextViewController {
//            viewController.delegate = self
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
    
//extension TextViewNavigationController: TextViewControllerDelegate {
//    func getTextView(text: String?, completion: () -> Void) {
//        textViewDelegate.relayText(text: text, completion: completion)
//    }
//}
