//
//  Ring-Controller.swift
//  ΛVΛ (Code Name Avalon)
//
//  Created by Grant Goodman on 21/06/16.
//  Copyright © 2016 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class RC: UIViewController
{
    @IBOutlet weak var totalEnclosingView: UIView!
    @IBOutlet weak var firstDatePicker: UIDatePicker!
    @IBOutlet weak var secondDatePicker: UIDatePicker!
    @IBOutlet weak var alarmWillRingLabel: UILabel!
    @IBOutlet weak var confirmButton: WRB!
    @IBOutlet weak var cancelButton: RRB!
    
    @IBOutlet weak var ringOptionsView: UIView!
    
    var dateToFire: NSDate? = (UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire
    var updateTimer: NSTimer!
    
    var shouldRingToday: Bool! = true
    var segueSenderIsConfirmButton: Bool! = false
    
    var amountOfNotificationsScheduled: Int? = 0
    
    var compareTimeTimer: NSTimer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimerShouldBeValid = false
        
        compareTimeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(compareTime), userInfo: nil, repeats: true)
        
        //Make variables declared in the app delegate accesible.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        amountOfNotificationsScheduled = appDelegate.amountOfNotificationsScheduled!
        
        //Register for notifications.
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        //Cancel all local notifications.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if appDelegate.userTryingToCancelAlarm == true
        {
            print("User wants to cancel alarm.")
        }
        
        firstDatePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        secondDatePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateDate), userInfo: nil, repeats: true)
        
        let currentDate = NSCalendar.currentCalendar().dateBySettingUnit(.Second, value: 0, ofDate: NSDate(), options: [])!
    
        firstDatePicker.minimumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Minute, value: -1, toDate: currentDate, options: [])!
        secondDatePicker.minimumDate = firstDatePicker.calendar.dateByAddingUnit(.Minute, value: 1, toDate: firstDatePicker.date, options: [])
        
        setButtonElementsForWhiteRoundedButton(confirmButton, buttonTitle: "Confirm", buttonTarget: "confirmAction", buttonEnabled: true)
        setButtonElementsForRedRoundedButton(cancelButton, buttonTitle: "Cancel", buttonTarget: "cancelAction", buttonEnabled: true)
        
        if shouldRingToday == true
        {
            configureAlarmToRing(0)
            alarmWillRingLabel.text = "This alarm will ring between today at"
        }
        else
        {
            configureAlarmToRing(1)
            alarmWillRingLabel.text = "This alarm will ring between tomorrow at"
        }
        
        UIView.animateWithDuration(1, delay: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.totalEnclosingView.alpha = 1.0
                
            }, completion: {(value: Bool) in})
    }
    
    func configureAlarmToRing(onDay: Int!)
    {
        if onDay == 0
        {
            let currentDate = NSCalendar.currentCalendar().dateBySettingUnit(.Second, value: 0, ofDate: NSDate(), options: [])!
            
            firstDatePicker.minimumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Minute, value: -1, toDate: currentDate, options: [])!
            firstDatePicker.setDate(NSCalendar.currentCalendar().dateByAddingUnit(.Minute, value: 1, toDate: NSDate(), options: [])!, animated: false)
            
            secondDatePicker.minimumDate = firstDatePicker.calendar.dateByAddingUnit(.Minute, value: 1, toDate: firstDatePicker.date, options: [])
            secondDatePicker.setDate(firstDatePicker.calendar.dateByAddingUnit(.Minute, value: 1, toDate: firstDatePicker.date, options: [])!, animated: false)
            
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateDate), userInfo: nil, repeats: true)
        }
        else if onDay == 1
        {
            updateTimer.invalidate()
            
            firstDatePicker.setDate(NSCalendar.currentCalendar().startOfDayForDate(NSDate()), animated: false)
            firstDatePicker.minimumDate = firstDatePicker.calendar.dateByAddingUnit(.Day, value: 1, toDate: firstDatePicker.date, options: [])
            
            secondDatePicker.setDate(firstDatePicker.date, animated: false)
            secondDatePicker.minimumDate = firstDatePicker.calendar.dateByAddingUnit(.Minute, value: 1, toDate: firstDatePicker.date, options: [])
        }
        else
        {
            print("The day integer value requested to be configured is invalid.")
        }
    }
    
    func updateDate()
    {
        if updateTimer.valid == true
        {
            let currentDate = NSCalendar.currentCalendar().dateBySettingUnit(.Second, value: 0, ofDate: NSDate(), options: [])!
            
            firstDatePicker.minimumDate = NSCalendar.currentCalendar().dateByAddingUnit(.Minute, value: -1, toDate: currentDate, options: [])!
            secondDatePicker.minimumDate = firstDatePicker.calendar.dateByAddingUnit(.Minute, value: 1, toDate: firstDatePicker.date, options: [])
        }
    }
    
    func compareTime()
    {
        if (UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire != nil
        {
            if shortTimeStringFromDate(NSDate()) == shortTimeStringFromDate((UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire!) && (UIApplication.sharedApplication().delegate as! AppDelegate).didResign == false
            {
                print("time of alarm occurred within app from ring controller")
                compareTimeTimer.invalidate()
                
                let alarmOccurredAlertController = UIAlertController(title: "Alarm Ringing", message: "Your alarm time occurred while you were still using ΛVΛ.", preferredStyle: UIAlertControllerStyle.Alert)
                
                alarmOccurredAlertController.addAction(UIAlertAction(title: "Cancel Alarm", style: .Cancel, handler: { (action) -> Void in
                    self.cancelAction()
                }))
                
                UIApplication.topViewController()!.presentViewController(alarmOccurredAlertController, animated: true, completion: nil)
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
    
    func confirmAction()
    {
        segueSenderIsConfirmButton = true
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        dateToFire = NSDate(timeIntervalSince1970: Double(randomTimeBetweenTwoTimes(Int(firstDatePicker.date.timeIntervalSince1970), secondTime: Int(secondDatePicker.date.timeIntervalSince1970))))
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .ShortStyle
        
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let dateToFireComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: dateToFire!)
        let currentDateComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: NSDate())
        
        if dateToFireComponents.day == currentDateComponents.day
        {
            NSUserDefaults.standardUserDefaults().setValue("Alarm set for today between \(timeFormatter.stringFromDate(firstDatePicker.date)) and \(timeFormatter.stringFromDate(secondDatePicker.date))", forKey: "textForGreetingLabel")
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setValue("Alarm set for tomorrow between \(timeFormatter.stringFromDate(firstDatePicker.date)) and \(timeFormatter.stringFromDate(secondDatePicker.date))", forKey: "textForGreetingLabel")
        }
        
        NSUserDefaults.standardUserDefaults().setValue(dateToFire, forKey: "dateToFire")
        NSUserDefaults.standardUserDefaults().setValue(true, forKey: "alarmSet")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        print("Alarm will fire at: \(dateToFire!)")
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire = dateToFire
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimerShouldBeValid = true
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                //self.optionsView.alpha = 1.0
                
            }, completion: {(value: Bool) in
                
                self.performSegueWithIdentifier("backToStartSegue", sender: self)
        })
    }
    
    func cancelAction()
    {
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "dateToFire")
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "alarmSet")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        segueSenderIsConfirmButton = false
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire = nil
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimerShouldBeValid = false
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                //self.optionsView.alpha = 1.0
                
            }, completion: {(value: Bool) in
                
                self.performSegueWithIdentifier("backToStartSegue", sender: self)
        })
    }
    
    func randomTimeBetweenTwoTimes(firstTime: Int!, secondTime: Int!) -> Int
    {
        return randRange(firstTime, upper: secondTime)
    }
    
    func randRange (lower: Int , upper: Int) -> Int
    {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    func registerFirstNotification()
    {
        if amountOfNotificationsScheduled < 64
        {
            dateToFire = dateToFire?.dateByAddingTimeInterval(3)
            
            amountOfNotificationsScheduled = amountOfNotificationsScheduled! + 1
            
            let newNotification = UILocalNotification()
            newNotification.timeZone = NSTimeZone.systemTimeZone()
            newNotification.fireDate = dateToFire
            
            if amountOfNotificationsScheduled != 64
            {
                newNotification.alertBody = "Your alarm is ringing! (\(amountOfNotificationsScheduled!))"
            }
            else
            {
                newNotification.alertBody = "The alarm doesn't seem to be working. Stopping notifications."
            }
            
            newNotification.alertAction = "address"
            newNotification.alertTitle = "ΛVΛ"
            newNotification.soundName = "ding.mp3"
            UIApplication.sharedApplication().scheduleLocalNotification(newNotification)
        }
        else
        {
            (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimer.invalidate()
        }
        
        print(amountOfNotificationsScheduled!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        compareTimeTimer.invalidate()
        
        if segue.identifier == "backToStartSegue" && segueSenderIsConfirmButton == true
        {
            let destinationController = segue.destinationViewController as! MC
            
            let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
            let dateToFireComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: dateToFire!)
            let currentDateComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: NSDate())
            
            destinationController.notificationShouldFire = true
            
            let timeFormatter = NSDateFormatter()
            timeFormatter.timeStyle = .ShortStyle
                
            if dateToFireComponents.day == currentDateComponents.day
            {
                destinationController.textForGreetingLabel = "Alarm set for today between \(timeFormatter.stringFromDate(firstDatePicker.date)) and \(timeFormatter.stringFromDate(secondDatePicker.date))"
            }
            else
            {
                destinationController.textForGreetingLabel = "Alarm set for tomorrow between \(timeFormatter.stringFromDate(firstDatePicker.date)) and \(timeFormatter.stringFromDate(secondDatePicker.date))"
            }
        }
        else if segue.identifier == "backToStartSegue" && segueSenderIsConfirmButton == false
        {
            let destinationController = segue.destinationViewController as! MC
            
            destinationController.textForGreetingLabel = ""
            
            destinationController.notificationShouldFire = false
        }
    }
    
    func firstDatePickerChanged(firstDatePicker:UIDatePicker)
    {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        secondDatePicker.minimumDate = firstDatePicker.calendar.dateByAddingUnit(.Minute, value: 1, toDate: firstDatePicker.date, options: [])
    }
    
    func setButtonElementsForWhiteRoundedButton(roundedButton: WRB, buttonTitle: String, buttonTarget: String?, buttonEnabled: Bool)
    {
        if buttonEnabled == true
        {
            roundedButton.layer.borderColor = UIColor.whiteColor().CGColor
            roundedButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            roundedButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            
            roundedButton.enabled = true
            roundedButton.userInteractionEnabled = true
        }
        else
        {
            roundedButton.layer.borderColor = UIColor.grayColor().CGColor
            roundedButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            roundedButton.enabled = false
            roundedButton.userInteractionEnabled = false
        }
        
        roundedButton.layer.borderWidth = 1.0
        roundedButton.layer.cornerRadius = 5.0
        roundedButton.alpha = 0.8
        roundedButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        roundedButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        if buttonTarget != nil
        {
            let buttonTargetSelector: Selector = NSSelectorFromString(buttonTarget!)
            roundedButton.addTarget(self, action: buttonTargetSelector, forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func setButtonElementsForRedRoundedButton(roundedButton: RRB, buttonTitle: String, buttonTarget: String?, buttonEnabled: Bool)
    {
        if buttonEnabled == true
        {
            roundedButton.layer.borderColor = colorWithHexString("FF4E4E").CGColor
            roundedButton.setTitleColor(colorWithHexString("FF4E4E"), forState: UIControlState.Normal)
            roundedButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            
            roundedButton.enabled = true
            roundedButton.userInteractionEnabled = true
        }
        else
        {
            roundedButton.layer.borderColor = UIColor.grayColor().CGColor
            roundedButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            roundedButton.enabled = false
            roundedButton.userInteractionEnabled = false
        }
        
        roundedButton.layer.borderWidth = 1.0
        roundedButton.layer.cornerRadius = 5.0
        roundedButton.alpha = 0.8
        roundedButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        roundedButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        if buttonTarget != nil
        {
            let buttonTargetSelector: Selector = NSSelectorFromString(buttonTarget!)
            roundedButton.addTarget(self, action: buttonTargetSelector, forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func setButtonElementsForBlackRoundedButton(roundedButton: BRB, buttonTitle: String, buttonTarget: String?, buttonEnabled: Bool)
    {
        if buttonEnabled == true
        {
            roundedButton.layer.borderColor = UIColor.blackColor().CGColor
            roundedButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            roundedButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
            
            roundedButton.enabled = true
            roundedButton.userInteractionEnabled = true
        }
        else
        {
            roundedButton.layer.borderColor = UIColor.grayColor().CGColor
            roundedButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            roundedButton.enabled = false
            roundedButton.userInteractionEnabled = false
        }
        
        roundedButton.layer.borderWidth = 1.0
        roundedButton.layer.cornerRadius = 5.0
        roundedButton.alpha = 0.600000023841858
        roundedButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        roundedButton.setTitle(buttonTitle.uppercaseString, forState: UIControlState.Normal)
        
        if buttonTarget != nil
        {
            let buttonTargetSelector: Selector = NSSelectorFromString(buttonTarget!)
            roundedButton.addTarget(self, action: buttonTargetSelector, forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
}
