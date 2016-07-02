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
    private var currentBook: Book? {
        didSet {
            // init data if view
            if let firstPage = currentBook!.page.first
            {
                imageView.image = loadImage(firstPage.id)
            }
            else {
                imageView.image = UIImage(named: "pug")
            }
            titleLabel.text = currentBook!.name
            numPagesLabel.text = "\(currentBook!.page.count) page(s)"
        }
    }

    // MARK: - data functions
    
    func setComics(comics: Book) {
        self.currentBook = comics
    }
    
    func getComics() -> Book {
        return self.currentBook!
    }
    
    private func loadImage(id: Int) -> UIImage? {
        let nameImage = String(id)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let readPath = "\(pathDocuments)/\(nameImage).jpg"
        let image    = UIImage(contentsOfFile: readPath)
        // Do whatever you want with the image
        return image
    }
    
    // MARK: - textField functions

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        // Realm transaction
        try! uiRealm.write({ () -> Void in
            self.currentBook!.name = textField.text!
        })
        return true
    }
}