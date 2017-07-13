//
//  UIImage+HeadImage.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/15.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func imageWithUsername(username:String?, placeholderImage:UIImage?) {
        var placeholderImage = placeholderImage
        if placeholderImage == nil {
            placeholderImage = UIImage(named: "default_avatar")
        }
        
        let entity = EMUserProfileManager.sharedInstance.getUserProfileByUsername(username: username)
        if entity != nil && entity?.imageUrl != nil {
            sd_setImage(with: URL.init(string: (entity?.imageUrl)!), placeholderImage: placeholderImage)
        } else {
            sd_setImage(with: nil, placeholderImage: placeholderImage)
        }
    }
}
