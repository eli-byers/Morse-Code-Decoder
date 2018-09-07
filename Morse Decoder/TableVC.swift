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
    
    let defaults = UserDefaults.standard
    var tableData: [(eng: String, morse: String)] = []
    var nightMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableData = Morse.Letters
        tableView.reloadData()
        
        // remove line between nav bars
        navigationController?.navigationBar.shadowImage = UIImage()
    
        nightMode = defaults.value(forKey: "NightMode") as! Bool
        if nightMode {
            tableView.backgroundColor = UI.Gray
        }
    }
    
    @IBAction func DoneButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func controllerChanged(_ sender: UISegmentedControl) {
        let data = [Morse.Letters, Morse.Numbers, Morse.Punctuation]
        let idx = sender.selectedSegmentIndex
        tableData = data[idx]
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
}

extension TableVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = tableData[indexPath.row]
        cell.textLabel?.text = cellData.eng
        cell.detailTextLabel?.text = cellData.morse
        
        if nightMode {
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
        }
        return cell
    }
    
}
