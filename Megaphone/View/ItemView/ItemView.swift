//
//  ItemView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/03.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import GestureRecognizerClosures

protocol ItemViewDelegate {
    // 削除ボタン
    func allDeleteTapped()
    //  塗りつぶしボタン
    func fillTapped()
    // 枠線ボタン
    func strokeTapped()
    // スタンプボタンタップ
    func stampTapped()
    // twitterボタン
    func twitterTapped()
    // スクショボタン
    func screenShotTapped()
}

class ItemView: UIView {
    
    @IBOutlet weak var screenShotButton: UIImageView!
    @IBOutlet weak var twitterButton: UIImageView!
    @IBOutlet weak var partitionView: UIView!
    @IBOutlet weak var allDeleteButton: UIImageView!
    @IBOutlet weak var fillButton: UIImageView!
    @IBOutlet weak var strokeButton: UIImageView!
    @IBOutlet weak var stampButton: UIImageView!
    
    @IBOutlet weak var stampStackView: UIStackView!
    
    static let nibName = "ItemsView"
    
    var delegate: ItemViewDelegate!
    
    override func awakeFromNib() {
        
        stampStackView.isHidden = true
        
        // NavigationBarとの仕切りViewの色を設定
        partitionView.backgroundColor = ConstColor.separatorYellow
        // 背景色を設定
        self.backgroundColor = ConstColor.iconYellow
        
        self.onTap{ _ in }
        
        allDeleteButton.onTap { _ in
            // タップしたことを実装側に通知
            self.delegate.allDeleteTapped()
        }
        
        fillButton.onTap { _ in
            self.delegate.fillTapped()
        }
        
        strokeButton.onTap { _ in 
            self.delegate.strokeTapped()
        }
        
        stampButton.onTap { _ in
            self.delegate.stampTapped()
        }
        
        twitterButton.onTap { _ in
            self.delegate.twitterTapped()
        }
        
        screenShotButton.onTap { _ in
            self.delegate.screenShotTapped()
        }
        
        super.awakeFromNib()
    }

}