//
//  File.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 27.04.2021.
//

import SwiftUI
import AppKit
 
func dateForMessages(from: Date?) -> String {
    guard let date = from else { return "" }
    let today = Date()
    
    let calendar = Calendar.current
    let formatter = DateFormatter()
    
    if calendar.isDateInToday(date) {
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    if calendar.isDate(date, equalTo: today, toGranularity: .weekOfYear)
                && calendar.isDate(date, equalTo: today, toGranularity: .year){
        formatter.dateFormat = "EEE"
        return formatter.string(from: date);
    }
    
    formatter.dateStyle = .short
    var result = formatter.string(for: date)!
    
    do {
        let regex = try NSRegularExpression(pattern: "20[0-9]{2}")
        let matches = regex.matches(in: result,
                                    range: NSRange(location: 0, length: result.count))
        guard let range = Range(matches[0].range, in: result) else { return result }
        let ub = range.upperBound
        let lb = result.index(range.lowerBound, offsetBy: 2)
        result.removeSubrange(Range(uncheckedBounds: (lb, ub)))
        return result
    }
    catch {
        return result
    }

}

func dateToTime(from: Date?) -> String {
    guard let date = from else { return "" }
    //let today = Date()
    
    //let calendar = Calendar.current
    let formatter = DateFormatter()
    
    formatter.timeStyle = .short
    return formatter.string(from: date)

}

func newDayCard(_ date: Date) -> String {
    let formatter = DateFormatter()
    if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    formatter.dateFormat = "d MMMM yyyy"
    return formatter.string(from: date)
}

func timeToString(_ timeSeconds: Int) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated // or .short or .abbreviated
    formatter.allowedUnits = [.second, .minute, .hour]

    return formatter.string(from: TimeInterval(timeSeconds))!
}
