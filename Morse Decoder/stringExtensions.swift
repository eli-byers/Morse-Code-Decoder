//
//  stringExtensions.swift
//  Morse Decoder
//
//  Created by Eli Byers on 11/3/17.
//  Copyright © 2017 Eli Byers. All rights reserved.
//

import UIKit


func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}

extension NSMutableAttributedString {
    
    func appendString(_ string: String, with attributes:[NSAttributedStringKey : Any]? = nil){
        let strToAdd = NSAttributedString(string: string, attributes: attributes)
        self.append(strToAdd)
    }
    
    func removeLast(){
        self.deleteCharacters(in: NSMakeRange(length - 1, 1))
    }
    
    func center() -> Self {
        let myParagraphStyle = NSMutableParagraphStyle()
        myParagraphStyle.alignment = .center // center the text
//        myParagraphStyle.lineSpacing = 14 //Change spacing between lines
//        myParagraphStyle.paragraphSpacing = 38 //Change space between paragraphs
        self.addAttributes([.paragraphStyle: myParagraphStyle], range: NSRange(location: 0, length: self.length))
        return self
    }
    
}

extension String {
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    mutating func replaceMatchesTo(pattern: String, with: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: with)
        } catch {
            return
        }
    }
}
