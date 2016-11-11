//
//  ChouseViewController.swift
//  ZbranevichComics
//
//  Created by Prashant on 16/11/15.
//  Edited by Zbranevich on 25.06.16.
//
//  All rights reserved.
//

import UIKit
import MobileCoreServices


class FiltersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    // Outlet & action - cancel button
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBAction func cancelButtonAction(_ sender: AnyObject) {
        // show action shee to choose image source.
        self.showImageSourceActionSheet()
    }
    
    
    // Outlet & action - save button
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        // save image to photo gallery
        self.saveImageToPhotoGallery()
    }
    
    
    // Outlet - image preview
    @IBOutlet var previewImageView: UIImageView!
    
    
    // Selected image
    var selctedImage: UIImage!
    var imageSmall: UIImage!
    
    
    // filter Name list
    var filterNameList: [String]!
    
    
    // filter selection picker
    @IBOutlet var filterCollection: UICollectionView!
    
    
    // MARK: - view functions
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.navigationBar.barTintColor = UIColor.darkGray
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orange]
        
        // set filter name list array.
        self.filterNameList = loadJSON()
        
        // set delegate for filter picker
        self.filterCollection.delegate = self
        self.filterCollection.dataSource = self
        
        // disable filter pickerView
        self.filterCollection.isUserInteractionEnabled = true
        
        previewImageView.image = selctedImage
        
        //imageSmall = UIImage(data: UIImageJPEGRepresentation(selctedImage, 0.1)!);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadJSON() -> [String] {
        let url = Bundle.main.url(forResource: "Filters", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        do {
            let object = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                guard
                    let templates = dictionary["filterNameList"] as? [String] else { return [] }
                return templates
            }
        } catch {
            // Handle Error
        }
        return []
    }
    
    
    
    // MARK: image picker delegate function
    
    // set selected image in preview
        
    // Close image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // dismiss image picker controller
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - picker view delegate and data source (to choose filter name)
    
    // how many component (i.e. column) to be displayed within picker view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.filterNameList.count
    }
    
    // title/content for row in given component
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let tmp = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width))
        let filterName = self.filterNameList[indexPath.row]
        
        tmp.image = UIImage(named: filterName)
        cell.backgroundColor = UIColor.blue
        cell.addSubview(tmp)

        return cell
    }
    

    
    // called when row selected from any component within picker view
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
        {
        
        // call funtion to apply the selected filter
            self.previewImageView.image = self.applyFilter(selectedImage: self.selctedImage, selectedFilterIndex: indexPath.row)
    }
    
    
    
    
    // MARK: - Utility functions {
    
    // Show action sheet for image source selection
    fileprivate func showImageSourceActionSheet() {
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.titleTextAttributes =  nil
        navigationController?.popViewController(animated: true)
        
    }
    
    // apply filter to current image
    fileprivate func applyFilter(selectedImage image: UIImage,selectedFilterIndex filterIndex: Int) -> UIImage {
        
        
        // if No filter selected then apply default image and return.
        if filterIndex == 0 {
            // set image selected image
            return image
        }
        
        // Create and apply filter
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let myFilter = CIFilter(name: self.filterNameList[filterIndex])
        myFilter?.setDefaults()
        
        // 3 - set source image
        myFilter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - create core image context
        let context = CIContext(options: nil)
        
        // 5 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage(myFilter!.outputImage!, from: myFilter!.outputImage!.extent)
        
        // 6 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!)
        
        // 7 - set filtered image to preview
        return filteredImage
    }
    
    
    // save imaage to photo gallery
    fileprivate func saveImageToPhotoGallery(){
        // Save image
        navigationController?.navigationBar.barTintColor = nil
        navigationController?.navigationBar.titleTextAttributes =  nil
        let baskViewController = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! TemplateViewController
        baskViewController.callbackImage(previewImageView.image!)
        navigationController?.popViewController(animated: true)

    }
}
