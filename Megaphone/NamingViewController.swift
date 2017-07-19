//
//  NamingViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class NamingViewController: UIViewController {
    
    static let identifier = "NamingViewController"
    var imageView: UIImageView?
    var actionTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = imageView {
            self.view.addSubview(image)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// タッチした座標を取得
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch!.location(in: self.view)
        let textView = UITextView(frame: CGRect.init(x: point.x, y: point.y, width: 150, height: 20))
        
        //ビューを作成する。
        let testView = UIView()
        testView.frame.size.height = 50
        testView.backgroundColor = UIColor.gray
        
        //「閉じるボタン」を作成する。
        let closeButton = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 70, y: 0, width: 70, height: 50))
        closeButton.setTitle("閉じる", for:UIControlState.normal)
        closeButton.addTarget(self,action: #selector(onClickCloseButton), for: .touchUpInside)
        
        //ビューに「閉じるボタン」を追加する。
        testView.addSubview(closeButton)
        
        //キーボードのアクセサリにビューを設定する。
        textView.inputAccessoryView = testView
        
        //テキストビューのデリゲート先にこのインスタンスを設定する。
        textView.delegate = self
        
        textView.text = "名前をつけてください"
        textView.textColor = UIColor.lightGray
        
        self.view.addSubview(textView)
    }
    
    func onClickCloseButton() {
        if !(actionTextView?.hasText)! {
            // テキストが入力されていない
            actionTextView?.text = "名前をつけてください"
            actionTextView?.textColor = UIColor.lightGray
            actionTextView?.sizeToFit()
        }
        actionTextView?.resignFirstResponder()
    }
}

extension NamingViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        actionTextView = textView
        actionTextView?.delegate = textView.delegate
        actionTextView?.text = ""
        actionTextView?.textColor = UIColor.black
        return true
    }
}
