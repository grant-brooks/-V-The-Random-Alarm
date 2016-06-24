//
//  Fade-From-Main-Segue.swift
//  ΛVΛ (Code Name Avalon)
//
//  Created by Grant Goodman on 21/06/16.
//  Copyright © 2016 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class FFM: UIStoryboardSegue
{
    override func perform()
    {
        let sourceController = sourceViewController as! MC
        let destinationController = destinationViewController
        
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        
        destinationController.view.alpha = 0.0
        
        keyWindow.insertSubview(destinationController.view, belowSubview: sourceController.view)
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            sourceController.totalEnclosingView.alpha = 0.0
            destinationController.view.alpha = 1.0
            
        }) { (finished) -> Void in
            
            self.showDestinationViewController(mustDismiss, completion: { () -> Void in
                
                mustDismiss = false
                sourceController.view.alpha = 1.0
            })
        }
    }
}
