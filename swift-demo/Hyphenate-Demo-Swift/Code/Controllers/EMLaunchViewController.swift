//
//  EMLaunchViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/12.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate


let animationDuration = 1.65 

class EMLaunchViewController: UIViewController, EMClientDelegate {
    
    @IBOutlet weak var launchImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor() 
        setLauchAnimation() 

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + animationDuration, execute: {
            if EMClient.shared().isLoggedIn {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: NSNumber(value: true)) 
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_LOGINCHANGE), object: NSNumber(value: false)) 
            }
        }) 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent 
    }
    
    func setBackgroundColor () {
        let gradient = CAGradientLayer.init() 
        gradient.frame = UIScreen.main.bounds 
        gradient.colors =  [LaunchTopColor.cgColor, LaunchBottomColor.cgColor] 
        gradient.startPoint = CGPoint.init(x: 0.0, y: 0.0) 
        gradient.endPoint = CGPoint.init(x: 0.0, y: 1.0) 
        view.layer.insertSublayer(gradient, at: 0) 
    }
    
    func setLauchAnimation () {
        launchImageView.animationImages = [
            UIImage(named: "logo1")!,
            UIImage(named: "logo2")!,
            UIImage(named: "logo3")!,
            UIImage(named: "logo4")!,
            UIImage(named: "logo5")!,
            UIImage(named: "logo6")!,
            UIImage(named: "logo7")!,
            UIImage(named: "logo8")!,
            UIImage(named: "logo9")!,
            UIImage(named: "logo10")!,
            UIImage(named: "logo11")!
        ] 
        
        launchImageView.animationDuration = animationDuration 
        launchImageView.animationRepeatCount = 1 
        launchImageView.startAnimating() 
        
        launchImageView.top(top: (kScreenHeight - launchImageView.height()) / 2) 
        launchImageView.left(left: (kScreenWidth - launchImageView.width()) / 2) 
    }
}
