//
//  NamingLabelView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/28.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol NamingLabelViewDelegate {
    func namingViewClose()
    func nimingLabelTapped()
}

class NamingLabelView: UIView {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var namingLabel: UILabel!
    
    var delegate: NamingLabelViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // 閉じるボタンが押された時呼ばれる
    @IBAction func close(_ sender: Any) {
        delegate.namingViewClose()
    }
    
    // TODO: ラベルがタップされたときに呼ばれるメソッド実装
}
