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
    var currentDragAndDropIndexPath: IndexPath?
    var currentDragAndDropSnapShot: UIView?
    var longpress: UILongPressGestureRecognizer?
    // MARK: - view functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        longpress = UILongPressGestureRecognizer(target: self, action: #selector(PagesCollectionViewController.longPressGestureRecognized(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    // MARK: - Moving functions
    
    func longPressGestureRecognized(_ sender: UIGestureRecognizer) {
       let currentLocation = sender.location(in: self.collectionView)
        let indexPatchForLocation: IndexPath? = self.collectionView!.indexPathForItem(at: currentLocation)
        
        switch sender.state {
        case .began:
            if indexPatchForLocation != nil {
                self.currentDragAndDropIndexPath = indexPatchForLocation
                let cell: PagesCollectionViewCell? = self.collectionView!.cellForItem(at: indexPatchForLocation!) as? PagesCollectionViewCell
                self.currentDragAndDropSnapShot = cell!.snapshot
                self.updareDragAndDropSnapShotView(0.0, center: cell!.center, transform: CGAffineTransform.identity)
                self.collectionView!.addSubview(self.currentDragAndDropSnapShot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.updareDragAndDropSnapShotView(0.95, center: cell!.center, transform: CGAffineTransform(scaleX: 1.05, y: 1.05))
                    cell?.isMoving = true
                })
            }
        case .changed:
            self.currentDragAndDropSnapShot!.center = currentLocation
            if indexPatchForLocation != nil {
                let page: Page = self.currentBook!.page[self.currentDragAndDropIndexPath!.row]
                try! uiRealm.write({
                    currentBook!.page.remove(at: self.currentDragAndDropIndexPath!.row)
                    currentBook!.page.insert(page, at: indexPatchForLocation!.row)
                    
                })
                self.collectionView!.moveItem(at: self.currentDragAndDropIndexPath!, to:  indexPatchForLocation!)
                self.currentDragAndDropIndexPath = indexPatchForLocation
            }
        default:
            if indexPatchForLocation != nil {
                let cell: PagesCollectionViewCell? = self.collectionView!.cellForItem(at: indexPatchForLocation!) as? PagesCollectionViewCell
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.updareDragAndDropSnapShotView(0.0, center: cell!.center, transform: CGAffineTransform.identity)
                    cell?.isMoving = false
                    }, completion: { (finished: Bool) -> Void in
                        self.currentDragAndDropSnapShot?.removeFromSuperview()
                        self.currentDragAndDropSnapShot = nil
                })
            }
            else {
                let cell: PagesCollectionViewCell? = self.collectionView!.cellForItem(at: currentDragAndDropIndexPath!) as? PagesCollectionViewCell
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.updareDragAndDropSnapShotView(0.0, center: cell!.center, transform: CGAffineTransform.identity)
                    cell?.isMoving = false
                    }, completion: { (finished: Bool) -> Void in
                        self.currentDragAndDropSnapShot?.removeFromSuperview()
                        self.currentDragAndDropSnapShot = nil
                })

            }
        }
    }
    
    func updareDragAndDropSnapShotView(_ alpha: CGFloat, center: CGPoint, transform: CGAffineTransform) {
        if self.currentDragAndDropSnapShot != nil {
            self.currentDragAndDropSnapShot?.alpha = alpha
            self.currentDragAndDropSnapShot?.center = center
            self.currentDragAndDropSnapShot?.transform = transform
        }
    }
    
    // MARK: - data functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return currentBook!.page.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PagesCollectionViewCell
        let page = currentBook!.page[indexPath.row]
        
        cell.setPage(page)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if !editModeEnabled {
            currentPage = currentBook!.page[indexPath.row]
            self.performSegue(withIdentifier: "showImage", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        switch segue.identifier {
        case "showImage"?:
                //let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
                //let indexPath = indexPaths[0] as NSIndexPath
            let vc = segue.destination as! PagesViewController
            vc.currentBook = self.currentBook!
            vc.frameViewController.currentPage = currentPage
            
        case "addPage"?:
            let vc = segue.destination as! TemplateViewController
            vc.comics = self.currentBook!
        default: break
            
        }
    }
    
    // MARK: - edit functions
    
    @IBAction func editBook(_ sender: UIBarButtonItem) {
        editModeEnabled = !editModeEnabled
        editButton.title = editModeEnabled ? NSLocalizedString("DONE", comment: "done buttom") : NSLocalizedString("EDIT", comment: "edit buttom")
        editButton.style = editModeEnabled ? .done : .plain
        
        navigationController?.setToolbarHidden(!editModeEnabled, animated: true)
        
        for item in self.collectionView!.visibleCells as! [PagesCollectionViewCell] {
            editModeEnabled ? item.shakeIcons() : item.stopShakingIcons()
            item.selector.isHidden  = editModeEnabled ? false : true
            item.isSelect = false
        }
        
        if editModeEnabled {
            let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPage))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePages))
            
            toolbarItems = [add, spacer, delete]
            collectionView.addGestureRecognizer(longpress!)
        }
        else {
            collectionView.removeGestureRecognizer(longpress!)
        }
    }
    
    // add new page to comics
    @IBAction func addPage(_ sender: UIBarButtonItem) {
        editBook(editButton)
        navigationController?.setToolbarHidden(true, animated: true)
        self.performSegue(withIdentifier: "addPage", sender: self)
    }
    
    // delete selected pages
    func deletePages(_ sender: AnyObject?) {
        for item in self.collectionView!.visibleCells as! [PagesCollectionViewCell] {
            if item.isSelect {
                // realm transaction
                try! uiRealm.write({
                    let index = self.currentBook!.page.index(of: item.currPage!)
                    self.currentBook!.page.remove(at: index!)
                    self.collectionView.deleteItems(at: [IndexPath(item: index!, section: 0 )])
                })
            }
        }
        // cell edit button
        editBook(editButton)
    }
}
