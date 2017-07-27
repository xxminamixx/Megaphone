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
    var scrollView: UIScrollView?
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView.delegate = self
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 3.0
        imageScrollView.contentMode = .scaleAspectFit
        
        self.imageView?.isUserInteractionEnabled = true
        
        // スクロールビューにタップジェスチャを登録
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped))
        imageScrollView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageScrollView.addSubview(imageView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // スクロールビューがタップされたとき呼ばれる
    func tapped(gesture: UITapGestureRecognizer) {
        for i in 0..<gesture.numberOfTouches {
            let point = gesture.location(ofTouch: i, in: self.view)
            let pointX = point.x
            let pointY = point.y
            print(pointX)
            print(pointY)
        }
//        let touch = touches.first
//        let point = touch!.location(in: self.scrollView)
//        let textView = UITextView(frame: CGRect.init(x: point.x, y: point.y, width: 150, height: 20))
//
//        //ビューを作成する。
//        let testView = UIView()
//        testView.frame.size.height = 50
//        testView.backgroundColor = UIColor.gray
//
//        //「閉じるボタン」を作成する。
//        let closeButton = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 70, y: 0, width: 70, height: 50))
//        closeButton.setTitle("閉じる", for:UIControlState.normal)
//        closeButton.addTarget(self,action: #selector(onClickCloseButton), for: .touchUpInside)
//
//        //ビューに「閉じるボタン」を追加する。
//        testView.addSubview(closeButton)
//
//        //キーボードのアクセサリにビューを設定する。
//        textView.inputAccessoryView = testView
//
//        //テキストビューのデリゲート先にこのインスタンスを設定する。
//        textView.delegate = self
//        
//        textView.text = "名前をつけてください"
//        textView.textColor = UIColor.lightGray
//        
//        self.view.addSubview(textView)
    }
    
    /// タッチした座標を取得
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("タッチされました")
//        let touch = touches.first
//        let point = touch!.location(in: self.scrollView)
//        let textView = UITextView(frame: CGRect.init(x: point.x, y: point.y, width: 150, height: 20))
//        
//        //ビューを作成する。
//        let testView = UIView()
//        testView.frame.size.height = 50
//        testView.backgroundColor = UIColor.gray
//        
//        //「閉じるボタン」を作成する。
//        let closeButton = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 70, y: 0, width: 70, height: 50))
//        closeButton.setTitle("閉じる", for:UIControlState.normal)
//        closeButton.addTarget(self,action: #selector(onClickCloseButton), for: .touchUpInside)
//        
//        //ビューに「閉じるボタン」を追加する。
//        testView.addSubview(closeButton)
//        
//        //キーボードのアクセサリにビューを設定する。
//        textView.inputAccessoryView = testView
//        
//        //テキストビューのデリゲート先にこのインスタンスを設定する。
//        textView.delegate = self
//        
//        textView.text = "名前をつけてください"
//        textView.textColor = UIColor.lightGray
//        
//        self.view.addSubview(textView)
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

extension NamingViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//    }
    
}
