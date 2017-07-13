//
//  EMMessageReadManager.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/26.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import MWPhotoBrowser

let readManager = EMMessageReadManager()
class EMMessageReadManager: NSObject, MWPhotoBrowserDelegate {

    var photos: Array = Array<MWPhoto>()
    var photoNavticationController: UINavigationController?
    var photoBrowser: MWPhotoBrowser?
    
    override init() {
        super.init()
        setupView()
    }
    
    func setupView() {
        photoBrowser = MWPhotoBrowser.init(delegate: self as MWPhotoBrowserDelegate)
        photoBrowser?.displayActionButton = true
        photoBrowser?.displayNavArrows = true
        photoBrowser?.displaySelectionButtons = false
        photoBrowser?.alwaysShowControls = false
        photoBrowser?.zoomPhotosToFill = true
        photoBrowser?.enableGrid = false
        photoBrowser?.startOnGrid = false
        photoBrowser?.setCurrentPhotoIndex(0)
        photoNavticationController = UINavigationController.init(rootViewController: photoBrowser!)
        photoNavticationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    }
    
    // MARK: - Public
    func showBrower(_ images: Array<Any>) {
        if images.count > 0 {
            var arys = Array<MWPhoto>()
            for obj in images {
                var photo: MWPhoto?
                if obj is UIImage {
                    photo = MWPhoto.init(image: obj as! UIImage)
                }else if obj is URL{
                    photo = MWPhoto.init(url: obj as! URL)
                }
                
                if photo != nil {arys.append(photo!)}
            }
            
            photos = arys
        }
        photoBrowser!.reloadData()
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        rootViewController?.present(photoNavticationController!, animated: true, completion: nil)
    }
    
    // MARK: - MWPhotoBrowserDelegate
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(photos.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        if Int(index) < photos.count {
            return photos[Int(index)] as MWPhotoProtocol
        }
        
        return nil
    }
}
