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
}

import UIKit
import MobileCoreServices
import UIKit
import AVFoundation

class TemplateViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UICollectionViewDataSource, UICollectionViewDelegate
{
    
    //MARK: - Other
    
    var load = false
    var imageSet: [[String: AnyObject]] = []
    var collectionItems: [[String: AnyObject]]? = nil
    var media = [NSURL]()

    var templateContainer: UIView!
    @IBOutlet weak var cloudCollection: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var mainView: UIView!
    var templateMode = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        loadJSONTemplates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.cloudCollection.delegate = self
        self.cloudCollection.dataSource = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "chouseImage"
        {
            let vc = segue.destination as! FiltersViewController
            vc.selctedImage = curreImage
        }
    }
    
    func createTemplateView() {
        let width = mainView.bounds.width
        let height = width
        
        templateContainer = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mainView.addSubview(templateContainer)
        templateContainer.addSubview(UIView())//?????????????????
    }
    
    func loadJSONTemplates() {
        let url = Bundle.main.url(forResource: "Template", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        do {
            let object = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                guard
                    let templates = dictionary["templates"] as? [[String: AnyObject]] else { print("err");return }
                self.collectionItems = templates
            }
        } catch {
            // Handle Error
        }
    }
    
    // MARK: collection view delegate function
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return collectionItems!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for aa in cell.subviews {
            aa.removeFromSuperview()
        }
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width))
        let imageName = collectionItems![indexPath.row]["name"] as? String
            
        iv.image = UIImage(named: imageName!)
        cell.addSubview(iv)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if templateMode {
            // set template property
            let template = collectionItems![indexPath.row]["struct"]
            
            self.imageSet = template as! [[String : AnyObject]]
            imagePicker.delegate = self
            
            // creator
            createTemplateView()
            
            for viewPart in imageSet {
                createScrollView(viewPart)
            }
            collectionView.reloadData()

            templateMode = !templateMode
            saveButton.isEnabled = true
            loadJSONCloud()
        }
        else {
            // set cloud property
            let dataFrame =  collectionItems![indexPath.row]["frame"]
            let newCloud = Cloud(frame: CGRect(x: dataFrame!["x"] as! CGFloat,
                y: dataFrame!["y"] as! CGFloat,
                width: dataFrame!["width"] as! CGFloat,
                height: dataFrame!["height"] as! CGFloat
                ))
            newCloud.imageName = collectionItems![indexPath.row]["name"] as? String
            templateContainer.addSubview(newCloud)

            
            // add text if need
            if let textData = collectionItems![indexPath.row]["text"] as? [String : AnyObject] {
                newCloud.imageText = textData
            }
        
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TemplateViewController.panGestureDetected(_:)))
            panGestureRecognizer.minimumNumberOfTouches = 1
            newCloud.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    // load json for cloud image
    func loadJSONCloud() {
        let url = Bundle.main.url(forResource: "Sticker", withExtension: "json")
        let data = try? Data(contentsOf: url!)
        do {
            let object = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            if let dictionary = object as? [String: AnyObject] {
                guard
                    let templates = dictionary["clouds"] as? [[String: AnyObject]] else { print("err");return }
                self.collectionItems = templates
            }
        } catch {
            // Handle Error
        }
    }
    
    // cloud delegate func
    func panGestureDetected(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.templateContainer)
        
        let newPoint = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        if self.templateContainer.point(inside: newPoint, with: nil) {
            sender.view!.center = newPoint
        }
        else {
            sender.view?.removeFromSuperview()
        }
        
        sender.setTranslation(CGPoint.zero, in: self.templateContainer)
    }
    
    //MARK: - create template
    
    func createScrollView(_ dataOfView: [String: AnyObject]) {
        // get data from json
        guard
        let dataX = dataOfView["x"] as? CGFloat,
        let dataY = dataOfView["y"] as? CGFloat,
        let dataWidth = dataOfView["width"] as? CGFloat,
        let dataHeight = dataOfView["heigth"] as? CGFloat else { return }
        
        // set scroll frame property
        let x = mainView.bounds.width * dataX
        let y = mainView.bounds.width * dataY
        let width = mainView.bounds.width * dataWidth
        let height = mainView.bounds.width * dataHeight
        let imageView = UIImageView()
        let scrollView = UIScrollView(frame: CGRect(x: x, y: y, width: width, height: height))
        let image = UIImage(named: "background")!
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(TemplateViewController.imageTapped(_:) ))
        
        scrollView.delegate = self
        scrollView.layer.borderWidth = 1
        scrollView.addSubview(imageView)

        tapGestureRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        // insert template in view
        templateContainer.addSubview(scrollView)
        
        // insert image in template
        insertImage(scrollView , image: image)
    }
    
    
    // MARK: scroll zoom delegate function
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first! as UIView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents(scrollView, imageView: scrollView.subviews.first as! UIImageView)
    }
    
    func centerScrollViewContents(_ scrollView: UIScrollView, imageView: UIView){
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
    
    // MARK: - insert in scroll functions
    
    func insertImage(_ scrollView: UIScrollView, image: UIImage)
    {
        
        let imageView = scrollView.subviews.first as! UIImageView
        let scrollViewFrame = scrollView.frame
        
        scrollView.contentSize = image.size

        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        
        // set imageView property
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        imageView.contentMode = UIViewContentMode.center
        imageView.isUserInteractionEnabled = true
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        
        // set scroll property
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1
        scrollView.zoomScale = 1
        
        centerScrollViewContents(scrollView, imageView: imageView)
        
        // tag scroll
        if scrollView.tag == 0 {
            media.append(NSURL())
            scrollView.tag = media.count
        }
        

    }
    
    func insertVideo(_ scrollView: UIScrollView, videoURL: URL)
    {
        // create screenshoot
        let imageView = scrollView.subviews.first as! UIImageView
        var uiImage = UIImage()
        do {
            let asset = AVURLAsset(url: videoURL, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            uiImage = UIImage(cgImage: cgImage)
            // lay out this image view, or if it already exists, set its image property to uiImage
        } catch let error as NSError {
            print("Error generating thumbnail: \(error)")
        }
        
        // set imageView property
        imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = uiImage
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        
        // tag scroll
        media[scrollView.tag - 1] = videoURL as NSURL
    }
    
    //MARK: - Tapped functions
    
    func imageTapped(_ img: UITapGestureRecognizer)
    {
        let alertController = UIAlertController(title: NSLocalizedString("SETMEDIA", comment: "set media"), message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "set media"), style: .cancel) { (action) in }
        let photoAction = UIAlertAction(title: NSLocalizedString("LIBRARY", comment: "set media"), style: .default) { (action) in
            self.currPicker = (img.view as! UIImageView).superview as! UIScrollView
            self.showPhotoGallery()
        }

        alertController.addAction(photoAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Show photo gallery to choose image
    fileprivate func showPhotoGallery() -> Void {
        
         // show picker to select image form gallery
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            
            // create image picker
            let imagePicker = UIImagePickerController()
            
            // set image picker property
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.allowsEditing = false
            
            
            // show image picker
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
 
    // MARK: - UIImagePickerControllerDelegate Method
    
    var currPicker = UIScrollView()
    fileprivate var curreImage = UIImage()
    let imagePicker = UIImagePickerController()
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // dismiss image picker controller
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        dismiss(animated: true) {
            // 3
            if mediaType == kUTTypeMovie {
                let contentURL = info[UIImagePickerControllerMediaURL] as! URL
                self.callbackVideo(contentURL)
                
            }
            else {
                // if image selected the set in preview.
                if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    self.curreImage = newImage
                    self.performSegue(withIdentifier: "chouseImage", sender: self)
                }
            }
        }
    }
    
    func callbackImage(_ img: UIImage) {
        self.insertImage(currPicker, image: img)
    }
    
    func callbackVideo(_ URL: Foundation.URL) {
        self.insertVideo(self.currPicker, videoURL: URL)
        
    }

    
    //MARK: - Save page to Realm
    
    var page = Page()
    var comics = Book()
    
    @IBAction func savePage(_ sender: AnyObject) {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
        
            // Save image:
            let pathDocuments = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
            let pathImage = "\(pathDocuments)/\(page.id).jpg"
        
            templateContainer.saveImageFromView(path: pathImage)
            page.URL = pathImage

            // Save video:
            for subScrolls in templateContainer.subviews
            {
                if let scroll = subScrolls as? UIScrollView
                {
                    // find video in all scroll
                    if media[scroll.tag - 1].absoluteString != ""
                    {
                        let video = Media()
                        video.setFrame(scroll.frame)
                        video.setLocalURL(saveLocalVideo(media[scroll.tag - 1] as URL))
                        page.data.append(video)
                    }
                    else {
                        
                    }
                }
            }
            comics.page.append(page)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // moveing video to local folder
    func saveLocalVideo (_ localPatch: URL) -> Int {
        let videoID =  Int(arc4random_uniform(600)+1)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        let pathVideo = "\(pathDocuments)/\(videoID).MOV"
        let videoData = try? Data(contentsOf: localPatch)
        
        try? videoData?.write(to: URL(fileURLWithPath: pathVideo), options: [])
        print(pathVideo)
        return videoID
    }
}

extension UIView {
    func saveImageFromView(path:String) {
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        try? UIImageJPEGRepresentation(image!, 0.4)?.write(to: URL(fileURLWithPath: path), options: [.atomic])
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
    }}
