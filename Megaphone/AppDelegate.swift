//
//  AppDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                // enumerate(_:_:)メソッドで保存されているすべての
                // Personオブジェクトを列挙します
                migration.enumerateObjects(ofType: LabelEntity.className()) { oldObject, newObject in
                    // スキーマバージョンが0のときだけ、'attribute'プロパティを追加します
                    if oldSchemaVersion < 1 {
                        newObject!["attribute"] = ""
                    }
                    
                }
                
                //
                if (oldSchemaVersion < 1) {
                    // 海女美術大学の名前ミスを修正
                    migration.renameProperty(onType: LabelEntity.className(), from: "海女美術館", to: "海女美術大学")
                }
        })

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

}

