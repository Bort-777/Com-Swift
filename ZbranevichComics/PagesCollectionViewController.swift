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
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    var currentBook = Book()
    var currentPage = Page()
    var editModeEnabled = false
    var currentDragAndDropIndexPath: NSIndexPath?
    var currentDragAndDropSnapShot: UIView?
    var longpress: UILongPressGestureRecognizer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = String(currentBook.name)
        
        // Do any additional setup after loading the view, typically from a nib.
        longpress = UILongPressGestureRecognizer(target: self, action: #selector(PagesCollectionViewController.longPressGestureRecognized(_:)))
    }
    
    override func viewDidAppear(animated: Bool) {
        self.collectionView.reloadData()
    }
    
    func longPressGestureRecognized(sender: UIGestureRecognizer) {
       let currentLocation = sender.locationInView(self.collectionView)
        let indexPatchForLocation: NSIndexPath? = self.collectionView!.indexPathForItemAtPoint(currentLocation)
        
        switch sender.state {
        case .Began:
            if indexPatchForLocation != nil {
                self.currentDragAndDropIndexPath = indexPatchForLocation
                let cell: PageCollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(indexPatchForLocation!) as? PageCollectionViewCell
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
                let cell: PageCollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(indexPatchForLocation!) as? PageCollectionViewCell
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.updareDragAndDropSnapShotView(0.0, center: cell!.center, transform: CGAffineTransformIdentity)
                    cell?.isMoving = false
                    }, completion: { (finished: Bool) -> Void in
                        self.currentDragAndDropSnapShot?.removeFromSuperview()
                        self.currentDragAndDropSnapShot = nil
                })
            }
            else {
                let cell: PageCollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(currentDragAndDropIndexPath!) as? PageCollectionViewCell
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PageCollectionViewCell
        let page = currentBook.page[indexPath.row]
        cell.setPage(page)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
       
        
        if(editModeEnabled == false) {
            currentPage = currentBook.page[indexPath.row]
            self.performSegueWithIdentifier("showImage", sender: self)
        } else {
           
        }
        
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
            let vc = segue.destinationViewController as! ImageViewController
            vc.comics = self.currentBook
        default: break
            
        }
    }
    
    @IBAction func editBook(sender: UIBarButtonItem) {
        if(editModeEnabled == false) {
            editButton.title = "Done"
            self.editButton.style = .Done
            editModeEnabled = true
  
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addPage))
            let editName = UIBarButtonItem(title: "Edit title", style: .Plain, target: self, action: #selector(PagesCollectionViewController.editName))
            let delete = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(deleteComics))

  
            toolbarItems = [add, spacer, editName, spacer, delete]
    
            navigationController?.setToolbarHidden(false, animated: true)
        
            collectionView.addGestureRecognizer(longpress!)
        
            for item in self.collectionView!.visibleCells() as! [PageCollectionViewCell] {
            
                item.shakeIcons()
                item.selector.hidden  = false
                item.isSelect = false
            }
        }
        else {
            editButton.title = "Edit"
            editButton.style = .Plain
            editModeEnabled = false
            
            for item in self.collectionView!.visibleCells() as! [PageCollectionViewCell] {
                
                item.isSelect = false
                item.selector.hidden  = true
                item.stopShakingIcons()
            }

            navigationController?.setToolbarHidden(true, animated: true)
            
            collectionView.removeGestureRecognizer(longpress!)
        }
    }
    
    func addPage() {
        editBook(editButton)
        navigationController?.setToolbarHidden(true, animated: true)
        self.performSegueWithIdentifier("addPage", sender: self)
    }
    
    func editName() {
        let alertController = UIAlertController(title: "Comics", message: "Name this comic", preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Save", style: .Default) { (_) in
            let field = alertController.textFields![0]
            try! uiRealm.write({
                self.currentBook.name = field.text!
            })
            self.title = self.currentBook.name
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.text = self.title
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.setNeedsLayout()
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func deleteComics(sender: AnyObject?) {
        
        for item in self.collectionView!.visibleCells() as! [PageCollectionViewCell] {
            if item.isSelect {
                try! uiRealm.write({
                    let index = self.currentBook.page.indexOf(item.currPage!)
                    self.currentBook.page.removeAtIndex(index!)
                    self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index!, inSection: 0 )])
                })
                
            }
        }
        editBook(editButton)
   
        
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


class PageCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!

    
    func setPage(page: Page) {
        self.currPage = page
    }
    
    var currPage: Page? {
        didSet {
            imageView.image = loadImage(currPage!.id)
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
    
    @IBOutlet weak var selector: UIButton!
    var isSelect: Bool = false {
        didSet {
            self.selector!.alpha = isSelect ? 1.0 : 0.5
            self.imageView!.alpha = isSelect ? 0.5 : 1.0
        }
    }
    
    var isMoving: Bool = false {
        didSet {
            self.hidden = isMoving
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
    
    // This function shake the collection view cells
    func shakeIcons() {
        let shakeAnim = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnim.duration = 0.05
        shakeAnim.repeatCount = 2
        shakeAnim.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/180
        let stopAngle = -startAngle
        shakeAnim.fromValue = NSNumber(float: startAngle)
        shakeAnim.toValue = NSNumber(float: 3 * stopAngle)
        shakeAnim.autoreverses = true
        shakeAnim.duration = 0.2
        shakeAnim.repeatCount = 10000
        shakeAnim.timeOffset = 290 * drand48()
        
        //Create layer, then add animation to the element's layer
        let layer: CALayer = self.layer
        layer.addAnimation(shakeAnim, forKey:"shaking")
        //shakeEnabled = true
    }
    
    // This function stop shaking the collection view cells
    func stopShakingIcons() {
        let layer: CALayer = self.layer
        layer.removeAnimationForKey("shaking")
        //self.deleteButton.hidden = true
        //shakeEnabled = false
    }
    
    @IBAction func selectIcon(sender: AnyObject) {
        if (isSelect == false) {
            isSelect = true
        }
        else {
            isSelect = false
        }
    }
    

}

