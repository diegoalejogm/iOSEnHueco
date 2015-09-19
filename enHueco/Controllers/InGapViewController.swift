//
//  InGapViewController.swift
//  enHueco
//
//  Created by Diego on 9/5/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class InGapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    var friendsAndGaps = [(friend: User, gap: Gap)]()
    var emptyLabel : UILabel?
    
    override func viewDidLoad()
    {
        tableView.dataSource = self
        tableView.delegate = self
        
        emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        emptyLabel!.text = "No tienes amigos en hueco"
        emptyLabel!.textColor = UIColor.grayColor()
        emptyLabel!.textAlignment = NSTextAlignment.Center
    }

    override func viewWillAppear(animated: Bool)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        friendsAndGaps = system.appUser.friendsCurrentlyInGap()
        tableView.reloadData()
        
        if friendsAndGaps.count == 0
        {
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        else
        {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            tableView.backgroundView = nil
            tableView.tableFooterView = UIView(frame: CGRectZero)
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if let selectedIndex = tableView.indexPathForSelectedRow
        {
            tableView.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

        return self.friendsAndGaps.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let friendAndGap = self.friendsAndGaps[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("InGapFriendCell") as! InGapFriendCell
        cell.friendNameLabel.text = friendAndGap.friend.name
        
        let globalCalendar = NSCalendar.currentCalendar()
        globalCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!
        
        let currentDate = NSDate()
        let gapEndHour = friendAndGap.gap.endHour
        let gapEndHourWithTodaysDate = globalCalendar.dateBySettingHour(gapEndHour.hour, minute: gapEndHour.minute, second: 0, ofDate: currentDate, options: NSCalendarOptions())!
        
        let timeLeftUntilNextEvent = gapEndHourWithTodaysDate - currentDate
        
        cell.timeLeftUntilNextEventLabel.text = "🕖 \(timeLeftUntilNextEvent.hour):\(timeLeftUntilNextEvent.minute) hrs"
        
        cell.friendImageImageView.clipsToBounds = true
        cell.friendImageImageView.layer.cornerRadius = cell.friendImageImageView.frame.height/2
                
        // TODO: Update InGapFriendCell image to match friend.
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let friend = system.appUser.friends[indexPath.row]
        let friendDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("FriendDetailViewController") as! FriendDetailViewController
        friendDetailViewController.friend = friend
        
        navigationController!.pushViewController(friendDetailViewController, animated: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        view.endEditing(true)
    }
}
