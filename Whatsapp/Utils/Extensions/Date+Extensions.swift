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
}

extension TimeInterval {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}
