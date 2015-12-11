//
//  ZCDateUtils.swift
//  ZCCalendarView
//
//  Created by john on 6/11/2015.
//  Copyright © 2015 john. All rights reserved.
//

import UIKit


class ZCDateUtils: NSObject {

    static let CalName = "ZCCalendar"
    static var timezoneAbbreviation = ""
    static let CALENDAR_COMPONENTS : NSCalendarUnit = [.Year, .Month, .Day]
    static let months : [String] = NSDateFormatter().shortMonthSymbols
    static func date(date1: NSDate? ,isSameDayAsDate date2: NSDate?) -> Bool
    {
        if date1 == nil || date2 == nil
        {
            return false
        }
        
        let calendar = ZCDateUtils.calendar()
        let day1 = calendar.components(CALENDAR_COMPONENTS, fromDate: date1!)
        let day2 = calendar.components(CALENDAR_COMPONENTS, fromDate: date2!)
        
        return day2.day == day1.day && day2.month == day1.month &&  day2.year == day1.year
        
    }
    
    static func date(date1: NSDate? ,isEarlyDate date2 : NSDate?) -> Bool
    {
        if date1 == nil || date2 == nil
        {
            return false
        }
        
        let calendar = ZCDateUtils.calendar()
        let day1 = calendar.components(CALENDAR_COMPONENTS, fromDate: date1!)
        let day2 = calendar.components(CALENDAR_COMPONENTS, fromDate: date2!)

        if day1.year < day2.year
        {
            return true
        }
        else if day1.year == day2.year
        {
            if day1.month < day2.month
            {
                return true
            }
            else if day1.month == day2.month
            {
                if day1.day < day2.day
                {
                    return true
                }
                else
                {
                    return false
                }
            }
            else
            {
                return false
            }
            
            
        }
        else
        {
            return false
        }
        
        
    }
    
    static func changeTimeZoneAbbreviation(timezoneAbb : String)
    {
        timezoneAbbreviation = timezoneAbb
        let threadDictionary = NSThread.currentThread().threadDictionary
        if let _ = threadDictionary.objectForKey(CalName) as? NSCalendar
        {
            threadDictionary.removeObjectForKey(CalName)
        }
        
        self.calendar()
    }
    
    
    static func calendar() -> NSCalendar
    {
        let threadDictionary = NSThread.currentThread().threadDictionary
        if let cal : NSCalendar = threadDictionary.objectForKey(CalName) as? NSCalendar
        {
            return cal
        }
        else
        {
            let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)
            cal?.locale = NSLocale.currentLocale()
            if let timezone = NSTimeZone(abbreviation: timezoneAbbreviation)
            {
                cal?.timeZone = timezone
            }
            threadDictionary.setObject(cal!, forKey: CalName)
            return cal!
        }
    }
    
    static func weekFirstDate(date: NSDate) ->NSDate
    {
        let calendar = ZCDateUtils.calendar()
        let components = calendar.components(.Weekday, fromDate: date)
        let weekday = components.weekday
        if weekday == calendar.firstWeekday
        {
            return date
        }
        else
        {
            return ZCDateUtils.dateByAddingDays(calendar.firstWeekday - weekday, toDate: date)
        }
    }

    static func weekLastDate(date :  NSDate) -> NSDate
    {
        let calendar = ZCDateUtils.calendar()
        let components = calendar.components( .Weekday, fromDate: date)
        let weekday = components.weekday
        if weekday == ((calendar.firstWeekday + 5%7 ) + 1)  // firstWeekday + 6 (= 7 Saturday for US)
        {
            return date
        }
        else
        {
            return ZCDateUtils.dateByAddingDays(7 - weekday , toDate: date)
        }
        
    }
    

    static func monthFirstDate(date: NSDate)
    {
        let calendar = ZCDateUtils.calendar()
        let components = calendar.components(CALENDAR_COMPONENTS, fromDate: date)
        let result = NSDateComponents()
        result.day = 1
        result.month = components.month
        result.year = components.year
        result.hour = 12
        result.minute = 0
        result.second = 0
    }
    
    static func dateByAddingDays(days : NSInteger, toDate date: NSDate) -> NSDate
    {
        let calendar = ZCDateUtils.calendar()
        let comps = NSDateComponents()
        comps.day = days
        return calendar.dateByAddingComponents(comps, toDate: date, options: [])!
    }
    
    static func dateByAddingMonths(months: NSInteger,toDate date: NSDate) -> NSDate
    {
        let calendar = ZCDateUtils.calendar()
        let comps = NSDateComponents()
        comps.month = months
        return calendar.dateByAddingComponents(comps, toDate: date, options: [])!
    }

    static func cutDate(date:NSDate) -> NSDate
    {
        let calendar = ZCDateUtils.calendar()
        let components = calendar.components(CALENDAR_COMPONENTS, fromDate: date)
        return calendar.dateFromComponents(components)!
    }

    static func daysBetween(beginDate: NSDate ,and endDate: NSDate) -> NSInteger
    {
        let calendar = ZCDateUtils.calendar()
        let components = calendar.components(.Day, fromDate: beginDate, toDate: endDate, options: [])
        return components.day
    }

    static func  maxForDate(date1: NSDate,andDate date2 : NSDate) -> NSDate
    {
        if (date1.compare(date2)) == .OrderedAscending
        {
            return date2
        }
        else
        {
            return date1
        }
    }
    
    static func minForDate(date1 : NSDate, andDate date2 : NSDate) -> NSDate
    {
        if date1.compare(date2) == .OrderedAscending
        {
            return date1
        }
        else
        {
            return date2
        }
    }

    static func descriptionForDate(date: NSDate) -> String
    {
        let calendar = ZCDateUtils.calendar()
        let components = calendar.components(CALENDAR_COMPONENTS, fromDate: date)
        return String(format: "%ld/%ld/%ld", components.year, components.month,components.day)
    }
    
    static func monthText(month : NSInteger) -> String
    {
        return months[month-1]
    }
    
    
}
