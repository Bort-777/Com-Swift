//
//  ViewController.swift
//  SwiftCoreImageFilter
//
//  Created by Prashant on 16/11/15.
//  Copyright © 2015 PrashantKumar Mangukiya. All rights reserved.
//

import UIKit
import MobileCoreServices


class ChouseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    // Outlet & action - camera button
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBAction func cancelButtonAction(sender: AnyObject) {
        // show action shee to choose image source.
        self.showImageSourceActionSheet()
    }
    
    
    // Outlet & action - save button
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBAction func saveButtonAction(sender: UIBarButtonItem) {
        // save image to photo gallery
        self.saveImageToPhotoGallery()
    }
    
    
    // Outlet - image preview
    @IBOutlet var previewImageView: UIImageView!
    
    
    // Selected image
    var selctedImage: UIImage!
    
    
    // filter Title and Name list
    var filterTitleList: [String]!
    var filterNameList: [String]!
    
    
    // filter selection picker
    @IBOutlet var filterCollection: UICollectionView!
    
    
    
    
    // MARK: - view functions
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set filter title list array.
        self.filterTitleList = ["(( Choose Filter ))" ,"PhotoEffectChrome", "PhotoEffectFade", "PhotoEffectInstant", "PhotoEffectMono", "PhotoEffectNoir", "PhotoEffectProcess", "PhotoEffectTonal", "PhotoEffectTransfer"]
        
        // set filter name list array.
        self.filterNameList = ["No Filter" ,"CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer"]
        
        // set delegate for filter picker
        self.filterCollection.delegate = self
        self.filterCollection.dataSource = self
        
        // disable filter pickerView
        self.filterCollection.userInteractionEnabled = true
        
        // show message label

        
        // disable save button
        self.saveButton.enabled = false
        
        previewImageView.image = selctedImage
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: image picker delegate function
    
    // set selected image in preview
        
    // Close image picker
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // dismiss image picker controller
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    // MARK: - picker view delegate and data source (to choose filter name)
    
    // how many component (i.e. column) to be displayed within picker view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.filterTitleList.count
    }
    
    // title/content for row in given component
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.blueColor()
        let tmp = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width))
        //tmp.image = self.applyFilter(selectedFilterIndex: indexPath.row)
        tmp.image = selctedImage

        cell.addSubview(tmp)

        return cell
    }
    

    
    // called when row selected from any component within picker view
        func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
        {
        
        // disable save button if filter not selected.
        // enable save button if filter selected.
        if indexPath.row == 0 {
            self.saveButton.enabled = false
        }else{
            self.saveButton.enabled = true
        }
        
        // call funtion to apply the selected filter
        self.previewImageView.image = self.applyFilter(selectedFilterIndex: indexPath.row)
    }
    
    
    
    
    // MARK: - Utility functions {
    
    // Show action sheet for image source selection
    private func showImageSourceActionSheet() {
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    // apply filter to current image
    private func applyFilter(selectedFilterIndex filterIndex: Int) -> UIImage {
        
        //print("Filter - \(self.filterNameList[filterIndex)")
        
        /* filter name
         0 - NO Filter,
         1 - PhotoEffectChrome, 2 - PhotoEffectFade, 3 - PhotoEffectInstant, 4 - PhotoEffectMono,
         5 - PhotoEffectNoir, 6 - PhotoEffectProcess, 7 - PhotoEffectTonal, 8 - PhotoEffectTransfer
         */
        
        // if No filter selected then apply default image and return.
        if filterIndex == 0 {
            // set image selected image
            return self.selctedImage
        }
        
        
        // Create and apply filter
        // 1 - create source image
        let sourceImage = CIImage(image: self.selctedImage)
        
        // 2 - create filter using name
        let myFilter = CIFilter(name: self.filterNameList[filterIndex])
        myFilter?.setDefaults()
        
        // 3 - set source image
        myFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - create core image context
        let context = CIContext(options: nil)
        
        // 5 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage(myFilter!.outputImage!, fromRect: myFilter!.outputImage!.extent)
        
        // 6 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(CGImage: outputCGImage)
        
        // 7 - set filtered image to preview
        return filteredImage
    }
    
    
    // save imaage to photo gallery
    private func saveImageToPhotoGallery(){
        // Save image
        let baskViewController = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! ImageViewController
        baskViewController.callbackImage(previewImageView.image!)
        navigationController?.popViewControllerAnimated(true)

    }
    
    private func saveCallbackVideo(URL: NSURL){
        let baskViewController = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! ImageViewController
        baskViewController.callbackVideo(URL)
        navigationController?.popViewControllerAnimated(true)

    }
    
    
    // show message after image saved to photo gallery.
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        
        // show success or error message.
        if error == nil {
            self.showAlertMessage(alertTitle: "Success", alertMessage: "Image Saved To Photo Gallery")
        } else {
            self.showAlertMessage(alertTitle: "Error!", alertMessage: (error?.localizedDescription)! )
        }
        
    }
    
    
    // Show alert message with OK button
    func showAlertMessage(alertTitle alertTitle: String, alertMessage: String) {
        
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlertVC.addAction(okAction)
        
        self.presentViewController(myAlertVC, animated: true, completion: nil)
    }
    
    
}

