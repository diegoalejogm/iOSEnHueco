//
//  BasicEvent.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/17/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome
import PureJsonSerializer

/// The type of the event

enum EventType: String {
    case FreeTime = "FREE_TIME", Class = "CLASS"
}

class BaseEvent: MappableObject {

    struct JSONKeys {
        private init() {}

        static let type = "type"
        static let name = "name"
        static let startDate = "start_date"
        static let endDate = "end_date"
        static let location = "location"
        static let repeating = "repeating"
    }

    let type: EventType
    let name: String?
    let startDate: NSDate
    let endDate: NSDate
    let location: String?
    let repeating: Bool

    init(type: EventType, name: String?, location: String?, startDate: NSDate, endDate: NSDate, repeating: Bool) {

        self.type = type
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.repeating = repeating
    }

    required init(map: Map) throws {
        
        type = try map.extract(.Key(JSONKeys.type), transformer: GenomeTransformers.fromJSON)
        name = try? map.extract(.Key(JSONKeys.name))
        startDate = try map.extract(.Key(JSONKeys.startDate), transformer: GenomeTransformers.fromJSON)
        endDate = try map.extract(.Key(JSONKeys.endDate), transformer: GenomeTransformers.fromJSON)
        location = try? map.extract(.Key(JSONKeys.location))
        repeating = try map.extract(.Key(JSONKeys.repeating))
    }
    
    static func newInstance(json: Json, context: Context) throws -> Self {
        let map = Map(json: json, context: context)
        let new = try self.init(map: map)
        return new
    }
    
    /** Returns the start hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     
     If the event is unique (i.e. non-repeating), the startDate is returned unchanged.
     */
    func startDateInNearestPossibleWeekToDate(targetDate: NSDate) -> NSDate  {

        guard repeating else { return startDate }
        return date(startDate, inNearestPossibleWeekToDate: targetDate)
    }
    
    /** Returns the end hour (Weekday, Hour, Minute) by setting the components to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     
     If the event is unique (i.e. non-repeating), the endDate is returned unchanged.
     */
    func endDateInNearestPossibleWeekToDate(targetDate: NSDate) -> NSDate  {

        guard repeating else { return endDate }
        
        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        var endHourDate = date(endDate, inNearestPossibleWeekToDate: targetDate)
        
        if endHourDate < startDateInNearestPossibleWeekToDate(targetDate) {
            endHourDate = globalCalendar.dateByAddingUnit(.WeekOfMonth, value: 1, toDate: endHourDate, options: [])!
        }
        
        return endHourDate
    }
    
    /** Returns a date by setting the components (Weekday, Hour, Minute) provided to the date of the nearest
     possible week to the date provided. The nearest possible week can be the week of the date provided itself, or the next
     one given that the weekday of the event doesn't exist for the week of the month of the date provided.
     */
    private func date(date: NSDate, inNearestPossibleWeekToDate targetDate: NSDate) -> NSDate  {

        let globalCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        globalCalendar.timeZone = NSTimeZone(name: "UTC")!
        
        let eventComponents = globalCalendar.components([.Weekday, .Hour, .Minute], fromDate: date)
        
        var startOfWeek: NSDate?
        
        globalCalendar.rangeOfUnit(.WeekOfMonth, startDate: &startOfWeek, interval: nil, forDate: targetDate)
        
        let componentsToAdd = NSDateComponents()
        componentsToAdd.day = eventComponents.weekday-1
        componentsToAdd.hour = eventComponents.hour
        componentsToAdd.minute = eventComponents.minute
        
        return globalCalendar.dateByAddingComponents(componentsToAdd, toDate: startOfWeek!, options: [])!
    }
    
    /// Returns true iff the event overlaps with another.
    func overlapsWith(anotherEvent: BaseEvent) -> Bool {
        
        let currentDate = NSDate()
        
        let anotherEventStartHourInCurrentDate = anotherEvent.startDateInNearestPossibleWeekToDate(currentDate)
        let anotherEventEndHourInCurrentDate = anotherEvent.endDateInNearestPossibleWeekToDate(currentDate)
        
        let startHourInCurrentDate = startDateInNearestPossibleWeekToDate(currentDate)
        let endHourInCurrentDate = endDateInNearestPossibleWeekToDate(currentDate)
            
        return !(anotherEventEndHourInCurrentDate < startHourInCurrentDate || anotherEventStartHourInCurrentDate > endHourInCurrentDate)
    }
}
