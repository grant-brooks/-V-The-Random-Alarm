//
//  Outlined-Label.swift
//  ΛVΛ (Code Name Avalon)
//
//  Created by Grant Goodman on 01/06/16.
//  Copyright © 2016 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class OL: UILabel
{
    var outlineWidth: CGFloat = 1
    var outlineColor: UIColor = UIColor.whiteColor()
    
    override func drawTextInRect(rect: CGRect)
    {
        let strokeTextAttributes = [NSStrokeColorAttributeName : outlineColor, NSStrokeWidthAttributeName : -1 * outlineWidth,]
        
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawTextInRect(rect)
    }
}
