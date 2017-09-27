//
//  Date+Mix.swift
//  Mix
//
//  Created by Maxwell on 07/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

public extension DateComponents {
    var ago: Date? {
        return Calendar.current.date(byAdding: -self, to: Date())
    }
    
    var later: Date? {
        return Calendar.current.date(byAdding: self, to: Date())
    }
    
    /// Creates inverse `DateComponents`
    ///
    /// - parameter rhs: A `DateComponents`
    ///
    /// - returns: A created inverse `DateComponents`
    static prefix func -(rhs: DateComponents) -> DateComponents {
        var dateComponents = DateComponents()
        
        if let year = rhs.year {
            dateComponents.year = -year
        }
        
        if let month = rhs.month {
            dateComponents.month = -month
        }
        
        if let day = rhs.day {
            dateComponents.day = -day
        }
        
        if let hour = rhs.hour {
            dateComponents.hour = -hour
        }
        
        if let minute = rhs.minute {
            dateComponents.minute = -minute
        }
        
        if let second = rhs.second {
            dateComponents.second = -second
        }
        
        if let nanosecond = rhs.nanosecond {
            dateComponents.nanosecond = -nanosecond
        }
        
        return dateComponents
    }
    
    /// Creates a instance calculated by the addition of `right` and `left`
    ///
    /// - parameter left:  The date components at left side.
    /// - parameter right: The date components at right side.
    ///
    /// - returns: Created `DateComponents` instance.
    static func + (left: DateComponents, right: DateComponents) -> DateComponents {
        var dateComponents = left
        
        if let year = right.year {
            dateComponents.year = (dateComponents.year ?? 0) + year
        }
        
        if let month = right.month {
            dateComponents.month = (dateComponents.month ?? 0) + month
        }
        
        if let day = right.day {
            dateComponents.day = (dateComponents.day ?? 0) + day
        }
        
        if let hour = right.hour {
            dateComponents.hour = (dateComponents.hour ?? 0) + hour
        }
        
        if let minute = right.minute {
            dateComponents.minute = (dateComponents.minute ?? 0) + minute
        }
        
        if let second = right.second {
            dateComponents.second = (dateComponents.second ?? 0) + second
        }
        
        if let nanosecond = right.nanosecond {
            dateComponents.nanosecond = (dateComponents.nanosecond ?? 0) + nanosecond
        }
        
        return dateComponents
    }
    
    /// Creates a instance calculated by the subtraction from `right` to `left`
    ///
    /// - parameter left:  The date components at left side.
    /// - parameter right: The date components at right side.
    ///
    /// - returns: Created `DateComponents` instance.
    static func - (left: DateComponents, right: DateComponents) -> DateComponents {
        return left + (-right)
    }
    
    /// Creates a `String` instance representing the receiver formatted in given units style.
    ///
    /// - parameter unitsStyle: The units style.
    ///
    /// - returns: The created a `String` instance.
    @available(OSX 10.10, *)
    public func string(in unitsStyle: DateComponentsFormatter.UnitsStyle) -> String? {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = unitsStyle
        dateComponentsFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second, .nanosecond]
        
        return dateComponentsFormatter.string(from: self)
    }
}

public extension Date {
    
    /// isToday
    public var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    ///
    public var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    ///
    public var isThisYear: Bool {
        return Date.today().year == year
    }
    
    /// The year.
    public var year: Int {
        return dateComponents.year!
    }
    
    /// The month.
    public var month: Int {
        return dateComponents.month!
    }
    
    /// The day.
    public var day: Int {
        return dateComponents.day!
    }
    
    /// The hour.
    public var hour: Int {
        return dateComponents.hour!
    }
    
    /// The minute.
    public var minute: Int {
        return dateComponents.minute!
    }
    
    /// The second.
    public var second: Int {
        return dateComponents.second!
    }
    
    /// The nanosecond.
    public var nanosecond: Int {
        return dateComponents.nanosecond!
    }
    
    /// The weekday.
    public var weekday: Int {
        return dateComponents.weekday!
    }
    
    private var dateComponents: DateComponents {
        return calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday], from: self)
    }
    
    // Returns user's calendar to be used to return `DateComponents` of the receiver.
    private var calendar: Calendar {
        return .current
    }
    
    /// Creates a new instance with specified date components.
    ///
    /// - parameter era:        The era.
    /// - parameter year:       The year.
    /// - parameter month:      The month.
    /// - parameter day:        The day.
    /// - parameter hour:       The hour.
    /// - parameter minute:     The minute.
    /// - parameter second:     The second.
    /// - parameter nanosecond: The nanosecond.
    /// - parameter calendar:   The calendar used to create a new instance.
    ///
    /// - returns: The created `Date` instance.
    public init(era: Int?, year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int, on calendar: Calendar) {
        let now = Date()
        var dateComponents = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second, .nanosecond], from: now)
        dateComponents.era = era
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.nanosecond = nanosecond
        
        let date = calendar.date(from: dateComponents)
        self.init(timeInterval: 0, since: date!)
    }
    
    /// Creates a new instance with specified date componentns.
    ///
    /// - parameter year:       The year.
    /// - parameter month:      The month.
    /// - parameter day:        The day.
    /// - parameter hour:       The hour.
    /// - parameter minute:     The minute.
    /// - parameter second:     The second.
    /// - parameter nanosecond: The nanosecond. `0` by default.
    ///
    /// - returns: The created `Date` instance.
    public init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int, nanosecond: Int = 0) {
        self.init(era: nil, year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanosecond, on: .current)
    }
    
    /// Creates a new Instance with specified date components
    ///
    /// - parameter year:  The year.
    /// - parameter month: The month.
    /// - parameter day:   The day.
    ///
    /// - returns: The created `Date` instance.
    public init(year: Int, month: Int, day: Int) {
        self.init(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
    }
    
    /// Creates a new instance representing today.
    ///
    /// - returns: The created `Date` instance representing today.
    public static func today() -> Date {
        let now = Date()
        return Date(year: now.year, month: now.month, day: now.day)
    }
    
    /// Creates a new instance representing yesterday
    ///
    /// - returns: The created `Date` instance representing yesterday.
    public static func yesterday() -> Date {
        return (today() - 1.day)!
    }
    
    /// Creates a new instance representing tomorrow
    ///
    /// - returns: The created `Date` instance representing tomorrow.
    public static func tomorrow() -> Date {
        return (today() + 1.day)!
    }
    
    /// Creates a new instance added a `DateComponents`
    ///
    /// - parameter left:  The date.
    /// - parameter right: The date components.
    ///
    /// - returns: The created `Date` instance.
    public static func + (left: Date, right: DateComponents) -> Date? {
        return Calendar.current.date(byAdding: right, to: left)
    }
    
    /// Creates a new instance subtracted a `DateComponents`
    ///
    /// - parameter left:  The date.
    /// - parameter right: The date components.
    ///
    /// - returns: The created `Date` instance.
    public static func - (left: Date, right: DateComponents) -> Date? {
        return Calendar.current.date(byAdding: -right, to: left)
    }
    
    /// Creates a new instance by changing the date components
    ///
    /// - Parameters:
    ///   - year: The year.
    ///   - month: The month.
    ///   - day: The day.
    ///   - hour: The hour.
    ///   - minute: The minute.
    ///   - second: The second.
    ///   - nanosecond: The nanosecond.
    /// - Returns: The created `Date` instnace.
    public func changed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) -> Date? {
        var dateComponents = self.dateComponents
        dateComponents.year = year ?? self.year
        dateComponents.month = month ?? self.month
        dateComponents.day = day ?? self.day
        dateComponents.hour = hour ?? self.hour
        dateComponents.minute = minute ?? self.minute
        dateComponents.second = second ?? self.second
        dateComponents.nanosecond = nanosecond ?? self.nanosecond
        
        return calendar.date(from: dateComponents)
    }
    
    /// Creates a new instance by changing the year.
    ///
    /// - Parameter year: The year.
    /// - Returns: The created `Date` instance.
    public func changed(year: Int) -> Date? {
        return changed(year: year, month: nil, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nil)
    }
    
    /// Creates a new instance by changing the month.
    ///
    /// - Parameter month: The month.
    /// - Returns: The created `Date` instance.
    public func changed(month: Int) -> Date? {
        return changed(year: nil, month: month, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nil)
    }
    
    /// Creates a new instance by changing the day.
    ///
    /// - Parameter day: The day.
    /// - Returns: The created `Date` instance.
    public func changed(day: Int) -> Date? {
        return changed(year: nil, month: nil, day: day, hour: nil, minute: nil, second: nil, nanosecond: nil)
    }
    
    /// Creates a new instance by changing the hour.
    ///
    /// - Parameter hour: The hour.
    /// - Returns: The created `Date` instance.
    public func changed(hour: Int) -> Date? {
        return changed(year: nil, month: nil, day: nil, hour: hour, minute: nil, second: nil, nanosecond: nil)
    }
    
    /// Creates a new instance by changing the minute.
    ///
    /// - Parameter minute: The minute.
    /// - Returns: The created `Date` instance.
    public func changed(minute: Int) -> Date? {
        return changed(year: nil, month: nil, day: nil, hour: nil, minute: minute, second: nil, nanosecond: nil)
    }
    
    /// Creates a new instance by changing the second.
    ///
    /// - Parameter second: The second.
    /// - Returns: The created `Date` instance.
    public func changed(second: Int) -> Date? {
        return changed(year: nil, month: nil, day: nil, hour: nil, minute: nil, second: second, nanosecond: nil)
    }
    
    /// Creates a new instance by changing the nanosecond.
    ///
    /// - Parameter nanosecond: The nanosecond.
    /// - Returns: The created `Date` instance.
    public func changed(nanosecond: Int) -> Date? {
        return changed(year: nil, month: nil, day: nil, hour: nil, minute: nil, second: nil, nanosecond: nanosecond)
    }
    
    /// Creates a new instance by changing the weekday.
    ///
    /// - Parameter weekday: The weekday.
    /// - Returns: The created `Date` instance.
    public func changed(weekday: Int) -> Date? {
        return self - (self.weekday - weekday).days
    }
    
    /// Creates a new instance by truncating the components
    ///
    /// - Parameter components: The components to be truncated.
    /// - Returns: The created `Date` instance.
    public func truncated(_ components: [Calendar.Component]) -> Date? {
        var dateComponents = self.dateComponents
        
        for component in components {
            switch component {
            case .month:
                dateComponents.month = 1
            case .day:
                dateComponents.day = 1
            case .hour:
                dateComponents.hour = 0
            case .minute:
                dateComponents.minute = 0
            case .second:
                dateComponents.second = 0
            case .nanosecond:
                dateComponents.nanosecond = 0
            default:
                continue
            }
        }
        
        return calendar.date(from: dateComponents)
    }
    
    /// Creates a new instance by truncating the components
    ///
    /// - Parameter component: The component to be truncated from.
    /// - Returns: The created `Date` instance.
    public func truncated(from component: Calendar.Component) -> Date? {
        switch component {
        case .month:
            return truncated([.month, .day, .hour, .minute, .second, .nanosecond])
        case .day:
            return truncated([.day, .hour, .minute, .second, .nanosecond])
        case .hour:
            return truncated([.hour, .minute, .second, .nanosecond])
        case .minute:
            return truncated([.minute, .second, .nanosecond])
        case .second:
            return truncated([.second, .nanosecond])
        case .nanosecond:
            return truncated([.nanosecond])
        default:
            return self
        }
    }
    
    public func string(from dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    /// Creates a new `String` instance representing the receiver formatted in given date style and time style.
    ///
    /// - parameter dateStyle: The date style.
    /// - parameter timeStyle: The time style.
    ///
    /// - returns: The created `String` instance.
    public func stringIn(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        
        return dateFormatter.string(from: self)
    }
    
    @available(*, unavailable, renamed: "stringIn(dateStyle:timeStyle:)")
    public func string(inDateStyle dateStyle: DateFormatter.Style, andTimeStyle timeStyle: DateFormatter.Style) -> String {
        return stringIn(dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
    /// Creates a new `String` instance representing the date of the receiver formatted in given date style.
    ///
    /// - parameter dateStyle: The date style.
    ///
    /// - returns: The created `String` instance.
    public func dateString(in dateStyle: DateFormatter.Style) -> String {
        return stringIn(dateStyle: dateStyle, timeStyle: .none)
    }
    
    /// Creates a new `String` instance representing the time of the receiver formatted in given time style.
    ///
    /// - parameter timeStyle: The time style.
    ///
    /// - returns: The created `String` instance.
    public func timeString(in timeStyle: DateFormatter.Style) -> String {
        return stringIn(dateStyle: .none, timeStyle: timeStyle)
    }
}

public extension Int {
    var year: DateComponents {
        return DateComponents(year: self)
    }
    
    var years: DateComponents {
        return year
    }
    
    var month: DateComponents {
        return DateComponents(month: self)
    }
    
    var months: DateComponents {
        return month
    }
    
    var week: DateComponents {
        return DateComponents(day: 7 * self)
    }
    
    var weeks: DateComponents {
        return week
    }
    
    var day: DateComponents {
        return DateComponents(day: self)
    }
    
    var days: DateComponents {
        return day
    }
    
    var hour: DateComponents {
        return DateComponents(hour: self)
    }
    
    var hours: DateComponents {
        return hour
    }
    
    var minute: DateComponents {
        return DateComponents(minute: self)
    }
    
    var minutes: DateComponents {
        return minute
    }
    
    var second: DateComponents {
        return DateComponents(second: self)
    }
    
    var seconds: DateComponents {
        return second
    }
    
    var nanosecond: DateComponents {
        return DateComponents(nanosecond: self)
    }
    
    var nanoseconds: DateComponents {
        return nanosecond
    }
}

extension String {
    /// Creates a `Date` instance representing the receiver parsed into `Date` in a given format.
    ///
    /// - parameter format: The format to be used to parse.
    ///
    /// - returns: The created `Date` instance.
    public func date(inFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter.date(from: self)
    }
    
    /// Creates a `Date` instance representing the receiver in ISO8601 format parsed into `Date` with given options.
    ///
    /// - parameter options: The options to be used to parse.
    ///
    /// - returns: The created `Date` instance.
    @available(iOS 10.0, OSX 10.12, watchOS 3.0, tvOS 10.0, *)
    public func dateInISO8601Format(with options: ISO8601DateFormatter.Options = [.withInternetDateTime]) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = options
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter.date(from: self)
    }
}

