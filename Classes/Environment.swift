//
//  Environment.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public class Environment {
        
    public class func isDebug() -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
