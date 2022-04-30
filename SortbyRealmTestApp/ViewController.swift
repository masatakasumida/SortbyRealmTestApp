//
//  ViewController.swift
//  SortbyRealmTestApp
//
//  Created by 住田雅隆 on 2022/04/07.
//

import UIKit
import RealmSwift
import os

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var datePicker: UIDatePicker = UIDatePicker()
    var textField = UITextField()
    var count:Int = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var list: List<Item>!
    
    
    @IBAction func timerSetButton(_ sender: Any) {
        os_log("stoplocalNotfication")
        
        // 通知の削除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["Time Interval"])
        
        let ac = UIAlertController(title: "時間の設定", message: "設定した時間にチェックが付いていないと通知します!!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "セット", style: .destructive) { (action) in
            self.count = Int(self.datePicker.countDownDuration)
            print("カウントは\(self.count)です")
            
            os_log("setlocalNotfication")
            
            // notification's payload の設定
            let content = UNMutableNotificationContent()
            content.title = "タスクが全て達成されていません!!"
            content.subtitle = ""
            content.body = "タスクを達成しましょう!!"
            content.sound = UNNotificationSound.default
            
            // １回だけ
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.count), repeats: false)
            let request = UNNotificationRequest(identifier: "Time Interval",
                                                content: content,
                                                trigger: trigger)
            // 通知の登録
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            print("キャンセルされました")
        }
        ac.addTextField { (textField) in
            // 決定バーの生成
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 35))
            let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
            toolbar.setItems([spaceItem, doneItem], animated: true)
            textField.inputView = self.datePicker
            textField.inputAccessoryView = toolbar
            self.textField = textField
            
            // ピッカー設定
            self.datePicker.datePickerMode = UIDatePicker.Mode.countDownTimer
        }
        ac.addAction(cancel)
        ac.addAction(ok)
        self.present(ac, animated: true, completion: nil)
    }
    
    @IBAction func toSecondViewButton(_ sender: Any) {
        let secondVC = storyboard?.instantiateViewController(identifier: "secondView") as! SecondViewController
        navigationController?.pushViewController(secondVC,animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        tableView.allowsMultipleSelectionDuringEditing = true
        super.viewDidLoad()
        let center = UNUserNotificationCenter.current()
        // 通知の使用許可をリクエスト
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            
            print(Realm.Configuration.defaultConfiguration.fileURL!)
            
        }
    }
    @objc func done() {
        textField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "H時間m分後"
        let time = formatter.string(from: datePicker.date)
        
        textField.text = time
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = realm.objects(ItemList.self).first?.list
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm.objects(Item.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row].title
        
        if list[indexPath.row].checkMark == true {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            let attributeString =  NSMutableAttributedString(string: list[indexPath.row].title)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
        }else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            try! realm.write {
                let item = list[indexPath.row]
                realm.delete(item)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! realm.write {
            let listItem = list[sourceIndexPath.row]
            list.remove(at: sourceIndexPath.row)
            list.insert(listItem, at: destinationIndexPath.row)
        }
    }
    
    //    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let attributeString =  NSMutableAttributedString(string: list[indexPath.row].title)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
            
        }
        try! realm.write {
            list[indexPath.row].checkMark = true
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let attributeString =  NSMutableAttributedString(string: list[indexPath.row].title)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
            try! realm.write {
                list[indexPath.row].checkMark = false
            }
        }
    }
}
