//
//  ZCCalendarDateRange.swift
//  ZCCalendarView
//
//  Created by john on 2/12/2015.
//  Copyright © 2015 john. All rights reserved.
//

import UIKit

class ZCCalendarDateRange: NSObject , CustomDebugStringConvertible{
    
    var inEdit : Bool = false
    
    var beginDate : NSDate
    {
        didSet {
            beginDate = ZCDateUtils.cutDate(beginDate)
        }
    }
    var endDate : NSDate
    {
        didSet {
            endDate = ZCDateUtils.cutDate(endDate)
        }
    }
    
    override var debugDescription: String {
        return String(format: "Range[begin:%@ end:%@]", ZCDateUtils.descriptionForDate(beginDate),ZCDateUtils.descriptionForDate(endDate))
    }
    

    var editable :  Bool

    init(beginDate: NSDate,endDate: NSDate)
    {
        self.endDate = ZCDateUtils.cutDate(endDate)
        self.editable = true
        self.beginDate = ZCDateUtils.cutDate(beginDate)
        super.init()
    }
    
    static func rangeWithBeginDate(beginDate: NSDate,endDate: NSDate) -> ZCCalendarDateRange
    {
        return ZCCalendarDateRange(beginDate: beginDate, endDate: endDate)
    }
    
    func containsDate(date: NSDate) -> Bool
    {
        let d = ZCDateUtils.cutDate(date)
        if d.compare(self.beginDate) == .OrderedAscending
        {
            return false
        }
        
        if d.compare(self.endDate) == .OrderedDescending
        {
            return false
        }
        
        return true
    }
}
