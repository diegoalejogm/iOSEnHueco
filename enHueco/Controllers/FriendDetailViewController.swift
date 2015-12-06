//
//  ViewFriendViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 9/8/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class FriendDetailViewController: UIViewController, UIPopoverPresentationControllerDelegate, PopOverMenuViewControllerDelegate
{
    @IBOutlet weak var imageImageView: UIImageView!
    @IBOutlet weak var firstNamesLabel: UILabel!
    @IBOutlet weak var lastNamesLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var viewScheduleButton: UIButton!
    @IBOutlet weak var commonGapsButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
   
    @IBOutlet weak var gapStartOrEndHourIconImageView: UIImageView!
    
    var dotsBarButtonItem: UIBarButtonItem!
    
    var friend : User!

    var recordId : NSNumber?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = friend.firstNames
        
        gapStartOrEndHourIconImageView.image = gapStartOrEndHourIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        gapStartOrEndHourIconImageView.tintColor = UIColor.whiteColor()
        
        viewScheduleButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor
        commonGapsButton.backgroundColor = EHInterfaceColor.defaultBigRoundedButtonsColor
        
        firstNamesLabel.text = friend.firstNames
        lastNamesLabel.text = friend.lastNames
        userNameLabel.text = friend.username
        
        setRecordId()
        
        backgroundImageView.alpha = 0
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.imageImageView.sd_setImageWithURL(self.friend.imageURL)
            self.backgroundImageView.sd_setImageWithURL(self.friend.imageURL)
            { (_, error, _, _) -> Void in
                
                if error == nil
                {
                    UIView.animateWithDuration(0.4)
                    {
                        self.backgroundImageView.image = self.backgroundImageView.image!.applyBlurWithRadius(40,tintColor: UIColor(white: 0.2, alpha: 0.5), saturationDeltaFactor: 1.8, maskImage: nil)
                        self.backgroundImageView.alpha = 1
                    }
                    
                    self.updateButtonColors()
                }
            }
        }
        
        imageImageView.contentMode = .ScaleAspectFill
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        viewScheduleButton.clipsToBounds = true
        viewScheduleButton.layer.cornerRadius = viewScheduleButton.frame.height/2
        
        commonGapsButton.clipsToBounds = true
        commonGapsButton.layer.cornerRadius = viewScheduleButton.frame.height/2
        
        imageImageView.clipsToBounds = true
        imageImageView.layer.cornerRadius = imageImageView.frame.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        /*let animation = CATransition()
        animation.duration = 0
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        
        navigationController?.navigationBar.layer.addAnimation(animation, forKey: nil)
        
        UIView.animateWithDuration(0)
        {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)), forBarMetrics: .Default)
        }*/
        
        transitionCoordinator()?.animateAlongsideTransition({ (context) -> Void in
            
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)
            
        }, completion: { (context) -> Void in
            
            if !context.isCancelled()
            {
                UIView.animateWithDuration(0.3)
                {
                    self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor(red: 57/255.0, green: 57/255.0, blue: 57/255.0, alpha: 0.6)), forBarMetrics: .Default)
                }
            }
        })
        
        let dotsButton = UIButton(type: .Custom)
        dotsButton.frame.size = CGSize(width: 20, height: 20)
        dotsButton.setBackgroundImage(UIImage(named: "Dots")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        dotsButton.addTarget(self, action: Selector("dotsIconPressed:"), forControlEvents: .TouchUpInside)
        dotsButton.tintColor = UIColor.whiteColor()
        
        dotsBarButtonItem = UIBarButtonItem(customView: dotsButton)
        
        navigationItem.rightBarButtonItem = dotsBarButtonItem
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateButtonColors()
    {
        let averageImageColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(averageColorFromImage: imageImageView.image), isFlat: true, alpha: 0.4)
        
        UIView.animateWithDuration(0.8)
        {
            self.viewScheduleButton.backgroundColor = averageImageColor
            self.commonGapsButton.backgroundColor = averageImageColor
        }
    }
    
    func dotsIconPressed(sender: UIButton)
    {
        let menu = storyboard!.instantiateViewControllerWithIdentifier("PopOverMenuViewController") as! PopOverMenuViewController
        
        menu.titlesAndIcons = [("Llamar", UIImage(named: "Phone")!), ("WhatsApp", UIImage(named: "WhatsApp")!)]
        menu.tintColor = UIColor(white: 1, alpha: 0.8)
        menu.delegate = self
        
        menu.modalInPopover = true
        menu.modalPresentationStyle = .Popover
        menu.popoverPresentationController?.delegate = self
        menu.popoverPresentationController?.barButtonItem = dotsBarButtonItem
        menu.popoverPresentationController?.backgroundColor = UIColor(white: 0.80, alpha: 0.35)
        
        presentViewController(menu, animated: true, completion: nil)
        
        let actionSheet = AHKActionSheet()
        
        actionSheet.addButtonWithTitle("Llamar", image: UIImage(named: "Phone")?.imageWithRenderingMode(.AlwaysTemplate), type: .Default) { (_) -> Void in
            
            self.call(sender)
        }
        
        actionSheet.addButtonWithTitle("Whatsapp", image: UIImage(named: "Whatsapp")?.imageWithRenderingMode(.AlwaysTemplate), type: .Default) { (_) -> Void in
            
            self.whatsappMessage(sender)
        }
        
        //actionSheet.show()
    }
    
    func popOverMenuViewController(controller: PopOverMenuViewController, didSelectMenuItemAtIndex index: Int)
    {
        if let number = friend.phoneNumber where index == 0
        {
            system.callFriend(number)
        }
        else if let recordId = recordId where index == 1
        {
            system.whatsappMessageTo(recordId)
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    @IBAction func whatsappMessage(sender: UIButton)
    {
        system.whatsappMessageTo(self.recordId!)
    }
    
    @IBAction func viewSchedule(sender: UIButton)
    {
        let scheduleCalendar = storyboard?.instantiateViewControllerWithIdentifier("ScheduleViewController") as!ScheduleViewController
        scheduleCalendar.schedule = friend.schedule
        presentViewController(scheduleCalendar, animated: true, completion: nil)
    }
    
    @IBAction func commonGapsButtonPressed(sender: AnyObject)
    {
        let commonGapsViewController = storyboard?.instantiateViewControllerWithIdentifier("CommonGapsViewController") as!CommonGapsViewController
        commonGapsViewController.selectedFriends.append(friend)
      
        navigationController?.pushViewController(commonGapsViewController, animated: true)
    }

    @IBAction func call(sender: UIButton)
    {
        if let num = friend.phoneNumber
        {
            system.callFriend(num)
        }
    }

    func setRecordId()
    {
        if self.friend.phoneNumber.characters.count < 7
        {
            self.recordId = nil
        }
        else
        {
            system.getFriendABID(self.friend.phoneNumber,onSuccess:{ (abid) -> () in
            self.recordId = abid
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
