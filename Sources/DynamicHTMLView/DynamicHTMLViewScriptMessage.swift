//
//  DynamicHTMLViewScriptMessage.swift
//  
//
//  Created by Rakibur Khan on 1/May/22.
//

import Foundation

public struct DynamicHTMLViewScriptMessage {
    public struct HandlerName : RawRepresentable, Equatable, Hashable, Comparable {
        public var rawValue: String
        
        public var hashValue: Int
        
        public static func <(lhs: DynamicHTMLViewScriptMessage.HandlerName, rhs: DynamicHTMLViewScriptMessage.HandlerName) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
            self.hashValue = rawValue.hashValue
        }
    }
}

extension DynamicHTMLViewScriptMessage.HandlerName {
    public static let onContentHeightChange = DynamicHTMLViewScriptMessage.HandlerName(StringConstants.onContentHeightChange.rawValue)
}
