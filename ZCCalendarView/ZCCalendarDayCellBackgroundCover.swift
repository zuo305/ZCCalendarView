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


class GLCalendarDayCellBackgroundCover: UIView {
    
    var rangePosition : RANGE_POSITION
    var paddingLeft : CGFloat
    var paddingRight : CGFloat
    @property (nonatomic) CGFloat paddingTop;
    @property (nonatomic, strong) UIColor *fillColor;
    @property (nonatomic, strong) UIColor *strokeColor;
    @property (nonatomic, strong) UIImage *backgroundImage;
    @property (nonatomic) CGFloat borderWidth;
    @property (nonatomic) BOOL inEdit;
    @property (nonatomic) BOOL isToday;
    @property (nonatomic) BOOL continuousRangeDisplay;
    @property (nonatomic) CGFloat pointSize;
    @property (nonatomic) CGFloat pointScale;
    
    var _beginPoint : ZCCalendarRangePoint?
    var beginPoint : ZCCalendarRangePoint {
//        _beginPoint = [[GLCalendarRangePoint alloc] initWithSize:self.pointSize borderWidth:self.borderWidth strokeColor:self.strokeColor];
//        _beginPoint.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
//
        get{
            if self._beginPoint == nil
            {
                let Point = ZCCalendarRangePoint(size: self.pointSize, borderWidth: self.borderWidth, strokeColor: UIColor)
                
            }
        
        
        
            return nil
        }
    }
    

}
