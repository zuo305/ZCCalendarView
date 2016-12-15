//
//  GLCalendarDayCellBackgroundCover.swift
//  ZCCalendarView
//
//  Created by john on 3/12/2015.
//  Copyright © 2015 john. All rights reserved.
//

import UIKit

enum RANGE_POSITION : NSInteger
{
    case RANGE_POSITION_NONE = 0
    case RANGE_POSITION_BEGIN = 1
    case RANGE_POSITION_MIDDLE = 2
    case RANGE_POSITION_END = 3
    case RANGE_POSITION_SINGLE = 4
}


let POINT_SCALE = 1.3

class ZCCalendarRangePoint : UIView
{
    init(size: CGFloat,borderWidth: CGFloat,strokeColor : UIColor)
    {
        super.init(frame: CGRectMake(0, 0, size, size))
        self.layer.borderColor = strokeColor.CGColor
        self.layer.borderWidth = borderWidth;
        self.layer.cornerRadius = size / 2;
        self.backgroundColor = UIColor.whiteColor()
        self.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ZCCalendarDayCellBackgroundCover: UIView {
    

    var paddingLeft : CGFloat?
    var paddingRight : CGFloat?
    var paddingTop : CGFloat?
    var fillcolor : UIColor?
    var strokeColor : UIColor?
    var backgroundImage : UIImageView?
    var borderWidth : CGFloat?
    var inEdit : Bool?
    var isToday : Bool?
    var continuousRangeDisplay : Bool?
    var pointSize : CGFloat?
    var pointScale : CGFloat?
    
    
    var rangePosition : RANGE_POSITION?
    
    var _beginPoint : ZCCalendarRangePoint?
    var beginPoint : ZCCalendarRangePoint  {
        if _beginPoint == nil
        {
            _beginPoint = ZCCalendarRangePoint(size: pointSize!, borderWidth: borderWidth!, strokeColor: strokeColor!)
            _beginPoint!.autoresizingMask = [.FlexibleBottomMargin,.FlexibleRightMargin,.FlexibleTopMargin ]
        }
        return _beginPoint!
    }
    
    var _endPoint : ZCCalendarRangePoint?
    var endPoint : ZCCalendarRangePoint{
        if _endPoint == nil
        {
            _endPoint = ZCCalendarRangePoint(size: pointSize!, borderWidth: borderWidth!, strokeColor: strokeColor!)
            _endPoint!.autoresizingMask = [.FlexibleBottomMargin,.FlexibleLeftMargin,.FlexibleTopMargin ]
        }
        return _endPoint!
        
        
    }
    
    
    

}
