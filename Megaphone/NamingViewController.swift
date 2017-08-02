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
    var editLabelView: NamingLabelView?
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るボタンの文字を空にすることで矢印だけにする
        navigationController!.navigationBar.topItem!.title = " "
        
        imageView?.backgroundColor = UIColor.darkGray
        
        /* NavigationBarのボタン関連 */
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
        
        navigationItem.setRightBarButtonItems([rightCaptureButtonItem, rightSpaceButtonItem,rightTweetButtonItem], animated: true)

        /* スクロールビュー関連 */
        imageScrollView.delegate = self
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 3.0
        imageScrollView.contentMode = .scaleAspectFit
        
        imageView?.isUserInteractionEnabled = true
        
        // スクロールビューにタップジェスチャを登録
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped))
        imageScrollView.addGestureRecognizer(tapGesture)
        
        // ラベルの配置
        loadLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let view = imageView else {
            return
        }
        imageScrollView.addSubview(view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // TODO: 永続化処理をここでしたい
        if let viewControllers = self.navigationController?.viewControllers {
            var existsSelfInViewControllers = true
            for viewController in viewControllers {
                // viewWillDisappearが呼ばれる時に、
                // 戻る処理を行っていれば、NavigationControllerのviewControllersの中にselfは存在していない
                if viewController == self {
                    existsSelfInViewControllers = false
                    // selfが存在した時点で処理を終える
                    break
                }
            }
            
            if existsSelfInViewControllers {
                // imageViewのsubviewであるNamingViewを全て取得したい
                guard let subviews = imageView?.subviews else {
                    return
                }
                
                let labelEntity = LabelOfStageEntity()
                for subview in subviews {
                    let entity = LabelEntity()
                    
                    entity.pointX = subview.frame.origin.x
                    entity.pointY = subview.frame.origin.y
                    let label = subview as! NamingLabelView
                    entity.text = label.namingLabel.text
                    
                    labelEntity.labelList.append(entity)
                }
                // 画面タイトルをキーに設定
                labelEntity.key = navigationItem.title
                
                // タイトルがオプショナルなので安全な取り出し
                if let title = navigationItem.title {
                    // もし同じ名前のEntityが存在したら削除
                    if LabelStoreManager.pic(key: title) != nil {
                        LabelStoreManager.delete(key: title)
                    }
                }
                
                // Entityを追加
                LabelStoreManager.add(object: labelEntity)
            }
        }
        
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
            present(twitterPostView, animated: true, completion: nil)
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
        present(alert, animated: true, completion: nil)
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
            pointX = point.x
            pointY = point.y
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
    
    // Realmに永続化されているラベル情報を読み込み配置する
    private func loadLabels() {
        if let title = navigationItem.title {
            
            if let entity = LabelStoreManager.pic(key: title) {
                
                // このfor文で永続化永続化している複数のラベル座標からラベルを配置する
                for labelEntity in entity.labelList {
                    
                    if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                        
                        // サイズ計算用のダミーのラベル
                        label.namingLabel.text = labelEntity.text
                        label.namingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        label.namingLabel.sizeToFit()
                        let labelWidth = label.namingLabel.bounds.width
                        let viewHeight = label.namingLabel.bounds.height + label.closeButton.bounds.height
                        // ラベルの初期位置を設定
                        label.frame = CGRect(x: labelEntity.pointX, y: labelEntity.pointY, width: labelWidth, height: viewHeight)
                        // ラベルの初期位置を保持
                        label.beforFrame = CGPoint(x: labelEntity.pointX , y: labelEntity.pointY)
                        
                        label.delegate = self
                        imageView?.addSubview(label)
                    }
                }
            }
        }
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
    
    func namingLabelTapped(view: NamingLabelView) {
        // 編集用のラベルを保持
        self.editLabelView = view
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: TextViewController.nibName) as? TextViewController  {
            let navigation = TextViewNavigationController()
            navigation.addChildViewController(viewController)
            
            viewController.delegate = self
            present(navigation, animated: true, completion: nil)
        }
    }
    
}

extension NamingViewController: TextViewControllerDelegate {
    
    func getTextView(text: String?, completion: () -> Void) {
        
        func addLabelView(x: CGFloat, y: CGFloat) {
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                
                // サイズ計算用のダミーのラベル
                label.namingLabel.text = text
                label.namingLabel.sizeToFit()
                let labelWidth = label.namingLabel.bounds.width
                let viewHeight = label.namingLabel.bounds.height + label.closeButton.bounds.height
                // ラベルの初期位置を設定
                label.frame = CGRect(x: x, y: y, width: labelWidth, height: viewHeight)
                // ラベルの初期位置を保持
                label.beforFrame = CGPoint(x: x, y: y)
                
                label.delegate = self
                imageView?.addSubview(label)
            }

        }
        
        if editLabelView != nil {
            // ラベルの編集が行われている場合
            
            // 編集中のラベルの座標
            let x = editLabelView?.beforFrame.x
            let y = editLabelView?.beforFrame.y
            
            // 新しいラベルビューを追加
            addLabelView(x: x!, y: y!)
            // 編集中のラベルを削除
            editLabelView?.removeFromSuperview()
            // 何度もこのif文に入らないように破棄
            editLabelView = nil
        } else {
            // NamingLabelViewを生成する
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                
                // サイズ計算用のダミーのラベル
                label.namingLabel.text = text
                label.namingLabel.sizeToFit()
                let labelWidth = label.namingLabel.bounds.width
                let viewHeight = label.namingLabel.bounds.height + label.closeButton.bounds.height
                // ラベルの初期位置を設定
                label.frame = CGRect(x: pointX! - (labelWidth / 2), y: pointY! - (viewHeight * 2), width: labelWidth, height: viewHeight)
                // ラベルの初期位置を保持
                label.beforFrame = CGPoint(x: pointX! - (labelWidth / 2), y: pointY! - (viewHeight * 2))
                
                label.delegate = self
                imageView?.addSubview(label)
            }
        }
        // テキストビューコントローラーを消す
        completion()
    }
    
}
