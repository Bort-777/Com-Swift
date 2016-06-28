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

    
    override init (frame : CGRect) {
        super.init(frame : frame)

        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.width))
        imageView.image = UIImage(named: "pug")
        self.addSubview(imageView)
        
        textF = UITextField(frame: CGRect(x: 12, y: 8, width: self.frame.size.width-90, height: 50))
        textF.text = "Conn!"
        textF.textColor = UIColor.whiteColor()
        textF.font = UIFont.systemFontOfSize(14)
        self.addSubview(textF)


    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
