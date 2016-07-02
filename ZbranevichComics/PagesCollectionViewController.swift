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
    
    var currentPage: Page? // tap page
    var currentBook : Book? {
        didSet {
            self.title = String(currentBook!.name)
        }
    }
    
    var editModeEnabled = false
    
    //moving data
    var currentDragAndDropIndexPath: NSIndexPath?
    var currentDragAndDropSnapShot: UIView?
    var longpress: UILongPressGestureRecognizer {
        return UILongPressGestureRecognizer(target: self, action: #selector(PagesCollectionViewController.longPressGestureRecognized(_:)))
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.collectionView.reloadData()
    }
    
    // MARK: - Moving functions
    
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
                let page: Page = self.currentBook!.page[self.currentDragAndDropIndexPath!.row]
                try! uiRealm.write({
                    currentBook!.page.removeAtIndex(self.currentDragAndDropIndexPath!.row)
                    currentBook!.page.insert(page, atIndex: indexPatchForLocation!.row)
                    
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
    
    // MARK: - data functions
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return currentBook!.page.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PagesCollectionViewCell
        let page = currentBook!.page[indexPath.row]
        
        cell.setPage(page)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if !editModeEnabled {
            currentPage = currentBook!.page[indexPath.row]
            self.performSegueWithIdentifier("showImage", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        switch segue.identifier {
        case "showImage"?:
                //let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
                //let indexPath = indexPaths[0] as NSIndexPath
            let vc = segue.destinationViewController as! PagesViewController
            vc.currentBook = self.currentBook!
            vc.frameViewController.currentPage = currentPage
            
        case "addPage"?:
            let vc = segue.destinationViewController as! ImageViewController
            vc.comics = self.currentBook!
        default: break
            
        }
    }
    
    // MARK: - edit functions
    
    @IBAction func editBook(sender: UIBarButtonItem) {
        if !editModeEnabled {
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            let add = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addPage))
            let delete = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(deletePages))
            
            toolbarItems = [add, spacer, delete]
            navigationController?.setToolbarHidden(false, animated: true)
            
            //edit button
            editButton.title = "Done"
            self.editButton.style = .Done
            editModeEnabled = true
        
            collectionView.addGestureRecognizer(longpress)
            for item in self.collectionView!.visibleCells() as! [PagesCollectionViewCell] {
                item.shakeIcons()
                item.selector.hidden  = false
                item.isSelect = false
            }
        }
        else {
            //edit button
            editButton.title = "Edit"
            editButton.style = .Plain
            editModeEnabled = false
            navigationController?.setToolbarHidden(true, animated: true)
            collectionView.removeGestureRecognizer(longpress)
            
            for item in self.collectionView!.visibleCells() as! [PagesCollectionViewCell] {
                item.isSelect = false
                item.selector.hidden  = true
                item.stopShakingIcons()
            }
        }
    }
    
    // add new page to comics
    func addPage() {
        editBook(editButton)
        navigationController?.setToolbarHidden(true, animated: true)
        self.performSegueWithIdentifier("addPage", sender: self)
    }
    
    // delete selected pages
    func deletePages(sender: AnyObject?) {
        for item in self.collectionView!.visibleCells() as! [PagesCollectionViewCell] {
            if item.isSelect {
                // realm transaction
                try! uiRealm.write({
                    let index = self.currentBook!.page.indexOf(item.currPage!)
                    self.currentBook!.page.removeAtIndex(index!)
                    self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index!, inSection: 0 )])
                })
            }
        }
        // cell edit button
        editBook(editButton)
    }
}
