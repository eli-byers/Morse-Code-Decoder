//
//  SettingsVC.swift
//  Morse Decoder
//
//  Created by Eli Byers on 5/26/18.
//  Copyright © 2018 Eli Byers. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    //FIXME: Night Mode
    
    @IBOutlet weak var uiColorBlue: UIButton!
    @IBOutlet weak var uiColorOrange: UIButton!
    @IBOutlet weak var uiColorGreen: UIButton!
    @IBOutlet weak var uiColorPurple: UIButton!
    @IBOutlet weak var nightSwitch: UISwitch!
    
    @IBOutlet var tableSections: [UITableViewCell]!
    @IBOutlet var tableCells: [UITableViewCell]!
    
    
    var buttons:[UIButton]!
    
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        buttons = [uiColorPurple, uiColorGreen, uiColorOrange, uiColorBlue]
        
        let selected = defaults.value(forKey: "UIColor") as! Int
        activateColorButton(selected)
        
        let nightModeOn = defaults.value(forKey: "NightMode") as! Bool
        nightSwitch.isOn = nightModeOn
        nightMode(on: nightModeOn)
    }
    
    func nightMode(on: Bool){
        let mainColor: UIColor
        let secondColor: UIColor
        let textColor: UIColor
        
        if on {
            mainColor = .darkGray
            secondColor = UIColor(white: 0.2, alpha: 1)
            textColor = .white
        } else {
            mainColor = UIColor(white: 0.8, alpha: 1)
            secondColor = .white
            textColor = .black
        }
        
        view.backgroundColor = mainColor
        tableSections.forEach { cell in
            cell.backgroundColor = mainColor
            let label = cell.subviews[0].subviews[0] as! UILabel
            label.textColor = textColor
        }
        tableCells.forEach { cell in
            cell.backgroundColor = secondColor
            let label = cell.subviews[0].subviews[0] as! UILabel
            label.textColor = textColor
        }
    }
    
    func activateColorButton(_ tag: Int){
        buttons.forEach { (button) in
            button.shadowOpacity = 0
        }
        buttons[tag].shadowRadius = 2
        buttons[tag].shadowOpacity = 1
        buttons[tag].shadowOffset = CGSize(width: 0, height: 1)
        buttons[tag].shadowColor = .black
    }
    
    @IBAction func colorPicked(_ sender: UIButton) {
        activateColorButton(sender.tag)
        appDelegate.setUIColor(sender.tag)
        navigationController?.navigationBar.barTintColor = UI.colorFor(tag: sender.tag)
    }
    
    
    @IBAction func nightModeChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "NightMode")
        nightMode(on: sender.isOn)
    }
    
    
    
    
}
