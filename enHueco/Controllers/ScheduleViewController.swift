//
//  ScheduleViewController.swift
//  enHueco
//
//  Created by Diego on 9/12/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController
{
    @IBOutlet weak var topBarBackgroundView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var importCalendarButton: UIButton!
    
    /**
     Schedule to be displayed. Defaults to AppUser's
     */
    var schedule: Schedule = system.appUser.schedule
    
    ///Reference to the embeded calendar view controller
    var scheduleCalendarViewController: ScheduleCalendarViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        topBarBackgroundView.backgroundColor = EHIntefaceColor.defaultTopBarsColor
        closeButton.titleLabel?.textColor = EHIntefaceColor.defaultEmbededTopBarButtonsColor
        importButton.titleLabel?.textColor = EHIntefaceColor.defaultEmbededTopBarButtonsColor
        addEventButton.titleLabel?.textColor = EHIntefaceColor.defaultEmbededTopBarButtonsColor
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        addEventButton.clipsToBounds = true
        addEventButton.layer.cornerRadius = addEventButton.frame.size.height/2
    }
    
    override func viewWillAppear(animated: Bool)
    {
        navigationController?.navigationBarHidden = true
       
        if schedule !== system.appUser.schedule
        {
            importCalendarButton.hidden = true
            addEventButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if schedule === system.appUser.schedule
        {
            becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool
    {
        return schedule === system.appUser.schedule
    }
    
    ///Gives the ability to undo and redo the actions.
    func registerAddedEventsForUndo(eventsAdded: [Event])
    {
        undoManager!.registerUndoWithTarget(self, selector: Selector("deleteEvents:"), object: eventsAdded)
        
        if !undoManager!.undoing
        {
            undoManager!.setActionName("Agregar Eventos")
        }
        
        scheduleCalendarViewController.reloadData()
    }
    
    func registerEditedEventForUndo(eventToEdit: Event)
    {
        //TODO:
    }
    
    ///Gives the ability to undo and redo the actions.
    func registerDeletedEventsForUndo(eventsDeleted: [Event])
    {
        undoManager!.registerUndoWithTarget(self, selector: Selector("addEvents:"), object: eventsDeleted)
        
        if !undoManager!.undoing
        {
            undoManager!.setActionName("Borrar Eventos")
        }
        
        scheduleCalendarViewController.reloadData()
    }
    
    @IBAction func importScheduleButtonPressed(sender: AnyObject)
    {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("SelectCalendarViewController") as! SelectCalendarViewController
        navigationController!.pushViewController(controller, animated: true)
    }
    
    @IBAction func cancel(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let controller = segue.destinationViewController as? ScheduleCalendarViewController
        {
            scheduleCalendarViewController = controller
            controller.schedule = schedule
        }
        else if let controller = segue.destinationViewController as? AddEditEventViewController
        {
            controller.scheduleViewController = self
        }
    }
}
