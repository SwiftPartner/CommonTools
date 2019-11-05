//
//  Print.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public class Log {
    
    private init(){}
    
    private class func pretty(hearts:String = "💚💚💚", filename: String = #file, function : String = #function, line: Int = #line) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        let filename = URL(fileURLWithPath: filename).lastPathComponent.split(separator: ".").first ?? ""
        let pretty = "\(formattedDate) \(filename) \(line) \(function): \(hearts) "
        return pretty
    }
    
    public class func i(_ items: Any..., filename: String = #file, function : String = #function, line: Int = #line) {
        if Environment.isDebug() {
            let prettryMsg = pretty(filename: filename, function: function, line: line)
            let output = items.map { "\($0)" }.joined(separator: " ")
            print(prettryMsg + output)
        }
    }
    
    public class func w(_ items: Any..., filename: String = #file, function : String = #function, line: Int = #line) {
        if Environment.isDebug() {
            let prettryMsg = pretty(hearts: "💛💛💛", filename: filename, function: function, line: line)
            let output = items.map { "\($0)" }.joined(separator: " ")
            print(prettryMsg + output)
        }
    }
    
    public class func e(_ items: Any..., filename: String = #file, function : String = #function, line: Int = #line) {
        if Environment.isDebug() {
            let prettryMsg = pretty(hearts: "❤️❤️❤️", filename: filename, function: function, line: line)
            let output = items.map { "\($0)" }.joined(separator: " ")
            print(prettryMsg + output)
        }
    }
}
