//
//  TextViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/28.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

@objc protocol TextViewControllerDelegate {
    func getTextView(text: String?, completion: () -> Void)
}

class TextViewController: UIViewController {
    
    static let nibName = "TextViewController"
    
    @IBOutlet weak var buttomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    var delegate: TextViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テキストビューの色を変更
        textView.backgroundColor = UIColor.darkGray
        // テキストの色を白に変更
        textView.textColor = UIColor.white
        // キーボードを表示する
        textView.becomeFirstResponder()
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(showKeyboard), name: .UIKeyboardDidShow, object: nil)
        
        // navigationControllrの色変更
        navigationController?.navigationBar.barTintColor = ConstColor.iconYellow
        
        /* NavigationBarにボタンアイテムを追加 */
        let rightDoneButton = UIButton()
        rightDoneButton.setTitle("完了", for: .normal)
        rightDoneButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        rightDoneButton.setTitleColor(UIColor.white, for: .normal)
        rightDoneButton.sizeToFit()
        rightDoneButton.addTarget(self, action: #selector(done), for: UIControlEvents.touchUpInside)
        
        let leftCloseButton = UIButton()
        leftCloseButton.setTitle("×", for: .normal)
        leftCloseButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        leftCloseButton.setTitleColor(UIColor.white, for: .normal)
        leftCloseButton.sizeToFit()
        leftCloseButton.addTarget(self, action: #selector(close), for: UIControlEvents.touchUpInside)
        
        let rightDoneButtonItem = UIBarButtonItem(customView: rightDoneButton)
        let leftCloseButtonItem = UIBarButtonItem(customView: leftCloseButton)
        
        navigationItem.setRightBarButtonItems([rightDoneButtonItem], animated: true)
        navigationItem.setLeftBarButtonItems([leftCloseButtonItem], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // キーボードが出現したときに呼ばれる
    func showKeyboard(notification: Notification) {
        
        if let userInfo = notification.userInfo {
            if let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue{
                let keyBoardRect = keyboard.cgRectValue
                // テキストビューのボトムの高さをキーボードの高さにする。
                buttomConstraint.constant = keyBoardRect.size.height
            }
        }
        
    }
    
    // 完了ボタンが押された時に呼ばれる
    func done() {
        // テキストをデリゲート実装もとに返し、モーダルを閉じる
        delegate.getTextView(text: textView.text, completion:  {
            // モーダル画面より先にキーボードを閉じる
            textView.resignFirstResponder()
            // モーダル画面を閉じる
            dismiss(animated: true, completion: nil)
        })
    }
    
    // 閉じるボタンが押された時に呼ばれる
    func close() {
        // キーボードを閉じるてからモーダルを閉じる
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
}
