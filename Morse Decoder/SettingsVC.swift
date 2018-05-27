//
//  SettingsVC.swift
//  Morse Decoder
//
//  Created by Eli Byers on 5/26/18.
//  Copyright © 2018 Eli Byers. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var uiColorBlue: UIButton!
    @IBOutlet weak var uiColorOrange: UIButton!
    @IBOutlet weak var uiColorGreen: UIButton!
    @IBOutlet weak var uiColorPurple: UIButton!
    
    var buttons:[UIButton]!
    
    let defaults = UserDefaults.standard
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        buttons = [uiColorPurple, uiColorGreen, uiColorOrange, uiColorBlue]
        
        let selected = defaults.value(forKey: "UIColor") as! Int
        activateColorButton(selected)
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
    
    }
    
    
    
    
}
