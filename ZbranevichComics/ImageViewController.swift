//
//  ImageViewController.swift
//  ZbranevichComics
//
//  Created by user on 13.06.16.
//  Copyright © 2016 itransition. All rights reserved.
//

struct MyFrame {
    var URLname = ""
    var x : CGFloat
    var y : CGFloat
    var width : CGFloat
    var heigth : CGFloat
    var vidoe = false
}



import UIKit
import MobileCoreServices
import UIKit
import AVFoundation

class ImageViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    //MARK: - Other
    
    var load = false
    var imageSet = [MyFrame]()
    var media = [String]()

    var templateContainer: UIView!
    
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if load == false {
            imagePicker.delegate = self
            
            createTemplateView()
            for viewPart in imageSet {
                createScrollView(viewPart)


            }
            load = true
        }
    }
    
    func createTemplateView() {
        let width = mainView.bounds.width
        let height = width
        templateContainer = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mainView.addSubview(templateContainer)
        templateContainer.addSubview(UIView())//?????????????????
    }
    
    
    //MARK: - TemplateControll
    
    func createScrollView(dataOfView: MyFrame) {
        let x = mainView.bounds.width * dataOfView.x
        let y = mainView.bounds.width * dataOfView.y
        let width = mainView.bounds.width * dataOfView.width
        let height = mainView.bounds.width * dataOfView.heigth
        
        let imageView = UIImageView()
        
        let scrollView = UIScrollView(frame: CGRect(x: x, y: y, width: width, height: height))
        
        scrollView.delegate = self
        scrollView.addSubview(imageView)

        
        let url = NSURL(string: dataOfView.URLname)
        var image = UIImage();
        if let imageData = NSData (contentsOfURL: url!) {
            image = UIImage(data: imageData)!
            //image = UIImage(named: "empty")!
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ImageViewController.imageTapped(_:) ))
        tapGestureRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        insertImage(scrollView , image: image)
        
        templateContainer.addSubview(scrollView)
        
        }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first! as UIView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents(scrollView, imageView: scrollView.subviews.first as! UIImageView)
    }
    
    func centerScrollViewContents(scrollView: UIScrollView, imageView: UIView){
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width{
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }else{
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }else{
            contentsFrame.origin.y = 0
        }

        imageView.frame = contentsFrame
        
    }
    
    func insertImage(scrollView: UIScrollView, image: UIImage)
    {
        
        let imageView = scrollView.subviews.first as! UIImageView
        imageView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        imageView.contentMode = UIViewContentMode.Center
        //scrollView.userInteractionEnabled = true
        imageView.userInteractionEnabled = true
        
        
        imageView.image = image
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        scrollView.contentSize = image.size
        
        
        
        
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        scrollView.contentSize = image.size
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = 1
        
        centerScrollViewContents(scrollView, imageView: imageView)
        
        if scrollView.tag == 0 {
            media.append("i")
            scrollView.tag = media.count
        }
        

    }
    
    func insertVideo(scrollView: UIScrollView, videoURL: NSURL)
    {
        let imageView = scrollView.subviews.first as! UIImageView
        var uiImage = UIImage()
        var error: NSError? = nil
        do {
            let asset = AVURLAsset(URL: videoURL, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            let cgImage = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil)
            uiImage = UIImage(CGImage: cgImage)
            // lay out this image view, or if it already exists, set its image property to uiImage
        } catch let error as NSError {
            print("Error generating thumbnail: \(error)")
        }
        
        
        imageView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        //scrollView.userInteractionEnabled = true
        imageView.userInteractionEnabled = true
        
        
        imageView.image = uiImage


        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        
        
        media[scrollView.tag - 1] = videoURL.absoluteString
        
        
}
    
    




    
// MARK: - UIImagePickerControllerDelegate Method
    
    var currPicker = UIScrollView()
    let imagePicker = UIImagePickerController()

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismissViewControllerAnimated(true) {
            // 3
            if mediaType == kUTTypeMovie {
                let contentURL = info[UIImagePickerControllerMediaURL] as! NSURL
                self.insertVideo(self.currPicker, videoURL: contentURL)
                
            }
            else {
                if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
                    self.insertImage(self.currPicker, image: pickedImage)
                }
            }
        }
    }
    
    func imageTapped(img: UITapGestureRecognizer)
    {
        let alertController = UIAlertController(title: "Set media", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        let photoAction = UIAlertAction(title: "Library", style: .Default) { (action) in
            self.currPicker = (img.view as! UIImageView).superview as! UIScrollView
            self.imagePicker.allowsEditing = false
            self.imagePicker.mediaTypes = ["public.image", "public.movie"]
            self.imagePicker.allowsEditing = true
            self.imagePicker.sourceType = .SavedPhotosAlbum

            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }

        alertController.addAction(photoAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

    
    //MARK: - Realm
    
    let page = Page()
    var comics = Book()
    
    @IBAction func savePage(sender: AnyObject) {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        if comics.id == 0 {
            comics.id = Int(arc4random_uniform(600)+1)
            comics.name = "tmp" + String(Int(arc4random_uniform(600)+1))
            try! uiRealm.write { () -> Void in
                uiRealm.add([comics], update: true)
            }
        }
        try! uiRealm.write {
            page.id = Int(arc4random_uniform(600)+1)
        
            let pathDocuments = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
            let pathImage = "\(pathDocuments)/\(page.id).jpg"
        
            templateContainer.saveImageFromView(path: pathImage)
            page.URL = pathImage

            for subScrolls in templateContainer.subviews
            {
                if let scroll = subScrolls as? UIScrollView
                {
                    if media[scroll.tag - 1] != "i"
                    {
                        print("video: ")
                        let video = Media()
                        video.setFrame(scroll.frame)
                        video.setLocalURL(media[scroll.tag - 1])
                        page.data.append(video)
                    }
                    else {
                        
                    }
                }
            }
        
        

            comics.page.append(page)
        
        }
        navigationController?.popToRootViewControllerAnimated(true)
    }
}

extension UIView {
    func saveImageFromView(path path:String) {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.mainScreen().scale)
        drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIImageJPEGRepresentation(image, 0.4)?.writeToFile(path, atomically: true)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
    }}