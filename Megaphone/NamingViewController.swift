//
//  NamingViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import Social

class NamingViewController: UIViewController {
    
    static let identifier = "NamingViewController"
    var imageView: UIImageView?
    var actionTextView: UITextView?
    var scrollView: UIScrollView?
    // ラベルの表示テキスト位置保存用
    var pointX: CGFloat?
    var pointY: CGFloat?
    // 編集しているラベル保持用のプロパティ
    var editLabel: UILabel?
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.backgroundColor = UIColor.darkGray
        
        // キャプチャボタンをNavigationBarの右に追加
        let rightCaptureButton = UIButton()
        rightCaptureButton.setImage(UIImage(named: "Capture.png"), for: .normal)
        rightCaptureButton.sizeToFit()
        rightCaptureButton.addTarget(self, action: #selector(capture), for: UIControlEvents.touchUpInside)
        
        let rightSpaceButton = UIButton()
        rightSpaceButton.contentRect(forBounds: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        let rightTweetButton = UIButton()
        rightTweetButton.setImage(UIImage(named: "TwitterIcon.png"), for: .normal)
        rightTweetButton.sizeToFit()
        rightTweetButton.addTarget(self, action: #selector(tweetImage), for: UIControlEvents.touchUpInside)
        
        let rightCaptureButtonItem = UIBarButtonItem(customView: rightCaptureButton)
        let rightSpaceButtonItem = UIBarButtonItem(customView: rightSpaceButton)
        let rightTweetButtonItem = UIBarButtonItem(customView: rightTweetButton)
        
          self.navigationItem.setRightBarButtonItems([rightCaptureButtonItem, rightSpaceButtonItem,rightTweetButtonItem], animated: true)

        /* スクロールビュー関連 */
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
        guard let view = imageView else {
            return
        }
        imageScrollView.addSubview(view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tweetImage() {
        if let image = imageView?.castImage() {
            // ツイッター投稿画面を表示
            let twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
            twitterPostView.add(image)
            twitterPostView.setInitialText("")
            self.present(twitterPostView, animated: true, completion: nil)
        }
    }
    
    // キャプチャボタンを押した時に呼ばれる
    func capture() {
        guard let image = imageView?.castImage() else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageResult), nil)
    }

    
    // 保存を試みた結果をダイアログで表示
    func saveImageResult(_ image: UIImage, didFinishSavingWithError error: Error!, contextInfo: UnsafeMutableRawPointer) {
        
        var title = "保存完了"
        var message = "カメラロールに保存しました"
        
        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // UIAlertController を表示
        self.present(alert, animated: true, completion: nil)
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
    
    func namingLabelTapped(label: UILabel) {
        // 編集用のラベルを保持
        self.editLabel = label
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: TextViewController.nibName) as? TextViewController  {
            let navigation = TextViewNavigationController()
            navigation.addChildViewController(viewController)
            viewController.delegate = self
            present(navigation, animated: true, completion: nil)
        }
    }
    
    func namingViewDraged(locate: CGPoint, view: UIView) {
//        view.frame.origin.x = view.frame.origin.x + locate.x
//        view.frame.origin.y = view.frame.origin.y + locate.y
        view.frame.origin = locate
    }
    
}

extension NamingViewController: TextViewControllerDelegate {
    
    func getTextView(text: String?, completion: () -> Void) {
        
        if editLabel != nil {
            // ラベルの編集が行われている場合
            editLabel?.text = text
            editLabel = nil
        } else {
            // NamingLabelViewを生成する
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                
                // サイズ計算用のダミーのラベル
                
                label.namingLabel.text = text
                label.namingLabel.sizeToFit()
                let labelWidth = label.namingLabel.bounds.width
                let viewHeight = label.namingLabel.bounds.height + label.closeButton.bounds.height

                label.frame = CGRect(x: pointX! - (labelWidth / 2), y: pointY! - (viewHeight * 2), width: labelWidth, height: viewHeight)
                
                label.beforFrame = CGPoint.init(x: pointX!, y: pointY!)
                
                label.delegate = self
                self.imageView?.addSubview(label)
            }
        }
        completion()
    }
    
}
