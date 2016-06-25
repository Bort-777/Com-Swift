//
//  CollectionViewCell.swift
//  UICollectionView Xcode 7
//
//  Created by PJ Vea on 7/1/15.
//  Copyright © 2015 Vea Software. All rights reserved.
//

import UIKit

class ComicsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numPagesLabel: UILabel!
    
    func setComics(comics: Book) {
        if let firstPage = comics.page.first
        {
            imageView.image = loadImage(firstPage.id)
        }
        else {
            imageView.image = UIImage(named: "pug")
        }
        titleLabel.text = comics.name
        numPagesLabel.text = "\(comics.page.count) page(s)"
    }
    
    func loadImage(id: Int) -> UIImage? {
        let nameImage = String(id)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let readPath = "\(pathDocuments)/\(nameImage).jpg"
        let image    = UIImage(contentsOfFile: readPath)
        // Do whatever you want with the image
        return image
    }
}
