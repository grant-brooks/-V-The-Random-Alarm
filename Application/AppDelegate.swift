//
//  AppDelegate.swift
//  ΛVΛ (Code Name Avalon)
//
//  Created by Grant Goodman on 30/05/16.
//  Copyright © 2016 NEOTechnica Corporation. All rights reserved.
//

import UIKit

var mustDismiss = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    //--------------------------------------------------//
    
    //Non-Interface Builder Elements
    
    //Integer Values
    var amountOfNotificationsScheduled: Int? = 0
    var buildNumber:                    Int?
    var bugFixReleaseNumber:            Int?
    var minorReleaseNumber:             Int?
    
    //String Values
    var preReleaseNotifierString: String!
    
    //Other Items
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var dateToFire: NSDate?
    var notificationTimer: NSTimer!
    var uploadedScreenShot: Bool! = false
    var window: UIWindow?
    
    var userTryingToCancelAlarm: Bool! = false
    var notificationTimerShouldBeValid: Bool! = false
    var comeBack: Bool! = false
    var didResign: Bool! = true
    
    //--------------------------------------------------//
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //Set the build number as an integer.
        //buildNumber = Int(NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String)! + 1
        buildNumber = Int(NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String)!
        
        //Set the minor release number.
        minorReleaseNumber = buildNumber! / 150
        
        if minorReleaseNumber == nil
        {
            minorReleaseNumber = 0
        }
        
        //Set the bug fix release number.
        bugFixReleaseNumber = buildNumber! / 50
        
        if bugFixReleaseNumber == nil
        {
            bugFixReleaseNumber = 0
        }
        
        //Determine the pre-release notifier string.
        let preReleaseNotifierStringArray = ["For testing purposes only.", "Evaluation version.", "Redistribution is prohibited.", "All features subject to change.", "For use by authorised parties only.", "Contents strictly confidential.", "This is pre-release software.", "Not for public use."]
        
        let randomIntegerValue = randomInteger(0, maximumValue: preReleaseNotifierStringArray.count - 1)
        preReleaseNotifierString = preReleaseNotifierStringArray[randomIntegerValue]
        
        //Determine the height of the screen, and set the preferred storyboard file accordingly.
        if screenSize.height == 667
        {
            let storyboard = UIStoryboard(name: "4.7 Inch", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else if screenSize.height == 568
        {
            let storyboard = UIStoryboard(name: "4 Inch", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        else if screenSize.height == 480
        {
            let storyboard = UIStoryboard(name: "3.5 Inch", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("MC")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject]
        {
            let aps = notification["aps"] as! [String: AnyObject]
            print(aps)

            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
    
        return true
    }

    func applicationWillResignActive(application: UIApplication)
    {
        print("RESIGNED")
        
        if notificationTimerShouldBeValid == true
        {
            notificationTimer = NSTimer.scheduledTimerWithTimeInterval(0, target: MC(), selector: #selector(MC.registerFirstNotification), userInfo: nil, repeats: true)
        }
        
        if (UIApplication.topViewController() as! MC).textForGreetingLabel == "Alarm is ringing"
        {
            notificationTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: MC(), selector: #selector(MC.registerFirstNotification), userInfo: nil, repeats: true)
            comeBack = true
        }
        
        didResign = true
    }

    func applicationWillEnterBackground(application: UIApplication)
    {
        print("ENTERED BACKGROUND")
    }

    func applicationWillEnterForeground(application: UIApplication)
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        print("ENTERED FOREGROUND")
        
        if NSUserDefaults.standardUserDefaults().objectForKey("dateToFire") != nil
        {
            if (shortTimeStringFromDate(NSDate()) == (shortTimeStringFromDate(NSUserDefaults.standardUserDefaults().objectForKey("dateToFire") as! NSDate)))
            {
                (UIApplication.topViewController() as! MC).greetingLabel.text = "Alarm is ringing"
                (UIApplication.topViewController() as! MC).hiddenGreetingLabel.text = "Alarm is ringing"
            }
        }
    }
    
    func shortTimeStringFromDate(dateToConvert: NSDate!) -> String
    {
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .ShortStyle
        
        let timeString = timeFormatter.stringFromDate(dateToConvert)
        
        return timeString
    }

    func applicationDidBecomeActive(application: UIApplication)
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        print("BECAME ACTIVE")
    }

    func applicationWillTerminate(application: UIApplication)
    {
        print("ABOUT TO TERMINATE")
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings)
    {
        if notificationSettings.types != .None
        {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
    {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length
        {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //print("Device Token:", tokenString)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
    {
        //print("Failed to Register:", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        print("Received Remote Notification in Foreground.")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        print("Received Local Notification in Foreground.")
    }
}

///Function that sets the background image on a UIView.
func setBackgroundImageForView(chosenView: UIView!, backgroundImageName: String!)
{
    UIGraphicsBeginImageContext(chosenView.frame.size)
    
    UIImage(named: backgroundImageName)?.drawInRect(chosenView.bounds)
    
    let imageToSet: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    chosenView.backgroundColor = UIColor(patternImage: imageToSet)
}

///Function that rounds the vertical corners on any desired object. Accepts 'left' and 'right' as strings.
func roundVerticalCornersOnObject(objectToRound: AnyObject!, sideToRound: String!)
{
    var topCorner: UIRectCorner!
    var bottomCorner: UIRectCorner!
    
    if sideToRound.noWhiteSpaceLowerCaseString == "left"
    {
        topCorner = UIRectCorner.TopLeft
        bottomCorner = UIRectCorner.BottomLeft
    }
    else if sideToRound.noWhiteSpaceLowerCaseString == "right"
    {
        topCorner = UIRectCorner.TopRight
        bottomCorner = UIRectCorner.BottomRight
    }
    
    let maskPath: UIBezierPath = UIBezierPath(roundedRect: objectToRound!.bounds,
                                              byRoundingCorners: [topCorner, bottomCorner],
                                              cornerRadii: CGSize(width: 5.0, height: 5.0))
    
    let maskLayer: CAShapeLayer = CAShapeLayer()
    
    maskLayer.frame = objectToRound!.bounds
    maskLayer.path = maskPath.CGPath
    
    objectToRound!.layer.mask = maskLayer
    objectToRound!.layer.masksToBounds = false
    objectToRound!.view?!.clipsToBounds = true
}

///Function that rounds the horizontal corners on any desired object. Accepts 'top' and 'bottom' as strings.
func roundHorizontalCornersOnObject(objectToRound: AnyObject!, sideToRound: String!)
{
    var leftCorner: UIRectCorner!
    var rightCorner: UIRectCorner!
    
    if sideToRound.noWhiteSpaceLowerCaseString == "top"
    {
        leftCorner = UIRectCorner.TopLeft
        rightCorner = UIRectCorner.TopRight
    }
    else if sideToRound.noWhiteSpaceLowerCaseString == "bottom"
    {
        leftCorner = UIRectCorner.BottomLeft
        rightCorner = UIRectCorner.BottomRight
    }
    
    let maskPath: UIBezierPath = UIBezierPath(roundedRect: objectToRound!.bounds,
                                              byRoundingCorners: [leftCorner, rightCorner],
                                              cornerRadii: CGSize(width: 5.0, height: 5.0))
    
    let maskLayer: CAShapeLayer = CAShapeLayer()
    
    maskLayer.frame = objectToRound!.bounds
    maskLayer.path = maskPath.CGPath
    
    objectToRound!.layer.mask = maskLayer
    objectToRound!.layer.masksToBounds = false
    objectToRound!.view?!.clipsToBounds = true
}

func randomInteger(minimumValue: Int, maximumValue: Int) -> Int
{
    return minimumValue + Int(arc4random_uniform(UInt32(maximumValue - minimumValue + 1)))
}

func colorWithHexString (hex:String) -> UIColor
{
    var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).noWhiteSpaceLowerCaseString
    
    if (cString.hasPrefix("#"))
    {
        cString = (cString as NSString).substringFromIndex(1)
    }
    
    if (cString.characters.count != 6)
    {
        return UIColor.grayColor()
    }
    
    let rString = (cString as NSString).substringToIndex(2)
    let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
    let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
    NSScanner(string: rString).scanHexInt(&r)
    NSScanner(string: gString).scanHexInt(&g)
    NSScanner(string: bString).scanHexInt(&b)
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}

extension Array
{
    var shuffledValue: [Element]
    {
        var arrayElements = self
        
        for individualIndex in 0..<arrayElements.count
        {
            swap(&arrayElements[individualIndex], &arrayElements[Int(arc4random_uniform(UInt32(arrayElements.count-individualIndex)))+individualIndex])
        }
        
        return arrayElements
    }
    
    var chooseOne: Element
    {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
}

extension Int
{
    var arrayValue: [Int]
    {
        return description.characters.map{Int(String($0)) ?? 0}
    }
    
    var ordinalValue: String
        {
        get
        {
            var suffix = "th"
            switch self % 10
            {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default: ()
            }
            
            if 10 < (self % 100) && (self % 100) < 20
            {
                suffix = "th"
            }
            
            return String(self) + suffix
        }
    }
}

extension String
{
    var noWhiteSpaceLowerCaseString: String { return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString }
    
    var letterValue: Int
    {
        return Array("abcdefghijklmnopqrstuvwxyz".characters).indexOf(Character(lowercaseString))?.successor() ?? 0
    }
    
    var jumbledValue: String
    {
        return String(Array(arrayLiteral: self).shuffledValue)
    }
    
    var length: Int { return characters.count }
    
    func removeWhitespace() -> String
    {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
    func chopPrefix(countToChop: Int = 1) -> String
    {
        return self.substringFromIndex(self.startIndex.advancedBy(characters.count - countToChop))
    }
    
    func chopSuffix(countToChop: Int = 1) -> String
    {
        return self.substringToIndex(self.startIndex.advancedBy(characters.count - countToChop))
    }
}

