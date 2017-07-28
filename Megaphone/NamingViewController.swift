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
    // ラベルの表示テキスト位置保存用
    var pointX: CGFloat?
    var pointY: CGFloat?
    
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
        
        /* TODO:
         タップした座標を保持
         文字入力用のモーダルを表示
         モーダルの完了ボタンを押したらその文字列を受け取る
         保持していた座標にUILabelを作成
 
        */
        
        for i in 0..<gesture.numberOfTouches {
            let point = gesture.location(ofTouch: i, in: self.view)
            self.pointX = point.x
            self.pointY = point.y
//            print(pointX)
//            print(pointY)
            
//            let textView = UITextView(frame: CGRect.init(x: point.x, y: point.y, width: 150, height: 20))
//            
//            //ビューを作成する。
//            let testView = UIView()
//            testView.frame.size.height = 50
//            testView.backgroundColor = UIColor.gray
//            
//            //「閉じるボタン」を作成する。
//            let closeButton = UIButton.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 70, y: 0, width: 70, height: 50))
//            closeButton.setTitle("閉じる", for:UIControlState.normal)
//            closeButton.addTarget(self,action: #selector(onClickCloseButton), for: .touchUpInside)
//            
//            //ビューに「閉じるボタン」を追加する。
//            testView.addSubview(closeButton)
//            
//            //キーボードのアクセサリにビューを設定する。
//            textView.inputAccessoryView = testView
//            
//            //テキストビューのデリゲート先にこのインスタンスを設定する。
//            textView.delegate = self
//            
//            textView.text = "名前をつけてください"
//            textView.textColor = UIColor.lightGray
//            
//            self.view.addSubview(textView)
        }
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: TextViewController.nibName) as? TextViewController  {
            let navigation = TextViewNavigationController()
            navigation.addChildViewController(viewController)
            viewController.delegate = self
            present(navigation, animated: true, completion: nil)
        }

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
    
}

extension NamingViewController: NamingLabelViewDelegate {
    
    func namingViewClose(view: UIView) {
        // 受け取ったViewをsubViewから削除する
        view.removeFromSuperview()
    }
    
    func nimingLabelTapped() {
        let view = Bundle.main.loadNibNamed("TextViewController", owner: self, options: nil)?.first as! TextViewController
        let navigation = UINavigationController.init(rootViewController: view)
        present(navigation, animated: true, completion: nil)
    }
    
}

extension NamingViewController: TextViewControllerDelegate {
    
    func getTextView(text: String?, completion: () -> Void) {
        // NamingLabelViewを生成する
        if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
            
            // サイズ計算用のダミーのラベル
            
            label.namingLabel.text = text
            label.namingLabel.sizeToFit()
            label.frame = CGRect(x: pointX!, y: pointY!, width: label.namingLabel.bounds.width, height: label.namingLabel.bounds.width + label.closeButton.frame.height)
            

            
            label.delegate = self
            self.view.addSubview(label)
            
            completion()
        }


    }
    
//    func getTextView(text: String?, completion: () -> Void) {
//        // NamingLabelViewを生成する
//        let label = NamingLabelView()
//        label.namingLabel.text = text
//        self.view.addSubview(label)
//    }
    
}
