//
//  EMMessageModel.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/19.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

class EMMessageModel: NSObject {
    var message: EMMessage?
    var isPlaying: Bool = false
    var thumbnailImage: UIImage?
    
    init(withMesage msg: EMMessage) {
        message = msg
    }
}
