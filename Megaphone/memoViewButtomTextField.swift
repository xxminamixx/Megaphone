//
//  memoViewButtomTextField.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/10/10.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol memoViewButtomTextFieldDelegate {
    // メモビューがタップされてキーボードが出現したときにコールする
    func memoViewTapped(keyBoardRect: CGRect)
    // キーボードが消えた時にコールする
    func disableKeyBoard(text: String?)
}

class memoViewButtomTextField: UIView {
    
    static let nibName = "memoViewButtomTextField"
    
    var delegate: memoViewButtomTextFieldDelegate?

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(showKeyboard), name: .UIKeyboardDidShow, object: nil)
        
        //ボタンを追加するためのViewを生成します。
        let myKeyboard = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        myKeyboard.backgroundColor = UIColor.lightGray
        
        //完了ボタンの生成
        let myButton = UIButton(frame: CGRect(x: 300, y: 5, width: 70, height: 30))
        myButton.backgroundColor = UIColor.darkGray
        myButton.setTitle("完了", for: .normal)
        myButton.layer.cornerRadius = 2.0
        myButton.addTarget(self, action: #selector(onClickMyButton), for: .touchUpInside)
        
        //Viewに完了ボタンを追加する。 
        myKeyboard.addSubview(myButton)
        textView.inputAccessoryView = myKeyboard
//        textView.delegate = self
    }
    
    // キーボードが出現したときに呼ばれる
    func showKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue{
                let keyBoardRect = keyboard.cgRectValue
                // デリゲートをコール
                delegate?.memoViewTapped(keyBoardRect: keyBoardRect)
            }
        }
    }
    
    func onClickMyButton() {
        // キーボードを消す
        self.endEditing(true)
        // デリゲートをコール
        delegate?.disableKeyBoard(text: textView.text)
    }

}
