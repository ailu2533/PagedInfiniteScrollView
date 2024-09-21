//
//  Steppable.swift
//  Heatmap
//
//  Created by Lu Ai on 2024/9/20.
//


import Foundation

protocol Steppable {
    static var origin: Self { get }

    func forward() -> Self
    func backward() -> Self
}

extension Int: Steppable {
    static var origin: Int {
        return 0
    }
    
    func forward() -> Int {
        return self + 1
    }

    func backward() -> Int {
        return self - 1
    }
}

extension Date: Steppable {
    static var origin: Date {
        return .now
    }
    
    func forward() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }

    func backward() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
}