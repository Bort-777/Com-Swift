//
//  PagesViewController.swift
//  ZbranevichComics
//
//  Created by user on 6/20/16.
//  Copyright © 2016 itransition. All rights reserved.
//


import UIKit
import AVKit
import AVFoundation

class PagesViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var currentBook = Book()
    let frameViewController = FrameViewController()
    var fullScreen = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        view.backgroundColor = UIColor.blackColor()
        navigationController?.navigationBar.hidden = true // for navigation bar show
        UIApplication.sharedApplication().statusBarHidden = true; // for status bar show

        let viewControllers = [frameViewController]
        setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PagesViewController.tapGestureDetected(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)

    }
    
    func tapGestureDetected(sender: UITapGestureRecognizer) {
        if fullScreen {
            view.backgroundColor = UIColor.whiteColor()
            navigationController?.navigationBar.hidden = false // for navigation bar hide
            UIApplication.sharedApplication().statusBarHidden = false; // for status bar hide
            fullScreen = false
        } else {
            view.backgroundColor = UIColor.blackColor()
            navigationController?.navigationBar.hidden = true // for navigation bar show
            UIApplication.sharedApplication().statusBarHidden = true; // for status bar show
            fullScreen = true
        }
       

    }
    
        
    func pageViewController(pageController: UIPageViewController, viewControllerAfterViewController
        viewController: UIViewController) -> UIViewController? {
        
        let currentImageName = (viewController as! FrameViewController).currentPage
        let currentIndex = currentBook.page.indexOf(currentImageName!)
        
        if currentIndex < currentBook.page.count - 1 {
            let frameViewController = FrameViewController()
            frameViewController.currentPage = currentBook.page[currentIndex! + 1]
            if fullScreen {
                frameViewController.activityIndicatorView.activityIndicatorViewStyle = .WhiteLarge
            } else {
                frameViewController.activityIndicatorView.activityIndicatorViewStyle = .Gray
            }

            return frameViewController
        }
        
        return nil
        }
        
    func pageViewController(pageController: UIPageViewController, viewControllerBeforeViewController
               viewController: UIViewController) -> UIViewController? {
        
        let currentImageName = (viewController as! FrameViewController).currentPage
        let currentIndex = currentBook.page.indexOf(currentImageName!)
        
        if currentIndex > 0 {
            let frameViewController = FrameViewController()
            frameViewController.currentPage = currentBook.page[currentIndex! - 1]
            if fullScreen {
                frameViewController.activityIndicatorView.activityIndicatorViewStyle = .WhiteLarge
            } else {
                frameViewController.activityIndicatorView.activityIndicatorViewStyle = .Gray
            }
            return frameViewController
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentBook.page.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        let currentImageName = frameViewController.currentPage
        let currentIndex = currentBook.page.indexOf(currentImageName!)
        return currentIndex!
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //self.reloadInputViews()
    }
    
}

class FrameViewController: UIViewController {


    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .ScaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    var currentPage: Page? {
        didSet {
            imageView.image = loadImage(currentPage!.id)
        }
    }
    private var firstAppear = true
    var template = UIView()
    
    var activityIndicatorView: UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        return activityIndicatorView
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        activityIndicatorView.startAnimating()
        
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let rect = templatePosition()

        template = UIView(frame: rect)
        
        template.addSubview(imageView)
        
        template.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options:
            NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        template.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v0]|", options:
            NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(self.imageTapped(_:) ))
        tapGestureRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)

        
        view.addSubview(template)

        for video in currentPage!.data
        {
            let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
            let pathVideo = "\(pathDocuments)/\(video.id).MOV"
            let x = CGFloat(video.x) //+ template.frame.minX
            let y = CGFloat(video.y) //+ template.frame.minY
            let h = CGFloat(video.height)
            let w = CGFloat(video.width)
            playVideo(CGRect(x: x, y: y, width: w, height: h), path: pathVideo)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            viewDidAppear(true)
    }
    
    func templatePosition() -> CGRect {
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
    
    func loadImage(id: Int) -> UIImage? {
        let imageName = String(id)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let readPath = "\(pathDocuments)/\(imageName).jpg"

        let image    = UIImage(contentsOfFile: readPath)
        // Do whatever you want with the image
        return image
    }
    
    func imageTapped(img: UITapGestureRecognizer) {
        navigationController?.navigationBar.hidden = true // for navigation bar hide
        UIApplication.sharedApplication().statusBarHidden=true; // for status bar hide
    }
    
    private func playVideo(frame: CGRect, path: String) {
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        playerController.view.frame = frame
        self.addChildViewController(playerController)
        self.template.addSubview(playerController.view)
        //player.play()
        
    }
}