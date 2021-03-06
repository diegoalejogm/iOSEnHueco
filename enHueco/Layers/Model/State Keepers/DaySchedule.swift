//
//  DaySchedule.swift
//  enHueco
//
//  Created by Diego Montoya on 8/13/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

/** 
 The schedule of a particular day. Contains the events of a given week day.
 DaySchedules are stored inside a Schedule object
 */
class DaySchedule: NSObject, NSCoding
{
    ///Localized weekday name
    let weekDayName: String
    
    private var mutableEvents = [Event]()
    
    override var description: String
    {
        return "\(weekDayName): \(mutableEvents.count) events"
    }
    
    var events:[Event]
    {
        get
        {
            return mutableEvents
        }
    }
    
    init(weekDayName:String)
    {
        self.weekDayName = weekDayName        
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let weekDayName = decoder.decodeObjectForKey("weekDayName") as? String,
            let mutableEvents = decoder.decodeObjectForKey("mutableEvents") as? [Event]
        else
        {
            return nil
        }
        
        self.weekDayName = weekDayName
        self.mutableEvents = mutableEvents
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(weekDayName, forKey: "weekDayName")
        coder.encodeObject(mutableEvents, forKey: "mutableEvents")
    }
    
    func setEvents(events: [Event])
    {
        mutableEvents = []
        
        for event in events
        {
            mutableEvents.insertInSortedArray(event)
        }
    }
   
    /// Returns true if event doesn't overlap with any gap or class, excluding eventToExclude.
    func canAddEvent(newEvent: Event, excludingEvent eventToExclude:Event? = nil) -> Bool
    {
        let currentDate = NSDate()
        
        let newEventStartHourInCurrentDate = newEvent.startHourInNearestPossibleWeekToDate(currentDate)
        let newEventEndHourInCurrentDate = newEvent.endHourInNearestPossibleWeekToDate(currentDate)
        
        for event in mutableEvents where eventToExclude == nil || event !== eventToExclude
        {
            let startHourInCurrentDate = event.startHourInNearestPossibleWeekToDate(currentDate)
            let endHourInCurrentDate = event.endHourInNearestPossibleWeekToDate(currentDate)
            
            if !(newEventEndHourInCurrentDate < startHourInCurrentDate || newEventStartHourInCurrentDate > endHourInCurrentDate)
            {
                return false
            }
        }
        
        return true
    }
        
    /// Adds event if it doesn't overlap with any other event
    func addEvent(newEvent: Event) -> Bool
    {
        if canAddEvent(newEvent)
        {
            mutableEvents.insertInSortedArray(newEvent)
            return true
        }
        return false
    }
    
    /**
        Adds all events if they don't overlap with any other event. The new events *must* not overlap with themselves, otherwise the method will not be
        able to add them all.
        
        - returns: True if all events could be added correctly
    */
    func addEvents(newEvents: [Event]) -> Bool
    {
        for newEvent in newEvents
        {
            if !addEvent(newEvent) { return false }
        }
        return true
    }
    
    func removeEvent(event: Event) -> Bool
    {
        return mutableEvents.removeObject(event)
    }
    
    func eventWithStartHour(startHour: NSDateComponents) -> Event?
    {
        return mutableEvents.filter { $0.startHour == startHour }.first
    }
}
