//
//  ViewController.swift
//  UICollectionView Xcode 7
//
//  Created by PJ Vea on 7/1/15.
//  Copyright © 2015 Vea Software. All rights reserved.
//

import UIKit
import RealmSwift


class ComicsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var editModeEnabled = false
    var books : Results<Book>!
   
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
        readBooksAndUpdateUI()
    }
    
    func readBooksAndUpdateUI() {
        books = uiRealm.objects(Book).sorted("id")
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return books.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ComicsCollectionViewCell
        
        cell.setComics(books[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if (editModeEnabled == false) {
            self.performSegueWithIdentifier("showPages", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showPages"
        {
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            let vc = segue.destinationViewController as! PagesCollectionViewController
            vc.currentBook = books[indexPath.row]
            

        }
    }
    
    @IBAction func addBook(sender: AnyObject) {
        let alertController = UIAlertController(title: "New comics", message: "Name this comic", preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Save", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                let newComics = Book()
                
                newComics.id = Int(arc4random_uniform(600)+1)
                newComics.name = field.text!
                try! uiRealm.write { () -> Void in
                    uiRealm.add([newComics], update: true)
                }
                self.readBooksAndUpdateUI()
            } else {
                // user did not fill field
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Title"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.setNeedsLayout()
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editBook(sender: UIBarButtonItem) {
        if(editModeEnabled == false) {
            editButton.title = "Done"
            self.editButton.style = .Done
            editModeEnabled = true
            
            for item in self.collectionView!.visibleCells() as! [ComicsCollectionViewCell] {
                item.deleteIcon.hidden = false
                item.titleLabel.enabled = true
            }
        }
        else {
            editButton.title = "Edit"
            editButton.style = .Plain
            editModeEnabled = false
            
            for item in self.collectionView!.visibleCells() as! [ComicsCollectionViewCell] {
                item.deleteIcon.hidden = true
                item.titleLabel.enabled = false
                
            }

        }
    }
    
    @IBAction func deletePage(sender: UIButton) {
        let point : CGPoint = sender.convertPoint(CGPointZero, toView:collectionView)
        let indexPath = collectionView!.indexPathForItemAtPoint(point)
        let cell = collectionView!.cellForItemAtIndexPath(indexPath!) as! ComicsCollectionViewCell
        try! uiRealm.write({ () -> Void in
            uiRealm.delete(cell.currentBook!)
        })
        collectionView.deleteItemsAtIndexPaths([indexPath!])
    }

}

