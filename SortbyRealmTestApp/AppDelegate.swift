//
//  AppDelegate.swift
//  SortbyRealmTestApp
//
//  Created by 住田雅隆 on 2022/04/07.
//

import UIKit
import RealmSwift
import os

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let realm = try! Realm()
    var list: List<Item>!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted{
                    UNUserNotificationCenter.current().delegate = self
                }
            }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}
// 通知を受け取ったときの処理
extension AppDelegate: UNUserNotificationCenterDelegate {
    // フォアグラウンドの状態でプッシュ通知を受信した際に呼ばれるメソッド
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            let result = realm.objects(Item.self).filter("checkMark == false")
            
            print("リストの中身は\([result])です")
            if result.indices.contains(0) == true {
                if #available(iOS 14.0, *) {
                    
                    completionHandler([[.banner, .list, .sound]])
                    print("通知出したよ")
                    
                } else {
                    completionHandler([[.alert, .sound]])
                }
            }else {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Time Interval"])
                os_log("stoplocalNotfication")
                print("タスクは全て達成しています!!")
            }
        }
}


