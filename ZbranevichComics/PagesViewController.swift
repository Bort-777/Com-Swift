//
//  PagesViewController.swift
//  ZbranevichComics
//
//  Created by user on 6/20/16.
//  Copyright © 2016 itransition. All rights reserved.
//


import UIKit
import Social
import SwiftyDropbox

class PagesViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var currentBook = Book()
    let frameViewController = PageViewController()
    
    // black screen
    var fullScreen: Bool? {
        didSet {
            view.backgroundColor = fullScreen! ? UIColor.blackColor() : UIColor.whiteColor()
            navigationController?.navigationBar.hidden = fullScreen!
            UIApplication.sharedApplication().statusBarHidden = fullScreen!
        }
    }
    
    // MARK: - view functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        // choose style
        fullScreen = false

        // page in PagesViewController
        let viewControllers = [frameViewController]
        setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        // tap on pag for changing color
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PagesViewController.tapGestureDetected(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)

    }

    // called when need change screen
    func tapGestureDetected(sender: UITapGestureRecognizer) {
        
        fullScreen! = !fullScreen!
    }
    
    // MARK: - picker view delegate and data source (to choose page)
        
    func pageViewController(pageController: UIPageViewController, viewControllerAfterViewController
        viewController: UIViewController) -> UIViewController? {
        
        let currentImageName = (viewController as! PageViewController).currentPage
        let currentIndex = currentBook.page.indexOf(currentImageName!)
        
        if currentIndex < currentBook.page.count - 1 {
            let frameViewController = PageViewController()
            frameViewController.currentPage = currentBook.page[currentIndex! + 1]
            frameViewController.activityIndicatorView.activityIndicatorViewStyle = fullScreen! ? .WhiteLarge : .Gray

            return frameViewController
        }
        
        return nil
    }
        
    func pageViewController(pageController: UIPageViewController, viewControllerBeforeViewController
               viewController: UIViewController) -> UIViewController? {
        
        let currentImageName = (viewController as! PageViewController).currentPage
        let currentIndex = currentBook.page.indexOf(currentImageName!)
        
        if currentIndex > 0 {
            let frameViewController = PageViewController()
            frameViewController.currentPage = currentBook.page[currentIndex! - 1]
            frameViewController.activityIndicatorView.activityIndicatorViewStyle = fullScreen! ? .WhiteLarge : .Gray
            
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
    
    // MARK: - actions
    
    @IBAction func shareAction(sender: AnyObject) {

        let optionMenu = UIAlertController(title: nil, message: "Share to", preferredStyle: .ActionSheet)
        let facebookAction = UIAlertAction(title: "Facebook", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareSLComposeView(SLServiceTypeFacebook)
        })
        let twitterAction = UIAlertAction(title: "Twitter", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareSLComposeView(SLServiceTypeTwitter)
        })
        let dropboxAction = UIAlertAction(title: "Dropbox", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.authorizedDropbox()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(facebookAction)
        optionMenu.addAction(twitterAction)
        optionMenu.addAction(dropboxAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    // share Facebook and Twitter
    func shareSLComposeView(SLServiceType: String) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceType) {
            let twShare = SLComposeViewController(forServiceType: SLServiceType)
            let text = "Оne page of my comic \"\(currentBook.name)\""
            let image = frameViewController.imageView.image!
            let url = NSURL(string: "https://github.com/Bort-777/Comics-Swift")
            
            twShare.setInitialText(text)
            twShare.addURL(url)
            twShare.addImage(image)
            
            self.presentViewController(twShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // authorized Dropbox
    func authorizedDropbox() {
        if Dropbox.authorizedClient != nil {
            self.saveToDropbox()
        }
        else {
            Dropbox.authorizeFromController(self)
            self.saveToDropbox()
        }
    }
    
    // save to Dropbox
    func saveToDropbox() {
        if let client = Dropbox.authorizedClient {
            let path = "/\(currentBook.name)/\(frameViewController.currentPage!.id).jpg"
            let fileData = UIImagePNGRepresentation(frameViewController.imageView.image!)
            
            // Upload a file
            client.files.upload(path: path, body: fileData!).response { response, error in
                if response != nil {
                    let alert = UIAlertController(title: "Save to Dropbox", message: "File upload was successful.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    print(error!)
                }
            }
        }
    }
}