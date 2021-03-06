//
//  HomeViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GestureRecognizerClosures
import FDTake
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class HomeViewController: UIViewController {

    @IBOutlet weak var stageTableView: UITableView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var cameraRollIgnitionView: UIView!
    
    var fdTakeController = FDTakeController()
    /// ローディング中を表すインジケータ
    var indicator: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = CGSize(width: 60, height: 60) // インジケータのサイズ
        self.indicator = NVActivityIndicatorView(frame: CGRect(origin: self.view.centerPoint(size: size), size: size), type: .lineScalePulseOut, color: ConstColor.iconYellow, padding: 10)
        self.view.addSubview(indicator!)
        // viewControllerを表示する前からフェッチは始まっているのでインジケータアニメーションを表示
        indicator?.startAnimating()
        
        // 広告表示用の親Viewの背景色を設定
        bannerView.backgroundColor = UIColor.darkGray
        
        // 広告の設定
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        // AdMobで発行された広告ユニットIDを設定
        banner.adUnitID = ConstText.homeBanner
        banner.delegate = self
        banner.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        
        // テスト用の広告を表示する時のみ使用（申請時に削除）
//        gadRequest.testDevices = [kGADSimulatorID]
        
        banner.load(gadRequest)
        bannerView.addSubview(banner)
        
        // テーブルビューの初期設定
        stageTableView.backgroundColor = UIColor.darkGray
        stageTableView.delegate = self
        stageTableView.dataSource = self
        let nib = UINib(nibName: StageTableViewCell.nibName, bundle: nil)
        stageTableView.register(nib, forCellReuseIdentifier: StageTableViewCell.nibName)
        
        /* カメラロール起動Viewの設定 */
        cameraRollIgnitionView.backgroundColor = ConstColor.cameraRollYellow
        cameraRollIgnitionView.onTap { _ in
            self.fdTakeController.allowsTake = false
            self.fdTakeController.allowsVideo = false
            self.fdTakeController.allowsEditing = false
            
            self.fdTakeController.chooseFromLibraryText = "アルバムを開く"
            self.fdTakeController.didGetPhoto = {
                (_ photo: UIImage, _ info: [AnyHashable : Any]) in
                
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: NamingViewController.identifier) as! NamingViewController
                let fullScreen = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                // イメージビュー生成
                let imageView = UIImageView(frame: fullScreen)
                imageView.contentMode = .scaleAspectFit
                imageView.image = photo
                imageView.isUserInteractionEnabled = true
                viewController.imageView = imageView

                self.navigationController?.pushViewController(viewController, animated: true)
            }
            self.fdTakeController.present()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // タイトルを設定
        navigationItem.title = ConstText.appName
        
        // ステージ一覧をフェッチしTableViewを更新
        StageFetcher.stageJson {
            // フェッチが完了したのでアニメーションストップ
            self.indicator?.stopAnimating()
            DispatchQueue.main.async {
                self.stageTableView.reloadData()
                self.fetchStore()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// フェッチしたstage情報を永続化
    private func fetchStore() {
        guard let stages = JsonManager.shared.stages?.stage else {
            return
        }
        
        /// StageEntity配列をひとつづつ永続化
        for stage in stages {
            if !RealmStoreManager.isStoreStageName(stage: stage.stage!) {
                let entity = FetchStoreEntity()
                entity.stageEntity = stage
                RealmStoreManager.addEntity(object: entity)
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: NamingViewController.identifier) as! NamingViewController
        // TODO: SharedInstansがデータを持ち続けているのはスコープが長くて危険なので短命にしたい
        // ステージエンティティをJsonManagerのSharedInstansから取得
        let stageEntity = JsonManager.shared.stages?.stage![indexPath.row] ?? StageEntity()
        // Navigation Titleを設定
        viewController.navigationItem.title = stageEntity.stage
        
        let fetchStoreEntity = RealmStoreManager.stageEntity(filter: stageEntity.stage!).first
        if let image = fetchStoreEntity?.image {
            /// 画像データがすでに永続化されているならばそれを使う
            guard let image = UIImage(data: image) else {
                return
            }
            self.imageSetNextViewController(viewController: viewController, image: image)
        } else {
            /// 永続化されている画像データがない場合はフェッチして使う
            guard let imageName = stageEntity.url else {
                return
            }
            
            // インジケータのアニメーションスタート
            indicator?.startAnimating()
            
            StageFetcher.stageImage(url: imageName, completion: { image in
                RealmStoreManager.save {
                    // UIImageをPNGデータ形式に変換して保存
                    fetchStoreEntity?.image = UIImagePNGRepresentation(image)
                }
                // インジケータのアニメーションストップ
                self.indicator?.stopAnimating()
                self.imageSetNextViewController(viewController: viewController, image: image)
            })
        }
    }
    
    /// NaigationBarのタイトルをセット + 次のViewControllerに画像をセット + 画面遷移
    func imageSetNextViewController(viewController: NamingViewController, image: UIImage) {
        // 画面いっぱい
        let fullScreen = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // イメージビュー生成
        let imageView = UIImageView(frame: fullScreen)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.isUserInteractionEnabled = true
        viewController.imageView = imageView
        
        // メインスレッドで画面遷移
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return JsonManager.shared.stageCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stageTableView.dequeueReusableCell(withIdentifier: StageTableViewCell.nibName, for: indexPath) as! StageTableViewCell
        
        guard let stageList = JsonManager.shared.stages?.stage else {
            // jsonのパースに失敗していた場合ステージ名をセットせずリターン
            return cell
        }
        
        cell.stageName.text = stageList[indexPath.row].stage
        
        // 選択時のスタイルを無しにする
        cell.selectionStyle = .none
        
        return cell
    }
    
}

// MARK: GADBannerViewDelegate
extension HomeViewController: GADBannerViewDelegate {
    
}
