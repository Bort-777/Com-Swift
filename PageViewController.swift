//
//  PageViewController.swift
//  ZbranevichComics
//
//  Created by user on 7/2/16.
//  Copyright © 2016 itransition. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PageViewController: UIViewController {
    
    // frame for page
    private var template = UIView()
    
    // image on frame
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .ScaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // page data
    var currentPage: Page? {
        didSet {
            imageView.image = loadImage(currentPage!.id)
        }
    }
    
    var activityIndicatorView: UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }
    
    // MARK: - view functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicatorView.startAnimating()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // get position on view
        let rect = templatePosition()
 
        template = UIView(frame: rect)
        template.addSubview(imageView)
        
        // MARK: - Settings imagwView
        
        template.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options:
            NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        template.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v0]|", options:
            NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        
        view.addSubview(template)
        
        // MARK: - Settings video
        
        for video in currentPage!.data
        {
            let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
            let pathVideo = "\(pathDocuments)/\(video.id).MOV"
            let x = CGFloat(video.x)
            let y = CGFloat(video.y)
            let h = CGFloat(video.height)
            let w = CGFloat(video.width)
            addVideo(CGRect(x: x, y: y, width: w, height: h), path: pathVideo)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        template.removeFromSuperview()
        viewDidAppear(true)
    }
    
    // get template position
    private func templatePosition() -> CGRect {
        if UIDevice.currentDevice().orientation.isPortrait.boolValue {
            let x = CGFloat(0)
            let y = view.frame.midY - view.frame.midX
            let size = view.frame.size.width
            
            return CGRect(x: x, y: y, width: size, height: size)
        }
        else {
            let x = view.frame.midX - view.frame.midY
            let y = CGFloat(0)
            let size = view.frame.size.height
            
            return CGRect(x: x, y: y, width: size, height: size)
        }
    }
    
    // load image
    private func loadImage(id: Int) -> UIImage? {
        let imageName = String(id)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let readPath = "\(pathDocuments)/\(imageName).jpg"
        
        let image    = UIImage(contentsOfFile: readPath)
        // Do whatever you want with the image
        return image
    }
    
    // MARK: - Add video
    
    private func addVideo(frame: CGRect, path: String) {
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        playerController.view.frame = frame
        self.addChildViewController(playerController)
        
        self.template.addSubview(playerController.view)
    }
}