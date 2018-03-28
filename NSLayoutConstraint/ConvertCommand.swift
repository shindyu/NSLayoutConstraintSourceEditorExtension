//
//  SourceEditorCommand.swift
//  NSLayoutConstraint
//
//  Created by 新堂　敬隆 on 2018/03/28.
//  Copyright © 2018年 shindyu. All rights reserved.
//

import Foundation
import XcodeKit

class ConvertCommand: NSObject, XCSourceEditorCommand {
    struct ArrayStyle {
        
    }
    struct LineStyle {
        
    }
    private func extractNSLayoutConstraints2(fromBuffer buffer: XCSourceTextBuffer) -> [String] {
        var result: [String] = []
        let idx = getSelectedLinesIndexes(fromBuffer: buffer)
        enum state {
            case array
            case line
        }
        var searchState: state = .line
        
        for index in idx {
            guard let line = buffer.lines[index] as? String else { preconditionFailure() }
            guard let l = line.prepared else { continue }
            switch searchState {
            case .array:
                if l.hasPrefix("])") {
                    searchState = .line
                } else {
                    if l.last == "," {
                        result.append(l.replacingOccurrences(of: ",", with: ".isActive = true"))
                    } else {
                        result.append(l + ".isActive = true")
                    }
                }
            case .line:
                if l.hasPrefix("NSLayoutConstraint.activate(") {
                    searchState = .array
                }
                if l.hasSuffix(".isActive = true") {
                    result.append(l.replacingOccurrences(of: ".isActive = true", with: ""))
                }
            }
            
        }
        return result
    }
    
    private func extractNSLayoutConstraints(fromBuffer buffer: XCSourceTextBuffer) -> [String] {
        var result: [String] = []
        let idx = getSelectedLinesIndexes(fromBuffer: buffer)
        
        for index in idx {
            guard let line = buffer.lines[index] as? String else { preconditionFailure() }
            guard let l = line.prepared else { continue }
            if l.hasSuffix(".isActive = true") {
                result.append(l.replacingOccurrences(of: ".isActive = true", with: ""))
            }
        }
        return result
    }
    
    private func convertNSLayoutConstraints(fromCases constraints: [String], tabWidth: Int) -> String {
        let indent = String(repeating: " ", count: tabWidth)
        let constraintsStr = constraints.map{ "\(indent)\(indent)\(indent)\($0)" }.joined(separator: ",\n")
        return """
        \(indent)\(indent)NSLayoutConstraint.activate([
        \(constraintsStr)
        \(indent)\(indent)\(indent)])
        """
    }
    
    private func startSelectedLine(fromBuffer buffer: XCSourceTextBuffer) -> Int? {
        return (buffer.selections.lastObject as? XCSourceTextRange)?.start.line
    }
    
    private func lastSelectedLine(fromBuffer buffer: XCSourceTextBuffer) -> Int? {
        return (buffer.selections.lastObject as? XCSourceTextRange)?.end.line
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard invocation.buffer.contentUTI == "public.swift-source" else { return }
        guard let lastIndex = lastSelectedLine(fromBuffer: invocation.buffer) else { return }
        
        let constraints = extractNSLayoutConstraints(fromBuffer: invocation.buffer)
        
        guard constraints.count > 0 else { return }
        
        let str = convertNSLayoutConstraints(fromCases: constraints, tabWidth: invocation.buffer.tabWidth)
        invocation.buffer.lines.insert(str, at: lastIndex + 1)
        
        defer {
            completionHandler(nil)
        }
    }
}
