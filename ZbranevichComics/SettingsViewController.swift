//
//  SettingsViewController.swift
//  ZbranevichComics
//
//  Created by user on 13.06.16.
//  Copyright © 2016 itransition. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var currentBook = Book()

    @IBOutlet weak var first: UIButton!
    @IBOutlet weak var sec: UIButton!
    @IBOutlet weak var three: UIButton!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let ivc = segue.destinationViewController as? ImageViewController  {
            
                let imageName = (sender as? UIButton)!.currentTitle
            let first = "First"
            let second = "Second"
            let three = "Three"
            
            ivc.comics = currentBook
            switch imageName {
            case first?:
                
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0,
                    width: 1.0,
                    heigth: 1.0,
                    vidoe: false
                    ))
                
            case second?:
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0,
                    width: 1.0,
                    heigth: 0.5,
                    vidoe: false
                    ))

                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0.5,
                    width: 1.0,
                    heigth: 0.5,
                    vidoe: false
                    ))

            case three?:
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0,
                    width: 0.5,
                    heigth: 0.5,
                    vidoe: false
                    ))
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0.5,
                    y: 0,
                    width: 0.5,
                    heigth: 0.5,
                    vidoe: false
                    
                    ))
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0.5,
                    width: 0.5,
                    heigth: 0.5,
                    vidoe: false
                    
                    ))
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0.5,
                    y: 0.5,
                    width: 0.5,
                    heigth: 0.5,
                    vidoe: false
                    ))
                default:
                   break
                
            }
        }
    }
   
}
