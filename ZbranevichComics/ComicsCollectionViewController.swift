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
    
    // data of cokkection
    var books : Results<Book>!
    
    // MARK: - view functions

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
        readBooksAndUpdateUI()
    }
    
    func readBooksAndUpdateUI() {
        books = uiRealm.objects(Book).sorted(byProperty: "id")
        self.collectionView.reloadData()
    }
    
    // MARK: - picker view delegate and data source (books)

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ComicsCollectionViewCell
        
        cell.setComics(books[indexPath.row])
        cell.deleteIcon.isHidden = editModeEnabled ? false : true
        cell.titleLabel.isEnabled = editModeEnabled ? true : false
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if !editModeEnabled {
            self.performSegue(withIdentifier: "showPages", sender: self)
        }
    }
    
    // MARK: - segue delegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showPages" {
            let indexPaths = self.collectionView!.indexPathsForSelectedItems!
            let indexPath = indexPaths[0] as IndexPath
            let vc = segue.destination as! PagesCollectionViewController
            
            vc.currentBook = books[indexPath.row]
        }
    }
    
    // MARK: - edit books functions
    
    @IBAction func addBook(_ sender: UIBarButtonItem) {
        let saveString = NSLocalizedString("SAVE", comment: "save buttom")
        let cancelString = NSLocalizedString("CANCEL", comment: "cancel buttom")
        let titleString = NSLocalizedString("NEWCOMICS", comment: "newcomics text")
        let messageString = NSLocalizedString("NAMETHISCOMICS", comment: "newcomics text")
        let fieldString = NSLocalizedString("TITLE", comment: "title text")
        
        let alertController = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: saveString, style: .default) { (_) in
            if let field = alertController.textFields!.first {
                // store your data
                let newComics = Book()
                
                newComics.id = Int(arc4random_uniform(600)+1)
                newComics.name = field.text!
                
                // realm transaction
                try! uiRealm.write { () -> Void in
                    uiRealm.add([newComics], update: true)
                }
                
                self.readBooksAndUpdateUI()
                
            } else {
                // user did not fill field
            }
        }
        let cancelAction = UIAlertAction(title: cancelString, style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = fieldString
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.setNeedsLayout()
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editBook(_ sender: UIBarButtonItem) {
        editModeEnabled = !editModeEnabled
        
        editButton.title = editModeEnabled ? NSLocalizedString("DONE", comment: "done buttom") : NSLocalizedString("EDIT", comment: "edit buttom")
        editButton.style = editModeEnabled ? .done : .plain
        
        for item in self.collectionView!.visibleCells as! [ComicsCollectionViewCell] {
            item.deleteIcon.isHidden = editModeEnabled ? false : true
            item.titleLabel.isEnabled = editModeEnabled ? true : false
        }
    }
    
    @IBAction func deletePage(_ sender: UIButton) {
        let point : CGPoint = sender.convert(CGPoint.zero, to:collectionView)
        let indexPath = collectionView!.indexPathForItem(at: point)
        let cell = collectionView!.cellForItem(at: indexPath!) as! ComicsCollectionViewCell
        
        // realm transaction
        try! uiRealm.write({ () -> Void in
            uiRealm.delete(cell.getComics())
        })
        
        collectionView.deleteItems(at: [indexPath!])
    }
}
