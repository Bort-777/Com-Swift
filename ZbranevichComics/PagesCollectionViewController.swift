//
//  PagesCollectionViewController.swift
//  ZbranevichComics
//
//  Created by user on 6/20/16.
//  Copyright © 2016 itransition. All rights reserved.
//

import UIKit




class PagesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentBook = Book()
    var currentPage = Page()
    var currentDragAndDropIndexPath: NSIndexPath?
    var currentDragAndDropSnapShot: UIView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = String(currentBook.name)
        // Do any additional setup after loading the view, typically from a nib.
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        collectionView.addGestureRecognizer(longpress)
    }
    
    func longPressGestureRecognized(sender: UIGestureRecognizer) {
       let currentLocation = sender.locationInView(self.collectionView)
        let indexPatchForLocation: NSIndexPath? = self.collectionView!.indexPathForItemAtPoint(currentLocation)
        
        switch sender.state {
        case .Began:
            if indexPatchForLocation != nil {
                self.currentDragAndDropIndexPath = indexPatchForLocation
                let cell: PagesCollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(indexPatchForLocation!) as? PagesCollectionViewCell
                self.currentDragAndDropSnapShot = cell!.snapshot
                self.updareDragAndDropSnapShotView(0.0, center: cell!.center, transform: CGAffineTransformIdentity)
                self.collectionView!.addSubview(self.currentDragAndDropSnapShot!)
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.updareDragAndDropSnapShotView(0.95, center: cell!.center, transform: CGAffineTransformMakeScale(1.05, 1.05))
                    cell?.isMoving = true
                })
            }
        case .Changed:
            self.currentDragAndDropSnapShot!.center = currentLocation
            if indexPatchForLocation != nil {
                let page: Page = self.currentBook.page[self.currentDragAndDropIndexPath!.row]
                try! uiRealm.write({
                    currentBook.page.removeAtIndex(self.currentDragAndDropIndexPath!.row)
                    currentBook.page.insert(page, atIndex: indexPatchForLocation!.row)
                    
                })
                self.collectionView!.moveItemAtIndexPath(self.currentDragAndDropIndexPath!, toIndexPath:  indexPatchForLocation!)
                self.currentDragAndDropIndexPath = indexPatchForLocation
            }
        default:
            if indexPatchForLocation != nil {
                let cell: PagesCollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(indexPatchForLocation!) as? PagesCollectionViewCell
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.updareDragAndDropSnapShotView(0.0, center: cell!.center, transform: CGAffineTransformIdentity)
                    cell?.isMoving = false
                    }, completion: { (finished: Bool) -> Void in
                        self.currentDragAndDropSnapShot?.removeFromSuperview()
                        self.currentDragAndDropSnapShot = nil
                })
            }
            else {
                let cell: PagesCollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(currentDragAndDropIndexPath!) as? PagesCollectionViewCell
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.updareDragAndDropSnapShotView(0.0, center: cell!.center, transform: CGAffineTransformIdentity)
                    cell?.isMoving = false
                    }, completion: { (finished: Bool) -> Void in
                        self.currentDragAndDropSnapShot?.removeFromSuperview()
                        self.currentDragAndDropSnapShot = nil
                })

            }
        }
    }
    
    func updareDragAndDropSnapShotView(alpha: CGFloat, center: CGPoint, transform: CGAffineTransform) {
        if self.currentDragAndDropSnapShot != nil {
            self.currentDragAndDropSnapShot?.alpha = alpha
            self.currentDragAndDropSnapShot?.center = center
            self.currentDragAndDropSnapShot?.transform = transform
        }
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return currentBook.page.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PagesCollectionViewCell
        let page = currentBook.page[indexPath.row]
        cell.setPage(page)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        currentPage = currentBook.page[indexPath.row]
        self.performSegueWithIdentifier("showImage", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
        
        switch segue.identifier {
        case "showImage"?:
                //let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
                //let indexPath = indexPaths[0] as NSIndexPath
            let vc = segue.destinationViewController as! PagesViewController
            vc.currentBook = self.currentBook
            vc.frameViewController.currentPage = currentPage
            
        case "addPage"?:
            let vc = segue.destinationViewController as! SettingsViewController
            vc.currentBook = self.currentBook
        default: break
            
        }
    }
    @IBAction func editBook(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        let destroyAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            try! uiRealm.write({ () -> Void in
                uiRealm.delete(self.currentBook)
            })
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        let addAction = UIAlertAction(title: "Add Page", style: .Default) { (action) in
            self.performSegueWithIdentifier("addPage", sender: self)
        }
        alertController.addAction(addAction)
        alertController.addAction(destroyAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}


class PagesCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!

    
    func setPage(page: Page) {
        imageView.image = loadImage(page.id)
    }
    
    func loadImage(id: Int) -> UIImage? {
        let imageName = String(id)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let readPath = "\(pathDocuments)/\(imageName).jpg"
        let image    = UIImage(contentsOfFile: readPath)
        // Do whatever you want with the image
        return image
    }
    
    var isMoving: Bool = false {
        didSet {
            self.imageView!.alpha = isMoving ? 0.2 : 1.0
            self.backgroundColor = isMoving ? UIColor.clearColor() : UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        }
    }
    
    var snapshot: UIView {
        let snapshot: UIView = self.snapshotViewAfterScreenUpdates(true)
        let layer: CALayer = snapshot.layer
        layer.masksToBounds = false
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -4.0, height: 0.0)
        
        return snapshot
    }
}

