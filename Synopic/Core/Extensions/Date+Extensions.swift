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

  func adding(days: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: days, to: self)!
  }

  func get(
    _ components: Calendar.Component...,
    calendar: Calendar = Calendar.current
  ) -> DateComponents {
    return calendar.dateComponents(Set(components), from: self)
  }

  func get(
    _ component: Calendar.Component,
    calendar: Calendar = Calendar.current
  ) -> Int {
    return calendar.component(component, from: self)
  }

  var date: Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents(
      [.year, .month, .day],
      from: self
    )
    return calendar.date(from: components)!
  }
}
