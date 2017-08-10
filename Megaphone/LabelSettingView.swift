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
    // フォント色・枠色の切り替え
    func closeTapped()
    func modeChange(isFont: Bool)
    func colorViewTapped(isFont: Bool, color: UIColor)
    func movedSlider(sender: UISlider, isFont: Bool, color: UIColor)
}

class LabelSettingView: UIView {
    
    static let nibName = "LabelSettingView"
    
    // 塗りつぶしボタン
    @IBOutlet weak var fill: UIImageView!
    // 枠線ボタン
    @IBOutlet weak var stroke: UIImageView!
    // 閉じるボタン
    @IBOutlet weak var close: UIImageView!
    
    @IBOutlet weak var sliderLeftImage: UIImageView!
    
    @IBOutlet weak var sliderRightImage: UIImageView!
    
    
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
    
    // 選択中の色Viewを囲む線の太さ
    let colorViewOutlineWidth: CGFloat = 2.0
    let colorViewOutlineColor = UIColor.white
    
    var delegate: LabelSettingViewDelegate!
    // 選択しているColorView
    var selectView: UIView?
    
    // デフォルトでフォント色の変更になっている。falseのときは枠色を選択している状態
    var isFontColorSelected = true
    
    override func awakeFromNib() {
        
        self.backgroundColor = UIColor.darkGray
        
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
        
        // スライダーの初期位置
        slider.value = 0.1
        
        /* ジェスチャ関連登録 */
        
        // 親Viewのタップ判定を奪うために空実装
        self.onTap { _ in
            
        }
        
        /// フォント色選択時
        fill.onTap { _ in
            self.delegate.modeChange(isFont: true)
        }
        
        stroke.onTap { _ in
            self.delegate.modeChange(isFont: false)
        }
        
        /// 閉じるボタン
        close.onTap { _ in
            // subViewから自身を取り除く
            self.delegate.closeTapped()
        }
        
        /// 色選択系
        redView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.redView)
            self.redView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.redView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.red)
        }
        
        orangeView.onTap{ _ in
            deleteDrawLineOtherColorView(view: self.orangeView)
            self.orangeView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.orangeView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.orange)
        }
        
        greenView.onTap{ _ in
            deleteDrawLineOtherColorView(view: self.greenView)
            self.greenView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.greenView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.iconGreen)
        }
        
        blueView.onTap{ _ in
            deleteDrawLineOtherColorView(view: self.blueView)
            self.blueView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.blueView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.blue)
        }
        
        purpleView.onTap{ _ in
            deleteDrawLineOtherColorView(view: self.purpleView)
            self.purpleView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.purpleView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.purple)
        }
        
        grayView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.grayView)
            self.grayView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.grayView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.gray_e8e8e8)
        }
        
        pinkView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.pinkView)
            self.pinkView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.pinkView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.pink)
        }
        
        yellowView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.yellowView)
            self.yellowView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.yellowView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.iconYellow)
        }
        
        yellowGreenView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.yellowGreenView)
            self.yellowGreenView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.yellowGreenView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.yellowGreen)
        }
        
        lightBlueView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.lightBlueView)
            self.lightBlueView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.lightBlueView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: ConstColor.lightBlue)
        }
        
        blackView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.blackView)
            self.blackView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.blackView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: UIColor.black)
        }
        
        whiteView.onTap { _ in
            deleteDrawLineOtherColorView(view: self.whiteView)
            self.whiteView.drawLine(color: self.colorViewOutlineColor, lineWidth: self.colorViewOutlineWidth)
            self.selectView = self.whiteView
            self.delegate.colorViewTapped(isFont: self.isFontColorSelected, color: UIColor.white)
        }
        
        // TODO: 他の色Viewにラインのレイヤーが載っていたら削除する共有処理がほしい
        func deleteDrawLineOtherColorView(view: UIView) {
            if selectView != nil {
                // 選択中のViewがあったらそのViewの一番上のレイヤを削除
                selectView?.layer.sublayers?.last?.removeFromSuperlayer()
                // 自身を選択中にする
                selectView = view
            } else {
                // 選択中のViewがなかったら自分を選択中にする
                selectView = view
            }
        }
            
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
       
        guard let select = selectView else {
           return
        }
        
        guard let backgroundColor = select.backgroundColor else {
            return
        }
        
        delegate.movedSlider(sender: sender, isFont: isFontColorSelected, color: backgroundColor)
    }
    
    
}
