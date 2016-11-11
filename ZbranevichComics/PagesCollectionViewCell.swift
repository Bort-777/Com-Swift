//
//  PagesCollectionViewCell.swift
//  ZbranevichComics
//
//  Created by user on 7/2/16.
//  Copyright © 2016 itransition. All rights reserved.
//

import UIKit

class PagesCollectionViewCell: UICollectionViewCell
{
    
    // MARK: - data functions
    
    @IBOutlet weak var imageView: UIImageView!
    
    var currPage: Page? {
        didSet {
            imageView.image = loadImage(currPage!.id)
        }
    }
    
    func setPage(_ page: Page) {
        self.currPage = page
    }
    
    func loadImage(_ id: Int) -> UIImage? {
        let imageName = String(id)
        let pathDocuments = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        let readPath = "\(pathDocuments)/\(imageName).jpg"
        let image    = UIImage(contentsOfFile: readPath)
        
        // Do whatever you want with the image
        return image
    }
    
    // MARK: - selection functions
    
    @IBOutlet weak var selector: UIButton!
    var isSelect: Bool = false {
        didSet {
            self.selector!.alpha = isSelect ? 1.0 : 0.5
            self.imageView!.alpha = isSelect ? 0.5 : 1.0
        }
    }
    @IBAction func selectIcon(_ sender: AnyObject) {
        isSelect = !isSelect
    }
    
    // MARK: - moving functions
    
    var isMoving: Bool = false {
        didSet {
            self.isHidden = isMoving
        }
    }
    
    var snapshot: UIView {
        let snapshot: UIView = self.snapshotView(afterScreenUpdates: true)!
        let layer: CALayer = snapshot.layer
        layer.masksToBounds = false
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -4.0, height: 0.0)
        
        return snapshot
    }
    
    // MARK: - shake functions
    
    // This function shake the collection view cells
    func shakeIcons() {
        let shakeAnim = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnim.duration = 0.05
        shakeAnim.repeatCount = 2
        shakeAnim.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/180
        let stopAngle = -startAngle
        shakeAnim.fromValue = NSNumber(value: startAngle as Float)
        shakeAnim.toValue = NSNumber(value: 3 * stopAngle as Float)
        shakeAnim.autoreverses = true
        shakeAnim.duration = 0.2
        shakeAnim.repeatCount = 10000
        shakeAnim.timeOffset = 290 * drand48()
        
        //Create layer, then add animation to the element's layer
        let layer: CALayer = self.layer
        layer.add(shakeAnim, forKey:"shaking")
    }
    
    // This function stop shaking the collection view cells
    func stopShakingIcons() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
    }
}
