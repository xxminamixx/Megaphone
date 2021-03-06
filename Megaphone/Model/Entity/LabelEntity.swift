//
//  LabelEntity.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/01.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

class LabelEntity: Object {
    dynamic var pointX: CGFloat = 0.0
    dynamic var pointY: CGFloat = 0.0
    dynamic var fontSize: CGFloat = 18.0
    dynamic var text: String?
    
    dynamic var attribute: Data?
}
