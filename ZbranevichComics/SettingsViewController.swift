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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTemplate()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let ivc = segue.destinationViewController as? ImageViewController  {
            
                let imageName = (sender as? UIButton)!.currentTitle
            let first = "First"
            let second = "Second"
            let three = "Three"
            
            ivc.comics = currentBook
            switch imageName {
            case first?:
                title = "sdfds"
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0,
                    width: 1.0,
                    heigth: 1.0
                    ))
                
            case second?:
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0,
                    width: 1.0,
                    heigth: 0.5
                    ))

                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0.5,
                    width: 1.0,
                    heigth: 0.5
                    ))

            case three?:
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0,
                    width: 0.5,
                    heigth: 0.5
                    ))
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0.5,
                    y: 0,
                    width: 0.5,
                    heigth: 0.5
                    
                    ))
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0,
                    y: 0.5,
                    width: 0.5,
                    heigth: 0.5
                    
                    ))
                ivc.imageSet.append(MyFrame(
                    URLname: "https://yastatic.net/disk/_/ZQnEdptjmA6XjGYMvsuKMV9E_yI.jpg",
                    x: 0.5,
                    y: 0.5,
                    width: 0.5,
                    heigth: 0.5
                    ))
                default:
                   break
                
            }
        }
    }
    
    func loadTemplate () {
        let url = NSBundle.mainBundle().URLForResource("Template", withExtension: "json")
        let data = NSData(contentsOfURL: url!)
        do {
            let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            if let dictionary = object as? [String: AnyObject] {
                readJSONObject(dictionary)
            }
        } catch {
            // Handle Error
        }
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        guard let title = object["dataTitle"] as? String,
            let version = object["swiftVersion"] as? Float,
            let users = object["template"] as? [[String: AnyObject]] else { return }
        _ = "Swift \(version) " + title
        
        for user in users {
            print(title)
            guard let URLname = user["URLname"] as? String,
                let x = user["x"] as? CGFloat,
            let y = user["y"] as? CGFloat,
            let width = user["width"] as? CGFloat,
            let heigth = user["heigth"] as? CGFloat else { break }
            var Frame = MyFrame(
                URLname: URLname,
                x: x,
                y: y,
                width: width,
                heigth: heigth
                )
            print(Frame)

            
        }
    }
}
