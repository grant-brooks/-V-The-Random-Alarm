//
//  Black-Rounded-Button.swift
//
//
//  Created by Grant Goodman on 13/07/15.
//  Copyright © NEOTechnica Corporation. All rights reserved.
//


import UIKit

class BRB: UIButton
{
    var linkString: String? = ""
    
    class func buttonWithType(buttonType: UIButtonType?) -> AnyObject
    {
        let button: BRB = buttonWithType(buttonType) as! BRB
        button.postButtonWithTypeInit()
        
        return button
    }
    
    func postButtonWithTypeInit()
    {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesBegan(touches, withEvent: event)
        
        self.titleLabel?.textColor = UIColor.whiteColor()
        
        UIView.animateWithDuration(0.2, animations: {
            
            self.highlighted = true
            
            self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            
            let titleLabelString: String! = self.titleLabel?.text!
            
            if titleLabelString.noWhiteSpaceLowerCaseString == "cancel"
            {
                self.backgroundColor = UIColor.redColor()
                self.layer.borderColor = UIColor.redColor().CGColor
            }
            else
            {
                self.backgroundColor = UIColor.blackColor()
                self.layer.borderColor = UIColor.blackColor().CGColor
            }
            
        })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        UIView.animateWithDuration(0.2, animations: {
            
            self.highlighted = false
            self.backgroundColor = UIColor.clearColor()
            
            self.titleLabel?.textColor = UIColor.whiteColor()
            
            let titleLabelString: String! = self.titleLabel?.text!
            
            if titleLabelString.noWhiteSpaceLowerCaseString == "cancel"
            {
                self.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            }
            else
            {
                self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            }
        })
        
        if !(linkString != nil)
        {
            
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        super.touchesMoved(touches, withEvent: event)
        
        UIView.animateWithDuration(0.2, animations: {
            
            if #available(iOS 9.0, *)
            {
                self.viewForFirstBaselineLayout.alpha = 1
            }
            else
            {
                print("We're not able to display this alpha on versions <iOS 9.0.")
            }
            
            let titleLabelString: String! = self.titleLabel?.text!
            
            if titleLabelString.noWhiteSpaceLowerCaseString == "cancel"
            {
                self.backgroundColor = UIColor.redColor()
            }
            else
            {
                self.backgroundColor = UIColor.blackColor()
            }
            
            self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        })
    }
}


