//
//  EasyColor.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/16.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

extension UIColor {

    public static var groupColor: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemGroupedBackground
        } else {
            return .groupTableViewBackground
        }
    }()

    public static func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0.2...0.8),
            green: CGFloat.random(in: 0.2...0.8),
            blue: CGFloat.random(in: 0.2...0.8),
            alpha: 1
        )
    }

    public static func hexColor(hex: Int, alpha: CGFloat = 1) -> UIColor {
        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        return UIColor(red: CGFloat(red) / 255,
                       green: CGFloat(green) / 255,
                       blue: CGFloat(blue) / 255,
                       alpha: alpha)
    }

}
