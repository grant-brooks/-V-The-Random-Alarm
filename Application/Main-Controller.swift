//
//  Main-Controller.swift
//  ΛVΛ (Code Name Avalon)
//
//  Created by Grant Goodman on 30/05/16.
//  Copyright © 2016 NEOTechnica Corporation. All rights reserved.
//

import UIKit

class MC: UIViewController
{
    //--------------------------------------------------//
    
    //Interface Builder User Interface Elements
    
    //UIButtons
    @IBOutlet weak var buildButton:       UIButton!
    @IBOutlet weak var codeNameButton:    UIButton!
    @IBOutlet weak var informationButton: UIButton!
    @IBOutlet weak var ntButton:          UIButton!
    
    //UILabels
    @IBOutlet weak var bundleVersionLabel:           UILabel!
    @IBOutlet weak var bundleVersionSubtitleLabel:   UILabel!
    
    @IBOutlet weak var designationLabel:             UILabel!
    @IBOutlet weak var designationSubtitleLabel:     UILabel!
    
    @IBOutlet weak var skuLabel:                     UILabel!
    @IBOutlet weak var skuLabelSubtitleLabel:        UILabel!
    
    @IBOutlet weak var topDesignationLabel:          UILabel!
    @IBOutlet weak var topSkuLabel:                  UILabel!
    @IBOutlet weak var topVersionLabel:              UILabel!
    
    @IBOutlet weak var preReleaseNotifierLabel:      UILabel!
    
    //Other Items
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    
    @IBOutlet weak var screenShotView: UIView!
    
    @IBOutlet weak var createAnAlarmButton: WRB!
    @IBOutlet weak var cancelMyAlarmButton: RRB!
    
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var hiddenGreetingLabel: UILabel!
    
    @IBOutlet weak var totalEnclosingView: UIView!
    
    @IBOutlet weak var userRequestLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var todayButton: WRB!
    @IBOutlet weak var tomorrowButton: WRB!
    
    var segueFromTodayButton: Bool! = true
    var alarmSet: Bool! = true
    
    var notificationShouldFire: Bool! = false
    
    var textForGreetingLabel: String! = ""
    
    var compareTimeTimer: NSTimer!
    
    //--------------------------------------------------//
    
    //Non-Interface Builder Elements
    
    //Array Objects
    var uploadArray:   [String]! = []
    var uploadedArray: [String]! = []
    
    //Boolean Objects
    var isAdHocDistribution:   Bool!
    var preReleaseApplication: Bool!
    var screenShotsToggledOn:  Bool!
    var shouldTakeScreenShot:  Bool!
    var uploadedScreenShot:    Bool! = false
    
    //Integer Objects
    //let buildNumber = Int(NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String)! + 1
    let buildNumber = Int(NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String)!
    
    var amountOfNotificationsScheduled: Int? = 0
    var applicationGenerationAsInteger: Int!
    var bugFixReleaseNumber:            Int!
    var minorReleaseNumber:             Int!
    var versionChoice:                  Int! = 0
    
    //String Objects
    var applicationCodeName:      String!
    var applicationGeneration:    String!
    var applicationSku:           String!
    var currentCaptureLink:       String!
    var developmentState:         String! = "i"
    var formattedVersionNumber:   String!
    var preReleaseNotifierString: String!
    
    //Other Items
    var dateToFire: NSDate? = (UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire
    var updateTimer: NSTimer!
    
    //--------------------------------------------------//
    
    
    //Override Functions
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimerShouldBeValid = false
        
        //Be sure to change the values below.
            //The development state of the application.
            //The code name of the application.
            //The value of the pre-release application boolean.
            //The boolean value determining whether or not the application is ad-hoc.
            //The first digit in the formatted version number.
        
        //Declare and set user defaults.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.objectForKey("buildNumber") != nil
        {
            if buildNumber == userDefaults.objectForKey("buildNumber") as! Int
            {
                shouldTakeScreenShot = false
            }
            else if buildNumber != userDefaults.objectForKey("buildNumber") as! Int
            {
                shouldTakeScreenShot = true
            }
        }
        else
        {
            shouldTakeScreenShot = true
        }
        
        if userDefaults.objectForKey("screenShotsToggledOn") != nil
        {
            screenShotsToggledOn = userDefaults.valueForKey("screenShotsToggledOn") as! Bool
        }
        else
        {
            screenShotsToggledOn = false
        }
        
        userDefaults.setValue(buildNumber, forKey: "buildNumber")
        userDefaults.setValue(screenShotsToggledOn, forKey: "screenShotsToggledOn")
        userDefaults.synchronize()
        
        //Make variables declared in the app delegate accesible.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Set the minor and bug fix release numbers, lifted from the values in the AppDelegate file.
        amountOfNotificationsScheduled = appDelegate.amountOfNotificationsScheduled!
        bugFixReleaseNumber = appDelegate.bugFixReleaseNumber!
        minorReleaseNumber = appDelegate.minorReleaseNumber!
        //notificationTimer = appDelegate.notificationTimer!
        preReleaseNotifierString = appDelegate.preReleaseNotifierString!
        
        //Declare whether the application is a pre-release version or not, and the project code name.
        applicationCodeName = "Avalon"
        codeNameButton.setTitle("Project Code Name: " + applicationCodeName, forState: .Normal)
        preReleaseApplication = false
        isAdHocDistribution = false
        
        //Prepare various values to be displayed as version information.
        preReleaseNotifierLabel.text = preReleaseNotifierString
        generateSkuAndGeneration()
        
        //Set the SKU and pre-release notifier for the application.
        skuLabelSubtitleLabel.text = applicationSku
        preReleaseNotifierLabel.text = preReleaseNotifierString
        
        //Format the version number for later display.
        formattedVersionNumber = "1." + String(minorReleaseNumber) + "." + String(bugFixReleaseNumber)
        
        //Determine what is displayed on the 'buildButton' button.
        if versionChoice == 0
        {
            buildButton.setTitle(formattedVersionNumber!, forState: UIControlState.Normal)
        }
        else if versionChoice == 1
        {
            buildButton.setTitle(applicationSku!, forState: UIControlState.Normal)
        }
        else if versionChoice == 2
        {
            buildButton.setTitle(formattedVersionNumber, forState: UIControlState.Normal)
            
            self.buildButton.alpha = 0.0
            self.ntButton.alpha = 1.0
        }
        
        //Set the colour of the status bar.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UIApplication.sharedApplication().statusBarHidden = false
        
        //Determine what to show or hide depending on what kind of release the current build is designated as.
        if preReleaseApplication == false && isAdHocDistribution == false
        {
            codeNameButton.hidden = true
            informationButton.hidden = true
            preReleaseNotifierLabel.hidden = true
            
            bundleVersionLabel.alpha = 0.0
            bundleVersionSubtitleLabel.alpha = 0.0
            
            designationLabel.alpha = 0.0
            designationSubtitleLabel.alpha = 0.0
            
            skuLabel.alpha = 0.0
            skuLabelSubtitleLabel.alpha = 0.0
            
            buildButton.hidden = false
            ntButton.hidden = false
        }
        else
        {
            bundleVersionLabel.alpha = 0.0
            bundleVersionSubtitleLabel.alpha = 0.0
            
            designationLabel.alpha = 0.0
            designationSubtitleLabel.alpha = 0.0
            
            skuLabel.alpha = 0.0
            skuLabelSubtitleLabel.alpha = 0.0
        }
        
        //Determine the application version number and display it on the 'bundleVersionSubtitleLabel' label.
        let applicationVersionNumber = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        bundleVersionSubtitleLabel.text = applicationVersionNumber
        
        //Register for notifications.
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        //Cancel all local notifications.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //Set the 'uploadArray' array to the array of files in the local documents folder.
        uploadArray = arrayOfFilesInDocumentsFolder()
        
        //Set the proposed web link to the current capture.
        currentCaptureLink = "http://www.grantbrooksgoodman.io/APPLICATIONS/\(applicationCodeName.uppercaseString)/\(applicationSku)"
        
        compareTimeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(compareTime), userInfo: nil, repeats: true)
        
        greetingLabel.adjustsFontSizeToFitWidth = true
        hiddenGreetingLabel.adjustsFontSizeToFitWidth = true
        
        if notificationShouldFire == false
        {
            (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimerShouldBeValid = false
        }
        else
        {
            (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimerShouldBeValid = true
        }
        
        if userDefaults.objectForKey("alarmSet") != nil
        {
            if userDefaults.objectForKey("alarmSet") as! Bool == true
            {
                if userDefaults.objectForKey("textForGreetingLabel") != nil
                {
                    if userDefaults.objectForKey("dateToFire") != nil
                    {
                        if (shortTimeStringFromDate(NSDate()) < (shortTimeStringFromDate(userDefaults.objectForKey("dateToFire") as! NSDate)))
                        {
                            textForGreetingLabel = userDefaults.objectForKey("textForGreetingLabel") as! String
                        }
                        else if (shortTimeStringFromDate(NSDate()) == (shortTimeStringFromDate(userDefaults.objectForKey("dateToFire") as! NSDate)))
                        {
                            textForGreetingLabel = "Alarm is ringing"
                        }
                    }
                }
                
                alarmSet = true
            }
            else
            {
                alarmSet = false
            }
        }
        else
        {
            alarmSet = false
        }
        
        let currentDate = NSDate()
        let currentCalendar = NSCalendar.currentCalendar()
        let calendarComponents = currentCalendar.components([ .Hour, .Minute, .Second], fromDate: currentDate)
        let currentHour = calendarComponents.hour
        
        if textForGreetingLabel == ""
        {
            if currentHour < 12
            {
                greetingLabel.text = "Good morning"
                hiddenGreetingLabel.text = "Good morning"
            }
            else if currentHour >= 12 && currentHour < 18
            {
                greetingLabel.text = "Good afternoon"
                hiddenGreetingLabel.text = "Good afternoon"
            }
            else if currentHour > 12 && currentHour > 18
            {
                greetingLabel.text = "Good evening"
                hiddenGreetingLabel.text = "Good evening"
            }
            
            greetingLabel.font = UIFont.systemFontOfSize(30.0)
            hiddenGreetingLabel.font = UIFont.systemFontOfSize(30.0)
        }
        else
        {
            greetingLabel.text = textForGreetingLabel
            hiddenGreetingLabel.text = textForGreetingLabel
        }
        
        setButtonElementsForWhiteRoundedButton(createAnAlarmButton, buttonTitle: "Create an alarm", buttonTarget: "createAlarmAction", buttonEnabled: true)
        
        setButtonElementsForRedRoundedButton(cancelMyAlarmButton, buttonTitle: "Cancel my alarm", buttonTarget: "cancelAlarmAction", buttonEnabled: true)
        
        setButtonElementsForWhiteRoundedButton(todayButton, buttonTitle: "Today", buttonTarget: "todayAction", buttonEnabled: true)
        setButtonElementsForWhiteRoundedButton(tomorrowButton, buttonTitle: "Tomorrow", buttonTarget: "tomorrowAction", buttonEnabled: true)
        
        if alarmSet == true
        {
            createAnAlarmButton.alpha = 0.0
        }
        else
        {
            cancelMyAlarmButton.alpha = 0.0
        }
        
        optionsView.alpha = 0.0
        todayButton.alpha = 0.0
        tomorrowButton.alpha = 0.0
        todayButton.enabled = false
        tomorrowButton.enabled = false
        
        UIView.animateWithDuration(1, delay: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.greetingLabel.alpha = 1.0
                
            }, completion: {(value: Bool) in
                
                UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.greetingLabel.frame.origin.y = 20
                        
                    }, completion: {(value: Bool) in
                        
                        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                            {
                                self.optionsView.alpha = 1.0
                                
                            }, completion:  {(value: Bool) in
                                
                                self.greetingLabel.hidden = true
                                self.hiddenGreetingLabel.hidden = false
                        })
                })
        })
    }
    
    func compareTime()
    {
        if (UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire != nil
        {
            if shortTimeStringFromDate(NSDate()) == shortTimeStringFromDate((UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire!) && (UIApplication.sharedApplication().delegate as! AppDelegate).didResign == false
            {
                print("time of alarm occurred within app from create controller")
                compareTimeTimer.invalidate()
                
                let alarmOccurredAlertController = UIAlertController(title: "Alarm Ringing", message: "Your alarm time occurred while you were still using ΛVΛ.", preferredStyle: UIAlertControllerStyle.Alert)
                
                alarmOccurredAlertController.addAction(UIAlertAction(title: "Cancel Alarm", style: .Cancel, handler: { (action) -> Void in
                    self.cancelAlarmAction()
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
    
    func createAlarmAction()
    {
        createAnAlarmButton.userInteractionEnabled = false
        
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                //self.totalEnclosingView.alpha = 0.0
                
            }, completion: {(value: Bool) in
                
                UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.lineView.frame.size.width = 280
                        
                        if UIScreen.mainScreen().bounds.height != 568 && UIScreen.mainScreen().bounds.height != 480
                        {
                            self.lineView.frame.origin.x = 59
                        }
                        else
                        {
                            self.lineView.frame.origin.x = 20
                        }

                    }, completion: {(value: Bool) in
                        
                        UIView.transitionWithView(self.userRequestLabel, duration: 0.5, options: [.TransitionCrossDissolve], animations: {
                            
                            self.userRequestLabel.text = "This alarm should ring"
                            
                            }, completion: {(value: Bool) in
                                
                                UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                                    {
                                        self.createAnAlarmButton.alpha = 0.0
                                        self.cancelMyAlarmButton.alpha = 0.0
                                        
                                        self.todayButton.alpha = 1.0
                                        self.tomorrowButton.alpha = 1.0
                                        
                                    }, completion: {(value: Bool) in
                                        
                                        self.createAnAlarmButton.enabled = false
                                        self.cancelMyAlarmButton.enabled = false
                                        self.createAnAlarmButton.userInteractionEnabled = true
                                        
                                        self.todayButton.enabled = true
                                        self.tomorrowButton.enabled = true
                                })
                        })
                })
        })
    }
    
    func cancelAlarmAction()
    {
        textForGreetingLabel = ""
        
        cancelMyAlarmButton.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.cancelMyAlarmButton.alpha = 0.0
                
            }, completion: {(value: Bool) in
                
                UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.createAnAlarmButton.alpha = 1.0
                        self.createAnAlarmButton.userInteractionEnabled = false
                        
                        let currentDate = NSDate()
                        let currentCalendar = NSCalendar.currentCalendar()
                        let calendarComponents = currentCalendar.components([ .Hour, .Minute, .Second], fromDate: currentDate)
                        let currentHour = calendarComponents.hour
                        
                        UIView.transitionWithView(self.greetingLabel, duration: 0.5, options: [.TransitionCrossDissolve], animations:{
                            
                            if currentHour < 12
                            {
                                self.greetingLabel.text = "Good morning"
                            }
                            else if currentHour >= 12 && currentHour < 18
                            {
                                self.greetingLabel.text = "Good afternoon"
                            }
                            else if currentHour > 12 && currentHour > 18
                            {
                                self.greetingLabel.text = "Good evening"
                            }
                            
                            self.greetingLabel.font = UIFont.systemFontOfSize(30.0)
                            
                            }, completion: {(value: Bool) in
                                
                                UIView.transitionWithView(self.hiddenGreetingLabel, duration: 0.5, options: [.TransitionCrossDissolve], animations: {
                                    
                                    if currentHour < 12
                                    {
                                        self.hiddenGreetingLabel.text = "Good morning"
                                    }
                                    else if currentHour >= 12 && currentHour < 18
                                    {
                                        self.hiddenGreetingLabel.text = "Good afternoon"
                                    }
                                    else if currentHour > 12 && currentHour > 18
                                    {
                                        self.hiddenGreetingLabel.text = "Good evening"
                                    }
                                    
                                    self.hiddenGreetingLabel.font = UIFont.systemFontOfSize(30.0)
                                    
                                    }, completion: nil)
                        })
                        
                    }, completion: {(value: Bool) in
                        
                        self.createAnAlarmButton.userInteractionEnabled = true
                        self.cancelMyAlarmButton.userInteractionEnabled = true
                        
                        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "dateToFire")
                        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "alarmSet")
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        (UIApplication.sharedApplication().delegate as! AppDelegate).dateToFire = nil
                        (UIApplication.sharedApplication().delegate as! AppDelegate).notificationTimerShouldBeValid = false
                        UIApplication.sharedApplication().cancelAllLocalNotifications()
                })
        })
    }
    
    func todayAction()
    {
        segueFromTodayButton = true
        performSegueWithIdentifier("createAlarmSegue", sender: self)
    }
    
    func tomorrowAction()
    {
        segueFromTodayButton = false
        performSegueWithIdentifier("createAlarmSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        compareTimeTimer.invalidate()
        
        let destinationController = segue.destinationViewController as! RC
        
        if segueFromTodayButton == true
        {
            destinationController.shouldRingToday = true
        }
        else
        {
            destinationController.shouldRingToday = false
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        topVersionLabel.text = formattedVersionNumber
        topSkuLabel.text = applicationSku
        topDesignationLabel.text = designationSubtitleLabel.text!
        
        if (shouldTakeScreenShot == true || uploadArray.count > 0) && ((UIApplication.sharedApplication().delegate as! AppDelegate).uploadedScreenShot == false)
        {
            if preReleaseApplication == true
            {
                NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: #selector(screenShot), userInfo: nil, repeats: false)
            }
            else
            {
                screenShotView.hidden = true
            }
        }
        else
        {
            screenShotView.hidden = true
        }
    }
    
    //--------------------------------------------------//
    
    //Interface Builder Actions
    
    @IBAction func buildButton(sender: AnyObject)
    {
        //Determine what to display for each setting of the build button.
        if buildButton.titleLabel!.text == formattedVersionNumber
        {
            buildButton.setTitle(applicationSku, forState: UIControlState.Normal)
            versionChoice = 1
        }
        else if buildButton.titleLabel!.text == applicationSku
        {
            buildButton.setTitle(formattedVersionNumber, forState: UIControlState.Normal)
            versionChoice = 2
            
            self.buildButton.alpha = 0.0
            
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.ntButton.alpha = 1.0
                    
                }, completion: nil)
        }
    }
    
    @IBAction func codeNameButton(sender: AnyObject)
    {
        if designationLabel.alpha == 0.0
        {
            //Animate the display of various elements of the view.
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.bundleVersionLabel.alpha = 1.0
                    self.bundleVersionSubtitleLabel.alpha = 1.0
                    
                    self.designationLabel.alpha = 1.0
                    self.designationSubtitleLabel.alpha = 1.0
                    
                    self.skuLabel.alpha = 1.0
                    self.skuLabelSubtitleLabel.alpha = 1.0
                    
                }, completion: nil)
        }
        else
        {
            //Animate the hide of various elements of the view.
            UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.bundleVersionLabel.alpha = 0.0
                    self.bundleVersionSubtitleLabel.alpha = 0.0
                    
                    self.designationLabel.alpha = 0.0
                    self.designationSubtitleLabel.alpha = 0.0
                    
                    self.skuLabel.alpha = 0.0
                    self.skuLabelSubtitleLabel.alpha = 0.0
                    
                }, completion: nil)
        }
    }
    
    @IBAction func informationButton(sender: AnyObject)
    {
        //Determine and set the reported development state, depending on the state of various prerequisites.
        if developmentState == "i"
        {
            developmentState = "for use by internal developers only"
        }
        else if developmentState == "p"
        {
            developmentState = "for limited outside user testing"
        }
        
        //Declare, set, and display the 'informationAlertController' alert controller.
        let informationAlertController = UIAlertController(title: "Project \(applicationCodeName.capitalizedString)", message: "This is a pre-release version of project code name \(applicationCodeName).\n\nThis version is meant \(developmentState).\n\nAll features presented here are subject to change, and any new or previously undisclosed information presented within this software is to remain strictly confidential.\n\nRedistribution of this software by unauthorised parties in any way, shape, or form is strictly prohibited.\n\nBy continuing your use of this software, you acknowledge your agreement to the above terms.", preferredStyle: UIAlertControllerStyle.Alert)
        informationAlertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        
        if uploadedScreenShot == true
        {
            informationAlertController.addAction(UIAlertAction(title: "View Current Online Capture", style: .Default, handler: { (action: UIAlertAction!) in
                UIApplication.sharedApplication().openURL(NSURL(string: "\(self.currentCaptureLink).png")!)
            }))
        }
        
        if screenShotsToggledOn == true
        {
            informationAlertController.addAction(UIAlertAction(title: "Disable Self-Capture", style: .Destructive, handler: { (action: UIAlertAction!) in
                self.screenShotsToggledOn = false
                NSUserDefaults.standardUserDefaults().setValue(self.screenShotsToggledOn, forKey: "screenShotsToggledOn")
                NSUserDefaults.standardUserDefaults().synchronize()
            }))
        }
        else
        {
            informationAlertController.addAction(UIAlertAction(title: "Enable Self-Capture", style: .Default, handler: { (action: UIAlertAction!) in
                self.screenShotsToggledOn = true
                NSUserDefaults.standardUserDefaults().setValue(self.screenShotsToggledOn, forKey: "screenShotsToggledOn")
                NSUserDefaults.standardUserDefaults().synchronize()
            }))
        }
        
        self.presentViewController(informationAlertController, animated: true, completion: nil)
    }
    
    @IBAction func longPress(sender: AnyObject)
    {
        //Copy the text of the build button to the clipboard.
        let pasteBoard = UIPasteboard.generalPasteboard()
        pasteBoard.string = buildButton.titleLabel!.text
    }
    
    @IBAction func ntButton(sender: AnyObject)
    {
        //Set the alpha of the 'ntButton' button and version choice.
        self.ntButton.alpha = 0.0
        versionChoice = 0
        
        //Animate the display of the build button.
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
            {
                self.buildButton.alpha = 1.0
                
            }, completion: nil)
    }
    
    //--------------------------------------------------//
    
    //Inependent Functions
    
    func generateSkuAndGeneration()
    {
        //Declare and set the application's build date.
        let applicationBuildDate = NSBundle.mainBundle().infoDictionary!["CFBuildDate"] as! NSDate
        
        //Declare and set the date that the application was compiled.
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "ddMM"
        let skuDate: String = dateFormatter.stringFromDate(applicationBuildDate)
        
        //Declare and set the name of the application.
        var applicationName = applicationCodeName
        
        //Format the name of the application for display in the SKU.
        if applicationName.length > 3
        {
            applicationName = applicationName.chopSuffix(applicationName.length - 3)
        }
        else if applicationName.length == 3
        {
            applicationName = applicationName.chopSuffix(applicationName.length)
        }
        
        //Format the build number for the SKU.
        var formattedBuildNumberAsString: String! = String(buildNumber)
        if formattedBuildNumberAsString.length < 4 && formattedBuildNumberAsString.length < 5
        {
            if formattedBuildNumberAsString.length == 1
            {
                formattedBuildNumberAsString = "000" + formattedBuildNumberAsString
            }
            else if formattedBuildNumberAsString.length == 2
            {
                formattedBuildNumberAsString = "00" + formattedBuildNumberAsString
            }
            else if formattedBuildNumberAsString.length == 3
            {
                formattedBuildNumberAsString = "0" + formattedBuildNumberAsString
            }
            
            applicationGeneration = 1.ordinalValue
            applicationGenerationAsInteger = 1
        }
        else if formattedBuildNumberAsString.length == 4
        {
            applicationGeneration = 1.ordinalValue
            applicationGenerationAsInteger = 1
        }
        else if formattedBuildNumberAsString.length >= 5
        {
            let formattedBuildNumberAsStringAsDouble = Double(formattedBuildNumberAsString)
            let firstSubtractedBuildNumber = Int((formattedBuildNumberAsStringAsDouble! / 10000) + 1)
            let secondSubtractedBuildNumber = (firstSubtractedBuildNumber - 1) * 10000
            let thirdSubtractedBuildNumber = secondSubtractedBuildNumber - Int(formattedBuildNumberAsStringAsDouble!)
            
            formattedBuildNumberAsString = String(thirdSubtractedBuildNumber).stringByReplacingOccurrencesOfString("-", withString: "")
            
            if formattedBuildNumberAsString.length == 1
            {
                formattedBuildNumberAsString = "000" + formattedBuildNumberAsString
            }
            else if formattedBuildNumberAsString.length == 2
            {
                formattedBuildNumberAsString = "00" + formattedBuildNumberAsString
            }
            else if formattedBuildNumberAsString.length == 3
            {
                formattedBuildNumberAsString = "0" + formattedBuildNumberAsString
            }
            
            applicationGeneration = String(Int((formattedBuildNumberAsStringAsDouble! / 10000) + 1).ordinalValue)
            applicationGenerationAsInteger = Int((formattedBuildNumberAsStringAsDouble! / 10000) + 1)
        }
        
        //Set the development state designation label text.
        if developmentState == "p" && preReleaseApplication == false
        {
            designationSubtitleLabel.text = "PUB-DIS"
        }
        else if developmentState == "p" && preReleaseApplication == true
        {
            designationSubtitleLabel.text = "PUB-TES"
        }
        else if developmentState == "i" && preReleaseApplication == false
        {
            designationSubtitleLabel.text = "INT-DIS"
        }
        else if developmentState == "i" && preReleaseApplication == true
        {
            designationSubtitleLabel.text = "INT-TES"
        }
        
        //Set the application SKU.
        applicationSku = "\(skuDate)-\(applicationName.uppercaseString)-\(String(applicationGenerationAsInteger) + formattedBuildNumberAsString)"
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
    
    func getDocumentsDirectory() -> NSString
    {
        let searchPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = searchPaths[0]
        return documentsDirectory
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
    
    func removeItemFromDocumentsFolder(itemName: String)
    {
        do
        {
            try NSFileManager.defaultManager().removeItemAtPath("\(getDocumentsDirectory())/\(itemName)")
        }
        catch let occurredError as NSError
        {
            print(occurredError.debugDescription)
        }
    }
    
    func arrayOfFilesInDocumentsFolder() -> [String]
    {
        do
        {
            let allItems = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(getDocumentsDirectory() as String)
            
            return allItems
        }
        catch let occurredError as NSError
        {
            print(occurredError.debugDescription)
        }
        
        return []
    }
    
    func screenShot() -> UIImage
    {
        if (UIApplication.sharedApplication().delegate as! AppDelegate).uploadedScreenShot == false
        {
            let keyWindowLayer = UIApplication.sharedApplication().keyWindow!.layer
            let mainScreenScale = UIScreen.mainScreen().scale
            
            UIGraphicsBeginImageContextWithOptions(keyWindowLayer.frame.size, false, mainScreenScale);
            
            self.view?.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
            
            let screenShot = UIGraphicsGetImageFromCurrentImageContext()
            
            if screenShotsToggledOn == true
            {
                UIImageWriteToSavedPhotosAlbum(screenShot, nil, nil, nil)
            }
            
            UIGraphicsEndImageContext()
            
            screenShotView.hidden = true
            
            if let pngData = UIImagePNGRepresentation(screenShot)
            {
                let fileName = getDocumentsDirectory().stringByAppendingPathComponent("\(applicationSku).png")
                uploadArray.append("\(applicationSku).png")
                pngData.writeToFile(fileName, atomically: true)
            }
            
            var sessionConfiguration = SessionConfiguration()
            sessionConfiguration.host = "ftp://ftp.grantbrooksgoodman.io/"
            sessionConfiguration.username = "grantgoodman"
            sessionConfiguration.password = "Grantavery123"
            
            let currentSession = Session(configuration: sessionConfiguration)
            
            currentSession.createDirectory("/public_html/APPLICATIONS/\(self.applicationCodeName.uppercaseString)")
            {
                (result, error) -> Void in
                
                if error == nil
                {
                    print("Made new directory for application.")
                }
                else
                {
                    print("Application directory already exists.")
                }
            }
            
            uploadArray.removeAtIndex(0)
            uploadedArray = uploadArray
            
            for individualObject in uploadArray
            {
                currentSession.upload(NSURL(fileURLWithPath: getDocumentsDirectory().stringByAppendingPathComponent(individualObject)), path: "/public_html/APPLICATIONS/\(self.applicationCodeName.uppercaseString)/\(individualObject)")
                {
                    (result, error) -> Void in
                    
                    if error == nil
                    {
                        print("http://www.grantbrooksgoodman.io/APPLICATIONS/\(self.applicationCodeName.uppercaseString)/\(individualObject)")
                        self.removeItemFromDocumentsFolder(individualObject)
                        (UIApplication.sharedApplication().delegate as! AppDelegate).uploadedScreenShot = true
                        
                        self.uploadedScreenShot = true
                    }
                    else
                    {
                        print("There was an error while uploading the screenshot.")
                        print(error!.localizedDescription)
                        (UIApplication.sharedApplication().delegate as! AppDelegate).uploadedScreenShot = false
                        
                        self.uploadedScreenShot = false
                    }
                }
            }
            
            return screenShot
        }
        
        return UIImage()
    }
}

extension UIApplication
{
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController
        {
            if let selected = tab.selectedViewController
            {
                return topViewController(selected)
            }
        }
        
        if let presented = base?.presentedViewController
        {
            return topViewController(presented)
        }
        
        return base
    }
}
