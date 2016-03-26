//
//  SettingsTableViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 11/3/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class SettingsEmbeddedTableViewController: UITableViewController, UIAlertViewDelegate
{
    @IBOutlet weak var changeProfilePictureCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var authTouchIDSwitch: UISwitch!
    @IBOutlet weak var nearbyFriendsNotificationsSwitch: UISwitch!
    @IBOutlet weak var phoneNumberCell: UITableViewCell!
    
    //Temporary
    @IBOutlet weak var lastBackgroundFetchDateLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Ajustes"
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .BlackTranslucent
        navigationController?.navigationBar.barTintColor = EHInterfaceColor.defaultNavigationBarColor
        
        clearsSelectionOnViewWillAppear = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsEmbeddedTableViewController.didReceiveAppUserWasUpdated(_:)), name: EHSystemNotification.SystemDidReceiveAppUserWasUpdated, object: enHueco)
        
        authTouchIDSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.authTouchID)
        nearbyFriendsNotificationsSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
        phoneNumberCell.textLabel?.text = enHueco.appUser.phoneNumber
        
        let lastBackgroundUpdate = NSDate(timeIntervalSince1970: NSUserDefaults.standardUserDefaults().doubleForKey("lastBackgroundUpdate")).descriptionWithLocale(NSLocale.currentLocale())
        let lastBackgroundUpdateResponse = NSDate(timeIntervalSince1970: NSUserDefaults.standardUserDefaults().doubleForKey("lastBackgroundUpdateResponse")).descriptionWithLocale(NSLocale.currentLocale())
        
        //lastBackgroundFetchDateLabel.text = "Last background fetch: \(lastBackgroundUpdate). Last response: \(lastBackgroundUpdateResponse)"
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject)
    {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func nearbyFriendsNotificationsToggleChanged(sender: AnyObject)
    {
        NSUserDefaults.standardUserDefaults().setBool(nearbyFriendsNotificationsSwitch.on, forKey: EHUserDefaultsKeys.nearbyCloseFriendsNotifications)
        
        ProximityUpdatesManager.sharedManager().updateBackgroundFetchInterval()
    }
    
    @IBAction func authenticateWithTIDChanged(sender: UISwitch)
    {
        var isOn = NSUserDefaults.standardUserDefaults().boolForKey(EHUserDefaultsKeys.authTouchID)
        isOn = !isOn
        
        NSUserDefaults.standardUserDefaults().setBool(isOn, forKey: EHUserDefaultsKeys.authTouchID)
        
        authTouchIDSwitch.on = isOn
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell ==  logoutCell
        {
            logout()
        }
        else if cell == phoneNumberCell
        {
            let alertView = UIAlertView(title: "Teléfono", message: "Agrega un nuevo número de teléfono", delegate: self, cancelButtonTitle: "Cancelar", otherButtonTitles: "Agregar")
            alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alertView.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.PhonePad
            alertView.show()
        }
        else if cell == changeProfilePictureCell
        {
            let importPictureController = storyboard?.instantiateViewControllerWithIdentifier("ImportProfileImageViewController") as! ImportProfileImageViewController
            importPictureController.delegate = self
            
            presentViewController(importPictureController, animated: true, completion: nil)
        }
    }
    
    func logout()
    {
        /*The actual logout will be done by the login view controller. We do this this way becase there seems to be a bug in iOS. 
         We are calling dismissViewController from the presenting controller that is first in the controller stack (i.e. AppDelegate.mainNavigationController).
         As a consequence, all intermediate controllers will also be dismissed behind the scenes.
         
         From Apple docs:
         
         "If you present several view controllers in succession, thus building a stack of presented view controllers, calling this method on a view controller lower 
         in the stack dismisses its immediate child view controller and all view controllers above that child on the stack. When this happens, only the top-most view 
         is dismissed in an animated fashion; any intermediate view controllers are simply removed from the stack. The top-most view is dismissed using its modal transition 
         style, which may differ from the styles used by other view controllers lower in the stack."
         
         The problem is that view(Will/Did)Appear is being called on all intermediate controllers without them ever appearing on screen, causing unexpected behavior if
         we did the actual logout procedure here*/

        (UIApplication.sharedApplication().delegate as! AppDelegate).mainNavigationController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        phoneNumberCell.setSelected(false, animated: true)
        if let newNumber = alertView.textFieldAtIndex(0)?.text where !newNumber.isEmpty
        {
            enHueco.appUser.phoneNumber = newNumber
            enHueco.appUser.pushPhoneNumber(newNumber)
        }
    }
    
    func didReceiveAppUserWasUpdated(notification : NSNotification)
    {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.phoneNumberCell.textLabel?.text = enHueco.appUser.phoneNumber
        }, completion: nil)
    }
}

extension SettingsEmbeddedTableViewController: ImportProfileImageViewControllerDelegate
{
    func importProfileImageViewControllerDidFinishImportingImage(controller: ImportProfileImageViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}