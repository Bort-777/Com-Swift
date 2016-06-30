//
//  Cloud.swift
//  ZbranevichComics
//
//  Created by user on 6/26/16.
//  Copyright © 2016 itransition. All rights reserved.
//

import UIKit

class Cloud: UIView, UITextFieldDelegate {


    var textF: UITextField!
    var imageView: UIImageView!
    var data: [String: AnyObject]!
    
    var imageName: String? {
        didSet{
            imageView.image = UIImage(named: imageName!)
        }
    }
    
    var imageText: [String: AnyObject]? {
        didSet{
            textF = UITextField(frame: CGRect(
                x: imageText!["x"] as! CGFloat,
                y: imageText!["y"] as! CGFloat,
                width: self.frame.size.width,
                height: imageText!["height"] as! CGFloat
                ))
            textF.text = imageText!["text"] as? String
            textF.textColor = UIColor.blackColor()
            textF.font = UIFont.systemFontOfSize(imageText!["height"] as! CGFloat)
            textF.delegate = self
            self.addSubview(textF)

        }
    }
    

    
    override init (frame : CGRect) {
        super.init(frame : frame)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width))

        self.addSubview(imageView)
        
        

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {

        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
