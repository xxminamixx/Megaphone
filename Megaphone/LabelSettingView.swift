//
//  LabelSettingView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/07.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import GestureRecognizerClosures

protocol LabelSettingViewDelegate {
    func colorViewTapped(isFont: Bool, color: UIColor)
}

class LabelSettingView: UIView {
    
    static let nibName = "LabelSettingView"
    
    // 閉じるボタン
    @IBOutlet weak var close: UIImageView!
    
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var orangeView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var purpleView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var pinkView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var yellowGreenView: UIView!
    @IBOutlet weak var lightBlueView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var whiteView: UIView!
    
    @IBOutlet weak var slider: UISlider!
    
    var delegate: LabelSettingViewDelegate!
    
    // デフォルトでフォント色の変更になっている。falseのときは枠色を選択している状態
    var isFontColorSelected = true
    
    override func awakeFromNib() {
        
        /* 色選択Viewの背景色設定 */
        redView.backgroundColor = ConstColor.red
        orangeView.backgroundColor = ConstColor.orange
        greenView.backgroundColor = ConstColor.iconGreen
        blueView.backgroundColor = ConstColor.blue
        purpleView.backgroundColor = ConstColor.purple
        grayView.backgroundColor = ConstColor.gray_e8e8e8
        pinkView.backgroundColor = ConstColor.pink
        yellowView.backgroundColor = ConstColor.iconYellow
        yellowGreenView.backgroundColor = ConstColor.yellowGreen
        lightBlueView.backgroundColor = ConstColor.lightBlue
        blackView.backgroundColor = UIColor.black
        whiteView.backgroundColor = UIColor.white
        // 背景色と同じで見えないので
        whiteView.drawLine(color: UIColor.gray, lineWidth: 1.0)
        
        /* ジェスチャ関連登録 */
        
        /// フォント色選択時
        self.onTap { _ in
            
        }
        
        /// 閉じるボタン
        close.onTap { _ in
            // subViewから自身を取り除く
            self.removeFromSuperview()
        }
        
        /// 色選択系
        redView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.red)
        }
        
        orangeView.onTap{ _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.orange)
        }
        
        greenView.onTap{ _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.iconGreen)
        }
        
        blueView.onTap{ _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.blue)
        }
        
        purpleView.onTap{ _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.purple)
        }
        
        grayView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.gray_e8e8e8)
        }
        
        pinkView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.pink)
        }
        
        yellowView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.iconYellow)
        }
        
        yellowGreenView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.yellowGreen)
        }
        
        lightBlueView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.lightBlue)
        }
        
        blackView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: UIColor.black)
        }
        
        whiteView.onTap { _ in
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: UIColor.white)
        }
    }
    
    @IBAction func moveToSlider(_ sender: Any) {
    
    }
    
}
