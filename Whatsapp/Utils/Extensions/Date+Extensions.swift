//
//  Date+Extensions.swift
//  Whatsapp
//
//  Created by iCommunity app on 27/08/2024.
//

import Foundation

extension Date {
    
    /// If today:  `3:00 PM`
    /// If yesterday: `Yesterday`
    /// Otherwise: `02/15/24`
    var dateOrTimeRepresentation: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: self)
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            return dateFormatter.string(from: self)
        }
    }
    
    var formatToTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: self)
    }
    
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if isCurrentWeek {
            return toString(dateFormat: "EEEE")
        } else if isCurrentYear {
            return toString(dateFormat: "E, MMM d")
        } else {
            return toString(dateFormat: "MMM dd, yyyy")
        }
    }
    
    private var isCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekday)
    }
    
    private var isCurrentYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    
    func toString(dateFormat: String) -> String {
         let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
}

extension TimeInterval {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
    
    var formatElapsedTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension TimeInterval? {
    var removeOptional: TimeInterval {
        return self ?? 0.0
    }
}
