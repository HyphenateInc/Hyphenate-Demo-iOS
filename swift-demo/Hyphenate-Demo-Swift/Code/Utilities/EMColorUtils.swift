//
//  EMColorUtils.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/12.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import Foundation
import UIKit

func RGBACOLOR (red: Float, green: Float, blue: Float, alpha: Float) -> UIColor{
    return UIColor.init(colorLiteralRed: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}

let DenimColor          =   RGBACOLOR(red: 64.0,green: 94.0,blue: 122.0,alpha: 1.0);
let FrogGreenColor      =   RGBACOLOR(red: 82.0,green: 210.0,blue: 0.0,alpha: 1.0)
let PaleGrayColor       =   RGBACOLOR(red: 228.0,green: 233.0,blue: 236.0,alpha: 1.0)
let CoolGrayColor       =   RGBACOLOR(red: 173.0,green: 185.0,blue: 193.0,alpha: 1.0)
let CoolGrayColor50     =   RGBACOLOR(red: 173.0,green: 185.0,blue: 193.0,alpha: 0.5)
let KermitGreenTwoColor =   RGBACOLOR(red: 0.0,green: 186.0,blue: 110.0,alpha: 1.0)
let OrangeRedColor      =   RGBACOLOR(red: 255.0,green: 59.0,blue: 48.0,alpha: 1.0)
let AlmostBlackColor    =   RGBACOLOR(red: 12.0,green: 18.0,blue: 24.0,alpha: 1.0)
let BrightBlueColor     =   RGBACOLOR(red: 0.0,green: 122.0,blue: 255.0,alpha: 1.0)
let WhiteColor          =   RGBACOLOR(red: 255.0,green: 255.0,blue: 255.0,alpha: 1.0)
let SteelGreyColor      =   RGBACOLOR(red: 112.0,green: 126.0,blue: 137.0,alpha: 1.0)
let PaleGreyTwoColor    =   RGBACOLOR(red: 236.0,green: 239.0,blue: 241.0,alpha: 1.0)
let BlueyGreyColor      =   RGBACOLOR(red: 135.0,green: 152.0,blue: 164.0,alpha: 1.0)
let LaunchTopColor      =   RGBACOLOR(red: 62.0,green: 92.0,blue: 120.0,alpha: 1.0)
let LaunchBottomColor   =   RGBACOLOR(red: 36.0,green: 62.0,blue: 85.0,alpha: 1.0)
let DefaultBarColor     =   RGBACOLOR(red: 250.0,green: 251.0,blue: 252.0,alpha: 1.0)
let TextViewBorderColor =   RGBACOLOR(red: 189.0,green: 189.0,blue: 189.0,alpha: 1.0)
