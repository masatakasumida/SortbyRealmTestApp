//
//  SecondViewController.swift
//  SortbyRealmTestApp
//
//  Created by 住田雅隆 on 2022/04/07.
//

import UIKit
import RealmSwift

class SecondViewController: UIViewController {
    let realm = try! Realm()
    var list: List<Item>!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func saveButton(_ sender: Any) {
        saveData()
      navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.becomeFirstResponder()
        list = realm.objects(ItemList.self).first?.list
    }
    func saveData() {
        let item = Item()
        item.title = textField.text!
        try! realm.write() {
            if list == nil {
                let itemList = ItemList()
                itemList.list.append(item)
                realm.add(itemList)
                list = realm.objects(ItemList.self).first?.list
            } else {
                list.append(item)
            }
        }        
    }
}
extension SecondViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
