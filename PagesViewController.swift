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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
            
        view.backgroundColor = UIColor.whiteColor()
            
        let frameViewController = FrameViewController()
        frameViewController.currentPage = currentBook.page[0]
            
        let viewControllers = [frameViewController]
        setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
    }
    
        
    func pageViewController(pageController: UIPageViewController, viewControllerAfterViewController
        viewController: UIViewController) -> UIViewController? {
        
        let currentImageName = (viewController as! FrameViewController).currentPage
        let currentIndex = currentBook.page.indexOf(currentImageName!)
        
        if currentIndex < currentBook.page.count - 1 {
            let frameViewController = FrameViewController()
            frameViewController.currentPage = currentBook.page[currentIndex! + 1]
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
            return frameViewController
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 2
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 1
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
    var template = UIImageView()

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
       
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let rect = templatePosition()

        template = UIImageView(frame: rect)
        
        template.addSubview(imageView)
        //navigationController?.navigationBar.hidden = true // for navigation bar hide
        //UIApplication.sharedApplication().statusBarHidden=true; // for status bar hide
        
        template.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options:
            NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        template.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[v0]|", options:
            NSLayoutFormatOptions(), metrics: nil, views: ["v0": imageView]))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(self.imageTapped(_:) ))
        tapGestureRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)

        
        view.addSubview(template)
        
        
        if firstAppear {
            for video in currentPage!.data
            {
                //print(image.frame.minY)
                let x = CGFloat(video.x) + imageView.frame.minX
                let y = CGFloat(video.y) + imageView.frame.minY
                let h = CGFloat(video.height)
                let w = CGFloat(video.width)
                playVideo(CGRect(x: x, y: y, width: h, height: w), path: video.URL)

            }
            firstAppear = false
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            viewDidAppear(true)
    }
    
    func templatePosition() -> CGRect {
        if UIDevice.currentDevice().orientation.isPortrait.boolValue {
            let x = CGFloat(0)
            let y = view.bounds.midY - view.bounds.midX
            let size = view.bounds.size.width
            
            return CGRect(x: x, y: y, width: size, height: size)
        }
        else {
            let x = view.bounds.midX - view.bounds.midY
            let y = CGFloat(0)
            let size = view.bounds.size.height
            
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
        print(frame)

        
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        
        playerController.view.frame = frame
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        player.play()
        
    }
}