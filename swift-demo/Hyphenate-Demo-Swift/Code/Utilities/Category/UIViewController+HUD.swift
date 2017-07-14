//
//  UIViewController+HUD.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/22.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import Foundation
import MBProgressHUD

extension UIViewController {
    
    private struct AssociatedKeys {
        static var hub: MBProgressHUD?
    }
    
    var HUD: MBProgressHUD? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.hub) as? MBProgressHUD
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.hub, newValue as MBProgressHUD?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
 
    func showHub(inView view: UIView,_ hint: String) {
        HUD = MBProgressHUD(view: view)
        HUD?.labelText = hint
        view.addSubview(HUD!)
        HUD?.show(true)
    }
    
    func show(_ hint: String) {
        let view = UIApplication.shared.delegate?.window
        let hub = MBProgressHUD.showAdded(to: view!, animated: true)
        hub?.isUserInteractionEnabled = false
        hub?.mode = MBProgressHUDMode.text
        hub?.labelText = hint
        hub?.margin = 10
        hub?.yOffset = 180
        hub?.removeFromSuperViewOnHide = true
        hub?.hide(true, afterDelay: 2)
    }
    
    func show(hint: String, _ yOffset: Float) {
        let view = UIApplication.shared.delegate?.window
        let hub = MBProgressHUD.showAdded(to: view!, animated: true)
        hub?.isUserInteractionEnabled = false
        hub?.mode = MBProgressHUDMode.text
        hub?.labelText = hint
        hub?.margin = 10
        hub?.yOffset = 180
        hub?.yOffset = hub!.yOffset + yOffset
        hub?.removeFromSuperViewOnHide = true
        hub?.hide(true, afterDelay: 2)
    }
    
    func hideHub() {
        HUD?.hide(true)
    }
}
