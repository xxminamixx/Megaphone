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

class HomeViewController: UIViewController {

    @IBOutlet weak var stageTableView: UITableView!
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var cameraRollIgnitionView: UIView!
    
    var fdTakeController = FDTakeController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // TODO: フェッチするたびにデータが蓄積するので、同じデータは保存しないようにする
        guard let stages = JsonManager.shared.stages?.stage else {
            return
        }
        
        // StageEntityを画像データからのまま一旦保存
        for stage in stages {
            let entity = FetchStoreEntity()
            entity.stageEntity = stage
            RealmStoreManager.addFetchEntity(object: entity)
        }
        
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: NamingViewController.identifier) as! NamingViewController
        let stageEntity = JsonManager.shared.stages?.stage![indexPath.row] ?? StageEntity()
        
        // 永続化した中にフェッチしたステージ名があった場合
        if RealmStoreManager.isStoreStageName(stage: stageEntity.stage!) {
            // ローカルのステージ画像データを使う
        }
        
        viewController.navigationItem.title = stageEntity.stage

        if let imageName = stageEntity.url {
            
            /// 画像データがすでに永続化されているならばそれを使う
            if let image = RealmStoreManager.stageEntity(filter: stageEntity.stage!).first?.image {
                // TOOD: 下記に同じ処理があるので外だしして共通化したい
                let image = UIImage(data: image)
                // 画面いっぱい
                let fullScreen = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                // イメージビュー生成
                let imageView = UIImageView(frame: fullScreen)
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                imageView.isUserInteractionEnabled = true
                viewController.imageView = imageView
                
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            } else {
                StageFetcher.stageImage(url: imageName, completion: { data in
                    let image = UIImage(data: data)
                    // 画面いっぱい
                    let fullScreen = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                    // イメージビュー生成
                    let imageView = UIImageView(frame: fullScreen)
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = image
                    imageView.isUserInteractionEnabled = true
                    viewController.imageView = imageView
                    
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                })
            }
            
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
