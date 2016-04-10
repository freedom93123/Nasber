//
//  NSDate.swift
//  ParseStarterProject
//
//  Created by FOEIT on 3/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))year"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))Month"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))week"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))day"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))hr"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))min" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))sec" }
        return ""
    }
}

extension NSDate : Comparable {}

//  To conform to Comparable, NSDate must also conform to Equatable.
//  Hence the == operator.
public func == (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}

public func > (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}

public func < (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

public func <= (lhs: NSDate, rhs: NSDate) -> Bool {
    return  lhs == rhs || lhs < rhs
}

public func >= (lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs == rhs || lhs > rhs
}