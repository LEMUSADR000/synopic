//
//  Date+Extensions.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Foundation

extension Date {
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self)!
    }
}
