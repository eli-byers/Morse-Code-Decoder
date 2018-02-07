//
//  TableVC.swift
//  Morse Decoder
//
//  Created by Eli Byers on 11/4/17.
//  Copyright © 2017 Eli Byers. All rights reserved.
//

import UIKit

class TableVC: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    
    let tableData:[(
            title: String,
            data:[
                (eng:String, morse:String)
            ]
        )] = [
        ("Alphabet", [
            ("A", "·-"),
            ("B", "-···"),
            ("C", "-·-·"),
            ("D", "-··"),
            ("E", "·"),
            ("F", "··-·"),
            ("G", "--·"),
            ("H", "····"),
            ("I", "··"),
            ("J", "·---"),
            ("K", "-·-"),
            ("L", "·-··"),
            ("M", "--"),
            ("N", "-·"),
            ("O", "---"),
            ("P", "·--·"),
            ("Q", "--·-"),
            ("R", "·-·"),
            ("S", "···"),
            ("T", "-"),
            ("U", "··-"),
            ("V", "···-"),
            ("W", "·--"),
            ("X", "-··-"),
            ("Y", "-·--"),
            ("Z", "--··"),
        ]),
        ("Numbers", [
            ("0", "-----"),
            ("1", "·----"),
            ("2", "··---"),
            ("3", "···--"),
            ("4", "····-"),
            ("5", "·····"),
            ("6", "-····"),
            ("7", "--···"),
            ("8", "---··"),
            ("9", "----·"),
        ]),
        ("Punctuation", [
            (".", "·-·-·-"),
            (",", "--··--"),
            ("?", "··--··"),
            ("@", "·--·-·"),
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    @IBAction func DoneButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

extension TableVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableData[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = tableData[indexPath.section].data[indexPath.row]
        cell.textLabel?.text = cellData.eng
        cell.detailTextLabel?.text = cellData.morse
        return cell
    }
    
}
