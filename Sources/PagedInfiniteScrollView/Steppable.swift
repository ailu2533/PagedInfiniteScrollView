//
//  Steppable.swift
//  Heatmap
//
//  Created by Lu Ai on 2024/9/20.
//

import Foundation

public protocol Steppable {
    static var origin: Self { get }

    func forward() -> Self?
    func backward() -> Self?
}

extension Int: Steppable {
    public static var origin: Int {
        return 0
    }

    public func forward() -> Int? {
        return self + 1
    }

    public func backward() -> Int? {
        return self - 1
    }
}

//extension Date: Steppable {
//    public static var origin: Date {
//        return .now
//    }
//
//    public func forward() -> Date? {
//        return Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
//    }
//
//    public func backward() -> Date? {
//        return Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
//    }
//}
