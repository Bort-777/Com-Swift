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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class PagesViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var currentBook = Book()
    let frameViewController = PageViewController()
    
    // black screen
    var fullScreen: Bool? {
        didSet {
            view.backgroundColor = fullScreen! ? UIColor.black : UIColor.white
            navigationController?.navigationBar.isHidden = fullScreen!
            UIApplication.shared.isStatusBarHidden = fullScreen!
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
        setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
        
        // tap on pag for changing color
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PagesViewController.tapGestureDetected(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)

    }

    // called when need change screen
    func tapGestureDetected(_ sender: UITapGestureRecognizer) {
        
        fullScreen! = !fullScreen!
    }
    
    // MARK: - picker view delegate and data source (to choose page)
        
    func pageViewController(_ pageController: UIPageViewController, viewControllerAfter
        viewController: UIViewController) -> UIViewController? {
        
        let currentImageName = (viewController as! PageViewController).currentPage
        let currentIndex = currentBook.page.index(of: currentImageName!)
        
        if currentIndex < currentBook.page.count - 1 {
            let frameViewController = PageViewController()
            frameViewController.currentPage = currentBook.page[currentIndex! + 1]
            frameViewController.activityIndicatorView.activityIndicatorViewStyle = fullScreen! ? .whiteLarge : .gray

            return frameViewController
        }
        
        return nil
    }
        
    func pageViewController(_ pageController: UIPageViewController, viewControllerBefore
               viewController: UIViewController) -> UIViewController? {
        
        let currentImageName = (viewController as! PageViewController).currentPage
        let currentIndex = currentBook.page.index(of: currentImageName!)
        
        if currentIndex > 0 {
            let frameViewController = PageViewController()
            frameViewController.currentPage = currentBook.page[currentIndex! - 1]
            frameViewController.activityIndicatorView.activityIndicatorViewStyle = fullScreen! ? .whiteLarge : .gray
            
            return frameViewController
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return currentBook.page.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        let currentImageName = frameViewController.currentPage
        let currentIndex = currentBook.page.index(of: currentImageName!)
        
        return currentIndex!
    }
    
    // MARK: - actions
    
    @IBAction func shareAction(_ sender: AnyObject) {
        let FacebookString = NSLocalizedString("FACEBOOK", comment: "FACEBOOK buttom")
        let TwitterString = NSLocalizedString("TWITTER", comment: "TWITTER buttom")
        let DropboxString = NSLocalizedString("DROPBOX", comment: "DROPBOX buttom")
        

        let optionMenu = UIAlertController(title: nil, message: "Share to", preferredStyle: .actionSheet)
        let facebookAction = UIAlertAction(title: FacebookString, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareSLComposeView(SLServiceTypeFacebook)
        })
        let twitterAction = UIAlertAction(title: TwitterString, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareSLComposeView(SLServiceTypeTwitter)
        })
        let dropboxAction = UIAlertAction(title: DropboxString, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.authorizedDropbox()
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "accounts buttom"),
                                         style: .cancel,
                                         handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(facebookAction)
        optionMenu.addAction(twitterAction)
        optionMenu.addAction(dropboxAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // share Facebook and Twitter
    func shareSLComposeView(_ SLServiceType: String) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceType) {
            let twShare = SLComposeViewController(forServiceType: SLServiceType)
            let text = "Оne page of my comic \"\(currentBook.name)\""
            let image = frameViewController.imageView.image!
            let url = URL(string: "https://github.com/Bort-777/Comics-Swift")
            
            twShare?.setInitialText(text)
            twShare?.add(url)
            twShare?.add(image)
            
            self.present(twShare!, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: NSLocalizedString("ACCOUNTS", comment: "accounts buttom"),
                                          message: NSLocalizedString("ACCOUNTSLOGINERROR", comment: "accounts buttom"),
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // authorized Dropbox
    func authorizedDropbox() {
        if DropboxClientsManager.authorizedClient != nil {
            self.saveToDropbox()
        }
        else {
            DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: { (URL) in

            })
            self.saveToDropbox()
        }
    }
    
    // save to Dropbox
    func saveToDropbox() {
        if let client = DropboxClientsManager.authorizedClient {
            let path = "/\(currentBook.name)/\(frameViewController.currentPage!.id).jpg"
            let fileData = UIImagePNGRepresentation(frameViewController.imageView.image!)
            
            // Upload a file
            // TODO:
//            client.files.upload(path: path, : fileData!).response { response, error in
//                if response != nil {
//                    let alert = UIAlertController(title: "Save to Dropbox", message: "File upload was successful.", preferredStyle: UIAlertControllerStyle.Alert)
//                    
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                    
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//                else {
//                    print(error!)
//                }
//            }
        }
    }
}
