//
//  MainVC.swift
//  Morse Decoder
//
//  Created by Eli Byers on 11/3/17.
//  Copyright © 2017 Eli Byers. All rights reserved.
//

import UIKit
import AVFoundation


class MainVC: UIViewController {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var backgroundViews: [UIView]!
    
    @IBOutlet weak var engTextView: UITextView!
    @IBOutlet weak var morseTextView: UITextView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!

    let defaults = UserDefaults.standard
    
    // morse player
    let timer = DispatchSource.makeTimerSource()
    let tone = AVTonePlayerUnit()
    let engine = AVAudioEngine()
    var morseToneString = ""
    var toneIdx = -1
    var playing = false
    var toneDuration = 0
    var toneTime = 0
    
    // output
    var morseText: String = ""
    var cursorPos: Int = 0;

    var engAttrs:[NSAttributedStringKey: Any] = [NSAttributedStringKey.font:UIFont(name: "AppleSDGothicNeo-Medium", size: 45)!]
    var morseAttrs:[NSAttributedStringKey: Any] = [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 45)!]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        engTextView.text = ""
        engTextView.delegate = self
        
        morseTextView.text = ""
        morseTextView.delegate = self
        // remove kayboard from morseLabel
        morseTextView.inputView = UIView()
        morseTextView.becomeFirstResponder()
        
        
        // init tone player
        tone.amplitude = 1

        // init audio engine
        engine.mainMixerNode.volume = 1.0
        engine.attach(tone)
        engine.prepare()
        
        let mixer = engine.mainMixerNode
        let format = AVAudioFormat(standardFormatWithSampleRate: tone.sampleRate, channels: 1)
        engine.connect(tone, to: mixer, format: format)
        
        // init player timer
        let interval = DispatchTimeInterval.milliseconds(20)
        timer.schedule(deadline: DispatchTime.now(), repeating: interval, leeway: interval)
        timer.setEventHandler(handler: self.playMorseCode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUIColor()
    }

    func setUIColor(){
        // for night mode
        let nightMode = defaults.value(forKey: "NightMode") as! Bool
        if nightMode {
            morseAttrs[NSAttributedStringKey.foregroundColor] = UIColor.white
            engAttrs[NSAttributedStringKey.foregroundColor] = UIColor.white
            backgroundViews.forEach({view in view.backgroundColor = UI.Gray})
            engTextView.keyboardAppearance = .dark
        } else {
            morseAttrs[NSAttributedStringKey.foregroundColor] = UIColor.black
            engAttrs[NSAttributedStringKey.foregroundColor] = UIColor.black
            backgroundViews.forEach({view in view.backgroundColor = UIColor.white})
            engTextView.keyboardAppearance = .light
        }
        
        let colorTag = defaults.value(forKey: "UIColor") as! Int
        let selectedColor = UI.colorFor(tag: colorTag)
        buttons.forEach({ button in button.backgroundColor = selectedColor })
        borderView.backgroundColor = selectedColor
    }
    
    //=================================================
    //                 MORSE DECODING
    //=================================================
    
    func makeMorseActive() -> Bool {
        if !morseTextView.isFirstResponder {
            morseTextView.becomeFirstResponder()
            return true
        }
        return false
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        if makeMorseActive() { return }

        morseText = ""
        updateOutputMTE(string: morseText)
    }
    
    @IBAction func delButtonPressed(_ sender: UIButton) {
        if makeMorseActive() { return }

        //FIXME: Delete in middle of textView
        if morseText.count > 0 {
            
            if let range = morseTextView.selectedTextRange {
                let cursIdx = morseTextView.offset(
                    from: morseTextView.beginningOfDocument,
                    to: range.start
                )
                
                if range.isEmpty {
                    let idx = morseText.index(morseText.startIndex, offsetBy: cursIdx-1)
                    morseText.remove(at: idx)
                } else {
                    //morseText.removeSubrange(<#T##bounds: Range<String.Index>##Range<String.Index>#>)
                    morseTextView.replace(range, withText: "")
                    morseText = morseTextView.text
                }
                
                updateOutputMTE(string: morseText)
                
                if range.isEmpty {
                    morseTextView.selectedRange = NSMakeRange(cursIdx-1, 0)
                }
            }
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if makeMorseActive() { return }
        
        if let idx = morseTextView.cursorPosition() {
            cursorPos = idx.start
            let newChar = ["·","-"," ","/"][sender.tag]
            let preChar = morseText[cursorPos-1]

            if preChar == "/" && [" ", "/"].contains(newChar) { return }

            //FIXME: space before word doesnt work
            
            // get sidex
            let left = morseText.substring(toIndex: idx.start)
            let right = morseText.substring(fromIndex: idx.end)
            morseText = left + newChar + right
            updateOutputMTE(string: morseText)
            
            // adjust when " " gets replaced by "/"
            if preChar == " " && [" ", "/"].contains(newChar) { cursorPos -= 1 }
            // update cursor
            morseTextView.setCursorPotition(to: cursorPos + 1)
        }
    }
    
    func morseDecode(string: String) -> NSMutableAttributedString {
        let engOutputStr = NSMutableAttributedString()
        let wordArray = string.components(separatedBy: "/")
        for word in wordArray {
            let characterArray = word.components(separatedBy: " ")
            for i in 0..<characterArray.count {
                let morseChar = characterArray[i]
                if let c = morseToAlphaNum[morseChar] {
                    engOutputStr.appendString(c, with: engAttrs)
                }
                // make unknown characters a red '?'
                else if morseChar != "" {
                    // 25A1 - WHITE SQUARE
                    // 003D - HORIZONTAL LINES
                    // 3013 - LOLG HORIZONTAL LINES
                    engOutputStr.appendString("?", with: engAttrs)
                    engOutputStr.addAttributes([.foregroundColor: UIColor.red], range: NSRange(location: i, length:1))
                }
            }
            engOutputStr.appendString(" ")
        }
        engOutputStr.removeLast()
        
        return engOutputStr
    }
    
    func updateMorseOutput(to string: String){
        // replace doublespaces with /
        var text = ""
        do {
            let regex = try NSRegularExpression(pattern: "[\\/| ]{2,}", options: .caseInsensitive)
                text = regex.stringByReplacingMatches(
                in: string,
                options: NSRegularExpression.MatchingOptions(rawValue: 0),
                range: NSMakeRange(0, string.count),
                withTemplate: "/"
            )
        } catch { print("regex error") }
        self.morseText = text
        
        // make "/" in morseText gray
        let morseAttrString = NSMutableAttributedString(string: morseText, attributes: morseAttrs)
        for idx in 0..<morseText.count {
            if morseText[idx] == "/" {
                morseAttrString.addAttribute(
                    .foregroundColor,
                    value: UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0),
                    range: NSRange(location:idx,length:1)
                )
            }
        }

        morseTextView.attributedText = morseAttrString.center()
        let range = NSMakeRange(morseTextView.text.count - 1, 0)
        morseTextView.scrollRangeToVisible(range)
    }
    
    func updateOutputMTE(string: String) {
        updateMorseOutput(to: string)
        
        // translate morse to english
        engTextView.attributedText = morseDecode(string: string).center()
        
        // scroll to bottom of text areas
        let range = NSMakeRange(engTextView.text.count - 1, 0)
        engTextView.scrollRangeToVisible(range)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
    }

}


//=================================================
//                 MORSE PLAYER
//=================================================
//MARK: Morse player
extension MainVC {
    
    func engineStart(){
        do {
            try engine.start()
        } catch let error as NSError {
            print(error)
        }
    }

    @IBAction func playButtonPressed(_ sender: UIBarButtonItem) {
        if !playing {
            playing = true
            leftBarButton.image = UIImage(named: "Stop")
            morseToneString = morseText.map {String($0)}.joined(separator: "~")
            
            engineStart()
            timer.resume()
        } else {
            endMorseTones()
        }
    }
    
    @objc func playMorseCode(){
        if !engine.isRunning { return }
        
        // if playing a tone, leave
        if toneTime < toneDuration {
            toneTime += 1
            return
        } else {
            toneTime = 0
        }
        tone.pause()
        tone.reset()
        
        // start next tone if exists
        toneIdx += 1
        if toneIdx < morseToneString.count {
            let t = morseToneString[toneIdx]
            toneDuration = (toneCode[t]?.dur)!
            let vol = (toneCode[t]?.vol)!
            if vol > 0 {
                tone.preparePlaying()
                tone.play()
            }
        } else {
            endMorseTones()
        }
    }
    
    func endMorseTones(){
        timer.suspend()
        tone.pause()
        engine.pause()
        toneDuration = 0
        toneTime = 0
        toneIdx = -1
        playing = false
        DispatchQueue.main.async {
            self.leftBarButton.image = UIImage(named: "Play")
        }
    }
}


//=================================================
//                  SHARE BUTTON
//=================================================
//MARK: Share
extension MainVC {
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Share", message: "", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "English", style: .default){
                alert in
                self.share(self.engTextView.text)
            }
        )
        alert.addAction(
            UIAlertAction(title: "Morse", style: .default){
                alert in
                self.share(self.morseTextView.text)
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        )
        self.present(alert, animated: true, completion: nil)
    }
    
    func share(_ textToShare: String){
        let objectsToShare = [textToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        //Excluded Activities
        activityVC.excludedActivityTypes = []
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}


extension MainVC: UITextViewDelegate {
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = textView.text.uppercased()
        morseText = morseEncode(text: textView.text)
        updateMorseOutput(to: morseText)
    }
    
    func morseEncode(text: String) -> String {
        var morseText = ""
        let wordArray = text.components(separatedBy: " ")
        for word in wordArray {
            for char in word {
                if let morse = alphaNumToMorse[String(char)] {
                    morseText += morse + " "
                }
            }
            morseText += "/"
        }
        morseText.removeLast()
        return morseText
    }
}


