//
//  CollectionViewCell.swift
//  UICollectionView Xcode 7
//
//  Created by PJ Vea on 7/1/15.
//  Copyright © 2015 Vea Software. All rights reserved.
//

import UIKit

class ComicsCollectionViewCell: UICollectionViewCell, UITextFieldDelegate
{
    // outlet of cell
    @IBOutlet weak var deleteIcon: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var numPagesLabel: UILabel!
    
    // data
    fileprivate var currentBook: Book? {
        didSet {
            // init data if view
            if let firstPage = currentBook!.page.first
            {
                imageView.image = loadImage(firstPage.id)
            }
            else {
                imageView.image = UIImage(named: "folder-icon")
            }
            titleLabel.text = currentBook!.name
            numPagesLabel.text = "\(currentBook!.page.count) " + NSLocalizedString("PAGE", comment: "page buttom")
        }
    }

    // MARK: - data functions
    
    func setComics(_ comics: Book) {
        self.currentBook = comics
    }
    
    func getComics() -> Book {
        return self.currentBook!
    }
    
    fileprivate func loadImage(_ id: Int) -> UIImage? {
        let nameImage = String(id)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        let readPath = "\(pathDocuments)/\(nameImage).jpg"
        let image    = UIImage(contentsOfFile: readPath)
        // Do whatever you want with the image
        return image
    }
    
    // MARK: - textField functions

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Realm transaction
        try! uiRealm.write({ () -> Void in
            self.currentBook!.name = textField.text!
        })
        return true
    }
}
