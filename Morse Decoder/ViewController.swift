//
//  ViewController.swift
//  Morse Decoder
//
//  Created by Eli Byers on 11/3/17.
//  Copyright © 2017 Eli Byers. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var outputLabel: UITextView!
    @IBOutlet weak var morseLabel: UITextView!
    @IBOutlet weak var leftBarButton: UIBarButtonItem!

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
    var engOutput = NSMutableAttributedString()
    var mourseOutput = NSMutableAttributedString()
    var engAttrs:[NSAttributedStringKey: Any] = [NSAttributedStringKey.font:UIFont(name: "AppleSDGothicNeo-Medium", size: 45)!]
    let morseAttrs = [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 45)!]

    override func viewDidLoad() {
        super.viewDidLoad()
        outputLabel.text = ""
        morseLabel.text = ""
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        engAttrs.updateValue(style, forKey: NSAttributedStringKey.paragraphStyle)
        
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
    
    func engineStart(){
        do {
            try engine.start()
        } catch let error as NSError {
            print(error)
        }
    }
    //=================================================
    //                 MORSE PLAYER
    //=================================================
    
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

    //=================================================
    //                 MORSE DECODING
    //=================================================
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        morseText += ["·","-"," ","/"][sender.tag]
        updateOutput()
    }
    
    func decode(){
        let wordArray = morseText.components(separatedBy: "/")
        for word in wordArray {
            let characterArray = word.components(separatedBy: " ")
            for morseChar in characterArray {
                 if let c = morseToAlphaNum[morseChar] {
                    engOutput.appendString(c, with: engAttrs)
                }
                // make unknown characters a red '?'
                else if morseChar != "" {
                    // 25A1 - WHITE SQUARE
                    // 003D - HORIZONTAL LINES
                    // 3013 - LOLG HORIZONTAL LINES
                    engOutput.appendString("\u{003D}", with: engAttrs)
                    let idx = engOutput.length - 1
                    engOutput.addAttribute(
                        NSAttributedStringKey.foregroundColor, value: UIColor.red,
                        range: NSRange(location:idx, length:1)
                    )
                }
            }
            engOutput.appendString(" ", with: engAttrs)
        }
        engOutput.removeLast()
    }
    
    func updateOutput() {
        engOutput = NSMutableAttributedString()
        
        // remove extra white space
        do {
            let regex = try NSRegularExpression(pattern: "[\\/| ]{2,}", options:.caseInsensitive)
            morseText = regex.stringByReplacingMatches(
                in: morseText,
                options:NSRegularExpression.MatchingOptions(rawValue: 0),
                range: NSMakeRange(0, morseText.count),
                withTemplate: "/"
            )
        } catch { print("regex error") }
        
        // translate to eng
        decode()
        
        // make "/" gray
        mourseOutput = NSMutableAttributedString(string: morseText, attributes: morseAttrs)
        for idx in 0..<morseText.count {
            if morseText[idx] == "/" {
                mourseOutput.addAttribute(
                    NSAttributedStringKey.foregroundColor,
                    value: UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0),
                    range: NSRange(location:idx,length:1)
                )
            }
        }

        outputLabel.attributedText = engOutput
        morseLabel.attributedText = mourseOutput
        
        // scroll to bottom of text areas
        var range = NSMakeRange(outputLabel.text.count - 1, 0)
        outputLabel.scrollRangeToVisible(range)
        range = NSMakeRange(morseLabel.text.count - 1, 0)
        morseLabel.scrollRangeToVisible(range)
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        morseText = ""
        updateOutput()
    }
    
    @IBAction func delButtonPressed(_ sender: UIButton) {
        if morseText.count > 0 {
            morseText.removeLast()
            updateOutput()
        }
    }
    
    //=================================================
    //                  SHARE BUTTON
    //=================================================

    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Share", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(
            UIAlertAction(title: "English", style: .default){
                alert in
                self.share(self.engOutput.string)
            }
        )
        alert.addAction(
            UIAlertAction(title: "Morse", style: .default){
                alert in
                self.share(self.morseText)
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
        activityVC.excludedActivityTypes = [
        ]
        
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
        // Dispose of any resources that can be recreated.
    }


}


