//
//  NavigationController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/01.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = ConstColor.iconYellow
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // NavigationBarにネーミングモード・メモモードを切り替えるUISwitchを配置
        let modeSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 30, height: 10))
        modeSwitch.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        self.navigationItem.rightBarButtonItem = modeSwitch
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // UISwitchの値が変更されたときにコールされる
    func switchChanged() {
        
    }
    
}

