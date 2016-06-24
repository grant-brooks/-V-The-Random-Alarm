//
//  UIStoryboardSegue+Extensions.swift
//  CustomSegue
//
//  Created by Mariam AlJamea on 4/21/15.
//  Copyright (c) 2015 MARIAM ALJAMEA. All rights reserved.
//

import UIKit

public extension UIStoryboardSegue {
    
    typealias closureTypeName = () -> Void
    
    public func destinationViewSnapshot() -> UIView {
        
        let destinationViewController = self.destinationViewController 
        
        UIGraphicsBeginImageContextWithOptions(destinationViewController.view.bounds.size, false, 0)
        
        destinationViewController.view.drawViewHierarchyInRect(destinationViewController.view.bounds, afterScreenUpdates: true)
        
        let destinationViewImage =  UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return UIImageView(image: destinationViewImage)
    }
    
    public func sourceViewSnapshot() -> UIView {
        
        let sourceViewController = self.sourceViewController 
        
        return sourceViewController.view.snapshotViewAfterScreenUpdates(false)
    }
    
    public func maskLeftSideOfView(view: UIView) {
        
        let rect = CGRectMake(view.bounds.size.width/2, view.bounds.origin.y,
            view.bounds.size.width/2, view.bounds.size.height)
        
        self.maskView(view, rec: rect)
    }
    
    public func maskRightSideOfView(view: UIView) {
        
        let rect = CGRectMake(view.bounds.origin.x, view.bounds.origin.y,
            view.bounds.size.width/2, view.bounds.size.height)
        
        self.maskView(view, rec: rect)
    }
    
    public func maskView(view: UIView, rec:CGRect) {
        
        let mask = CAShapeLayer()
        let path = CGPathCreateWithRect(rec, nil)
        mask.path = path
        
        view.layer.mask = mask
        
    }
    
    public func addRightShadowToView(view: UIView, shadowWidth: CGFloat) -> CALayer {
        
        return self.addShadowToView(view, shadowSize: CGSizeMake(shadowWidth, 0) ,shadowWidth:shadowWidth)
    }
    
    public func addLeftShadowToView(view: UIView, shadowWidth: CGFloat) -> CALayer {
        
        return self.addShadowToView(view, shadowSize: CGSizeMake(-shadowWidth, 0) ,shadowWidth:shadowWidth)
    }
    
    public func addShadowToView(view: UIView, shadowSize: CGSize, shadowWidth: CGFloat) -> CALayer {
        
        let containerLayer = CALayer()
        
        containerLayer.shadowColor = UIColor.blackColor().CGColor
        containerLayer.shadowRadius = 2*shadowWidth
        containerLayer.shadowOffset = shadowSize
        containerLayer.shadowOpacity = 0.5
        
        containerLayer.addSublayer(view.layer)
        
        return containerLayer
    }
    
    public func setAnchorPoint(anchorPoint: CGPoint, view: UIView) {
        
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
            view.bounds.size.height * anchorPoint.y)
        
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
            view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    public func showDestinationViewController(dismiss: Bool, completion: closureTypeName) {
        
        if dismiss {
            
            self.destinationViewController.dismissViewControllerAnimated(false, completion: completion)
            
        } else {
            
            self.sourceViewController.presentViewController(self.destinationViewController , animated: false, completion: completion)
            
        }
    }
}
