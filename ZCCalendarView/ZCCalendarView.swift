//
//  ZCCalendarView.swift
//  ZCCalendarView
//
//  Created by john on 2/12/2015.
//  Copyright © 2015 john. All rights reserved.
//

import UIKit



enum GestureType  : NSInteger{
    case DragBegin = 0
    case DragEnd = 1
}

@objc protocol ZCCalendarViewDelegate
{
    func calenderView(calendarView : ZCCalendarView, canAddRangeWithBeginDate beginDate : NSDate) -> Bool
    func calenderView(calendarView : ZCCalendarView, rangeToAddWithBeginDate beginDate : NSDate) -> ZCCalendarDateRange
    func calenderView(calendarView : ZCCalendarView, beginToEditRange range : ZCCalendarDateRange)
    func calenderView(calendarView : ZCCalendarView, finishEditRange range : ZCCalendarDateRange ,continueEditing: Bool)
    func calenderView(calendarView : ZCCalendarView, canUpdateRange range : ZCCalendarDateRange ,toBeginDate beginDate:NSDate,endDate : NSDate) -> Bool
    func calenderView(calendarView : ZCCalendarView, didUpdateRange range : ZCCalendarDateRange ,toBeginDate beginDate:NSDate,endDate : NSDate)
    func calenderView(calendarView : ZCCalendarView, tipShowByBeginDate begindate : NSDate,enddate : NSDate)
    
    
    optional func  weekDayTitlesForCalendarView(calendarView :ZCCalendarView ) -> [String]
    
    
}

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}



class ZCCalendarView: UIView {

    var draggingBeginDate : Bool
    var draggingEndDate : Bool
    
    
    var showMagnifier : Bool
    
    let dragBeginDateGesture : UILongPressGestureRecognizer?
    let dragEndDateGesture : UILongPressGestureRecognizer?

    
    var _today : NSDate?
    var today : NSDate
    {
        get
        {
            if _today == nil
            {
                _today = ZCDateUtils.cutDate(self.todayDate)
            }
            return _today!
        }
    }
    
    weak var delegate : ZCCalendarViewDelegate?
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    @IBOutlet weak var magnifierContainer : UIView!
    
    @IBOutlet weak var maginifierContentView : UIImageView!
    
    @IBOutlet weak var weekDayTitle : UIView!
    
    
    weak var rangeUnderEdit : ZCCalendarDateRange?
    
    
    var cellWidth : CGFloat {
        get
        {
            return (CGRectGetWidth(self.bounds) - CGFloat(self.padding!) * 2) / 7
        }
    }
    
    
    var _firstDate : NSDate?
    var firstDate : NSDate {
        get
        {
            if _firstDate == nil
            {
                _firstDate =  ZCDateUtils.dateByAddingDays(-7, toDate: todayDate)
            }
            return _firstDate!
        }
        set(newValue)
        {
            _firstDate = ZCDateUtils.weekFirstDate(ZCDateUtils.cutDate(newValue))
        }
    }
    
    var _lastDate : NSDate?
    var lastDate : NSDate{
        get
        {
            if _lastDate == nil
            {
                _lastDate =  ZCDateUtils.dateByAddingDays(+365, toDate: todayDate)
            }
            return _lastDate!
        }
        set(newValue)
        {
            _lastDate = ZCDateUtils.weekLastDate(ZCDateUtils.cutDate(newValue))
        }
        
    }
    
    var todayDate : NSDate
    {
        get{
            return NSDate()
        }
    }
    
    lazy var ranges = [ZCCalendarDateRange]()
    
    lazy var calendar = ZCDateUtils.calendar()
    
    var padding : Float?
    var rowHeight : Float?
    
    var weekDayTitleAttributes : [String : NSObject]?
    var monthCoverAttributes : NSDictionary?
    
    
    let CELL_REUSE_IDENTIFIER = "DayCell"
    let DEFAULT_PADDING =  Float(6)
    let DEFAULT_ROW_HEIGHT = Float(54)
    
    override init(frame:CGRect)
    {
        super.init(frame: frame)
        self.commonInit()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit()
    {
        let array = NSBundle(forClass: self.dynamicType).loadNibNamed("ZCCalendarView", owner: self, options: nil)
        if let view = array.last as? UIView
        {
            view.frame = self.bounds;
            view.autoresizingMask = [ .FlexibleWidth , .FlexibleHeight]
            self.addSubview(view)
            self.setUp()
        }
    }
    
    func setUp()
    {
        self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let nib = UINib(nibName: "GLCalendarDayCell", bundle: NSBundle(forClass: self.dynamicType))
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: CELL_REUSE_IDENTIFIER)
        
        
    
        let dragBeginDateGesture = UILongPressGestureRecognizer(target: self, action: "handleDragBeginDate:")
        let dragEndDateGesture = UILongPressGestureRecognizer(target: self, action: "handleDragEndDate:")
    
        dragBeginDateGesture.delegate = self
        dragEndDateGesture.delegate = self
    
        dragBeginDateGesture.minimumPressDuration = 0.05;
        dragEndDateGesture.minimumPressDuration = 0.05;
    
        self.collectionView.addGestureRecognizer(dragBeginDateGesture)
        self.collectionView.addGestureRecognizer(dragEndDateGesture)
    
        self.addSubview(magnifierContainer)
        self.magnifierContainer.hidden = true
    
        self.reloadAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupWeekDayTitle()
    }
    
    func setupWeekDayTitle()
    {
        self.weekDayTitle.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        let width = (CGRectGetWidth(self.bounds) - CGFloat(self.padding! * 2)) / 7
        let centerY = self.weekDayTitle.bounds.size.height / 2
        var titles = [String]()

        
        if ((self.delegate?.weekDayTitlesForCalendarView?(self)) != nil)
        {
            titles = (self.delegate?.weekDayTitlesForCalendarView!(self))!
        }
        else
        {
            titles = self.calendar.shortStandaloneWeekdaySymbols
        }
        
        let firstWeekDayIdx = self.calendar.firstWeekday - 1
        if firstWeekDayIdx > 0
        {
            let post = Array(titles[firstWeekDayIdx...7-firstWeekDayIdx])
            let pre = Array(titles[0...firstWeekDayIdx])
            titles = post + pre
        }
        
        for i in 0...titles.count
        {
            let label = UILabel(frame: CGRectMake(0,0,width,20))
            label.textAlignment = .Center
            label.attributedText = NSAttributedString(string: titles[i], attributes: self.weekDayTitleAttributes)
            label.center = CGPointMake(CGFloat(self.padding!) + CGFloat(i) * width + width / 2, centerY)
            self.weekDayTitle.addSubview(label)
        }
        

    }
    

    func reloadAppearance()
    {
        let appearance = self.dynamicType.appearance()
        
        if let value =  appearance.padding
        {
            self.padding = value
        }
        else
        {
            self.padding = DEFAULT_PADDING
        }

        if let height = appearance.rowHeight
        {
            self.rowHeight = height
        }
        else
        {
            self.rowHeight = DEFAULT_ROW_HEIGHT
        }
        
        if let value = appearance.weekDayTitleAttributes
        {
            self.weekDayTitleAttributes = value
        }
        else
        {
            self.weekDayTitleAttributes =  [NSFontAttributeName:UIFont.systemFontOfSize(CGFloat(8)),NSForegroundColorAttributeName:UIColor.grayColor()]

        }
        
        
    }
    
    func reload()
    {
        self.collectionView.reloadData()
    }
    
    func addRange(range: ZCCalendarDateRange)
    {
        self.ranges.append(range)
        self.reloadFromBeginDate(range.beginDate, toDate: range.endDate)
    }
    
    func removeRange(range : ZCCalendarDateRange)
    {
        self.ranges.removeObject(range)
        self.reloadFromBeginDate(range.beginDate, toDate: range.endDate)
    }

    func updateRange(range : ZCCalendarDateRange,withBeginDate beginDate: NSDate,endDate : NSDate)
    {
        let beginDateToReload = ZCDateUtils.minForDate(range.beginDate, andDate: beginDate).copy()
        let endDateToReload = ZCDateUtils.minForDate(range.endDate, andDate: endDate).copy()
        range.beginDate = beginDate
        range.endDate = endDate
        self.reloadFromBeginDate(beginDateToReload as! NSDate, toDate: endDateToReload as! NSDate)
    }
    
    func forceFinishEdit()
    {
        self.rangeUnderEdit?.inEdit = false
        self.reloadFromBeginDate((self.rangeUnderEdit?.beginDate)!, toDate: (self.rangeUnderEdit?.endDate)!)
        self.rangeUnderEdit = nil
    }
    
    func scrollToDate(date : NSDate , animated : Bool)
    {
        let item = ZCDateUtils.daysBetween(self.firstDate, and: date)
        let indexPath = NSIndexPath(forItem: item, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
    }

    
    
    func dateAtLocation(location : CGPoint) -> NSDate
    {
        return self.dateForCellAtIndexPath(self.indexPathAtLocation(location))
    }
    
    
    func indexPathAtLocation(location: CGPoint) -> NSIndexPath
    {
        let row = location.y / CGFloat(self.rowHeight!)
        let col = (location.x - CGFloat(self.padding!)) / self.cellWidth
        let item = row * 7 + floor(col)
        return NSIndexPath(forItem: Int(item), inSection: 0)
    }
    
    func rectForDate(date : NSDate)  -> CGRect
    {
        let dayDiff = ZCDateUtils.daysBetween(self.firstDate, and: date)
        let row = dayDiff / 7
        let col = dayDiff % 7
        
        let ox = CGFloat(self.padding!) + CGFloat(col) * self.cellWidth
        let oy = CGFloat(row) * CGFloat(self.rowHeight!)
        let width = self.cellWidth
        let height = CGFloat(self.rowHeight!)
        
        return CGRectMake(ox, oy, width, height)
    }
    

    func reloadCellOnDate(date : NSDate)
    {
        self.reloadFromBeginDate(date , toDate: date)
    }
    
    
    func reloadFromBeginDate(beginDate : NSDate,toDate endDate : NSDate)
    {
        var indexPaths = [NSIndexPath]()
        let beginIndex = max(0, ZCDateUtils.daysBetween(self.firstDate, and: beginDate))
        let endinIndex = min(self.collectionView.numberOfItemsInSection(0) - 1, ZCDateUtils.daysBetween( self.firstDate, and: endDate))
        
        for i in beginIndex...endinIndex
        {
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        
        if indexPaths.count > 30
        {
            self.collectionView.reloadData()
        }
        else
        {
            UIView.performWithoutAnimation({ () -> Void in
                self.collectionView.reloadItemsAtIndexPaths(indexPaths)
            })
        }
    }
    
    func indexPathForDate(date : NSDate) -> NSIndexPath
    {
        return NSIndexPath(forItem: ZCDateUtils.daysBetween(self.firstDate, and: date), inSection: 0)
    }
    
    func showMagnifierAboveDate(date : NSDate)
    {
        if self.showMagnifier == false
        {
            return
        }
        
        let cell = self.collectionView(self.collectionView, cellForItemAtIndexPath: self.indexPathForDate(date))
        var delta = self.cellWidth / 2
        if self.draggingBeginDate
        {
//            delta = delta
        }
        else
        {
            delta = -delta
        }
        UIGraphicsBeginImageContextWithOptions(maginifierContentView.frame.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, self.maginifierContentView.bounds);
        CGContextTranslateCTM(context, -cell.center.x + delta, -cell.center.y);
        CGContextTranslateCTM(context, self.maginifierContentView.frame.size.width / 2, self.maginifierContentView.frame.size.height / 2);
        
        self.collectionView.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.maginifierContentView.image = image;
        self.magnifierContainer.center = self.convertPoint(CGPointMake(cell.center.x - delta - 58 ,cell.center.y - 90 ), fromView: self.collectionView)
        self.magnifierContainer.hidden = false
        
    }

    func hideMagnifier()
    {
        if self.showMagnifier == false
        {
            return
        }
        self.magnifierContainer.hidden = false
    }

}

extension ZCCalendarView : UIGestureRecognizerDelegate
{
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.rangeUnderEdit == nil
        {
            return false
        }
        
        if gestureRecognizer == dragBeginDateGesture
        {
            let location = gestureRecognizer.locationInView(self.collectionView)
            var rectForBeginDate = self.rectForDate(self.rangeUnderEdit!.beginDate)
            rectForBeginDate.origin.x -= self.cellWidth / 2
            if CGRectContainsPoint(rectForBeginDate, location)
            {
                return true
            }
        }
        else if gestureRecognizer == dragEndDateGesture
        {
            let location = gestureRecognizer.locationInView(self.collectionView)
            var rectForEndDate = self.rectForDate(self.rangeUnderEdit!.endDate)
            rectForEndDate.origin.x += self.cellWidth / 2
            if CGRectContainsPoint(rectForEndDate, location)
            {
                return true
            }
        }
        
        
        return false
    }
    
    func handleDragBeginDate(recognizer : UIPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            self.draggingBeginDate = true
            self.reloadCellOnDate(self.rangeUnderEdit!.beginDate)
            self.showMagnifierAboveDate((self.rangeUnderEdit?.beginDate)!)
            return
            
        }
        if recognizer.state == UIGestureRecognizerState.Ended
        {
            self.draggingBeginDate = false
            self.hideMagnifier()
            self.reloadCellOnDate((self.rangeUnderEdit?.beginDate)!)
            return
        }
        let location = recognizer.locationInView(self.collectionView)
        if location.y <= self.collectionView.contentOffset.y
        {
            return
        }
        
        let date = self.dateAtLocation(location)

        if ZCDateUtils.date(self.rangeUnderEdit?.beginDate, isSameDayAsDate: date)
        {
            return
        }

        if self.rangeUnderEdit?.endDate.compare(date) == .OrderedAscending
        {
            return
        }
        
        let canUpdate = self.delegate?.calenderView(self, canUpdateRange: self.rangeUnderEdit!, toBeginDate: date, endDate: (self.rangeUnderEdit?.endDate)!)

        if canUpdate == true
        {
            let originalBeginDate = self.rangeUnderEdit?.beginDate.copy() as! NSDate
            self.rangeUnderEdit?.beginDate = date
            
            if originalBeginDate.compare(date) == .OrderedAscending
            {
                self.reloadFromBeginDate(originalBeginDate, toDate: date)
            }
            else
            {
                self.reloadFromBeginDate(date, toDate: originalBeginDate)
            }
            
            self.showMagnifierAboveDate((self.rangeUnderEdit?.beginDate)!)
            self.delegate?.calenderView(self, didUpdateRange: self.rangeUnderEdit!, toBeginDate: date, endDate: (self.rangeUnderEdit?.endDate)!)
        }
        
    }
    
    
    
    func handleDragEndDate(recognizer : UIPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            self.draggingEndDate = true
            self.reloadCellOnDate((self.rangeUnderEdit?.endDate)!)
            self.showMagnifierAboveDate((self.rangeUnderEdit?.endDate)!)
            return
        }
        
        if recognizer.state == UIGestureRecognizerState.Ended
        {
            self.draggingEndDate = false
            self.hideMagnifier()
            self.reloadCellOnDate((self.rangeUnderEdit?.endDate)!)
            return
        }
        
        let location = recognizer.locationInView(self.collectionView)
        if location.y <= self.collectionView.contentOffset.y {
            return
        }
        
        let date = self.dateAtLocation(location)
        if ZCDateUtils.date(self.rangeUnderEdit?.endDate, isSameDayAsDate: date)
        {
            return
        }
        
        if date.compare((self.rangeUnderEdit?.beginDate)!) == .OrderedAscending
        {
            return
        }
        
        let canUpdate = self.delegate?.calenderView(self, canUpdateRange: self.rangeUnderEdit!, toBeginDate: self.rangeUnderEdit!.beginDate , endDate: date)

        if canUpdate == true
        {
            let originalEndDate = self.rangeUnderEdit?.endDate.copy() as! NSDate!
            self.rangeUnderEdit?.endDate = date
            if originalEndDate.compare(date) == .OrderedAscending
            {
                self.reloadFromBeginDate(originalEndDate, toDate: date)
            }
            else
            {
                self.reloadFromBeginDate(date, toDate: originalEndDate)
            }
            self.showMagnifierAboveDate((self.rangeUnderEdit?.endDate)!)
            self.delegate?.calenderView(self, didUpdateRange: self.rangeUnderEdit!, toBeginDate: (self.rangeUnderEdit?.beginDate)!, endDate: date)
        }
        
    }


    
    
    
  
    

}

extension ZCCalendarView : UICollectionViewDelegate ,UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ZCDateUtils.daysBetween(self.firstDate, and: self.lastDate) + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
//        GLCalendarDayCell *cell = (GLCalendarDayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSE_IDENTIFIER forIndexPath:indexPath];
//        
//        CELL_POSITION cellPosition;
//        ENLARGE_POINT enlargePoint;
//        
//        NSInteger position = indexPath.item % 7;
//        if (position == 0) {
//            cellPosition = POSITION_LEFT_EDGE;
//        } else if (position == 6) {
//            cellPosition = POSITION_RIGHT_EDGE;
//        } else {
//            cellPosition = POSITION_NORMAL;
//        }
//        
//        NSDate *date = [self dateForCellAtIndexPath:indexPath];
//        if (self.draggingBeginDate && [GLDateUtils date:self.rangeUnderEdit.beginDate isSameDayAsDate:date]) {
//            enlargePoint = ENLARGE_BEGIN_POINT;
//        } else if (self.draggingEndDate && [GLDateUtils date:self.rangeUnderEdit.endDate isSameDayAsDate:date]) {
//            enlargePoint = ENLARGE_END_POINT;
//        } else {
//            enlargePoint = ENLARGE_NONE;
//        }
//        cell.calendarView = self;
//        cell.popTipView = self.popTipView;
//        [cell setDate:date range:[self selectedRangeForDate:date] cellPosition:cellPosition enlargePoint:enlargePoint];
//        
//        return cell;
        return nil

    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
    }
    

    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    
    {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake(self.cellWidth, CGFloat(self.rowHeight!));
        
    }
    
    
    func initRangUnderEdit(range : ZCCalendarDateRange)
    {
        self.rangeUnderEdit = range
        self.rangeUnderEdit?.inEdit = true
    }
    
    func  beginToEditRange(range: ZCCalendarDateRange)
    {
        self.rangeUnderEdit = range
        self.rangeUnderEdit?.inEdit = true
        self.reloadFromBeginDate((self.rangeUnderEdit?.beginDate)!, toDate: (self.rangeUnderEdit?.endDate)!)
        self.delegate?.calenderView(self, beginToEditRange: range)
    }
    
    func finishEditRange(range: ZCCalendarDateRange , continueEditing : Bool)
    {
        self.rangeUnderEdit?.inEdit = false
        self.reloadFromBeginDate((self.rangeUnderEdit?.beginDate)!, toDate: (self.rangeUnderEdit?.endDate)!)
        self.delegate?.calenderView(self, finishEditRange: self.rangeUnderEdit!, continueEditing: continueEditing)
    }
    
    
    func dateForCellAtIndexPath(indexPath : NSIndexPath) -> NSDate
    {
        return ZCDateUtils.dateByAddingDays(indexPath.item, toDate: self.firstDate)
    }
    
    func selectedRangeForDate(date : NSDate ) -> ZCCalendarDateRange?
    {
        for range in self.ranges
        {
            if range.containsDate(date)
            {
                return range
            }
        }
        
        return nil
        
    }
    
    

    
  }
