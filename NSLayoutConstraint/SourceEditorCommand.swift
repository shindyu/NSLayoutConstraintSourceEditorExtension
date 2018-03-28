//
//  SourceEditorCommand.swift
//  NSLayoutConstraint
//
//  Created by 新堂　敬隆 on 2018/03/28.
//  Copyright © 2018年 shindyu. All rights reserved.
//

import Foundation
import XcodeKit

extension String {
    var prepared: String? {
        let line = trimmingCharacters(in: .whitespacesAndNewlines)
        return line.isEmpty ? nil : line
    }
}

private class NSConstraintExtractor {
    private static func getSelectedLinesIndexes(fromBuffer buffer: XCSourceTextBuffer) -> [Int] {
        var result: [Int] = []
        for range in buffer.selections {
            guard let range = range as? XCSourceTextRange else { preconditionFailure() }
            for lineNumber in range.start.line...range.end.line {
                result.append(lineNumber)
            }
        }
        return result
    }
    
    static func extractNSConstraints(fromBuffer buffer: XCSourceTextBuffer) -> [String] {
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
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    private func generateNSConstraint(fromCases constraints: [String], tabWidth: Int) -> String {
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
        
        let constraints = NSConstraintExtractor.extractNSConstraints(fromBuffer: invocation.buffer)
        
        guard constraints.count > 0 else { return }
        
        let str = generateNSConstraint(fromCases: constraints, tabWidth: invocation.buffer.tabWidth)
        invocation.buffer.lines.insert(str, at: lastIndex + 1)
        
//        // select the inserted code
//        let start = XCSourceTextPosition(line: lineIndex + 2, column: 0)
//        let end = XCSourceTextPosition(line: lineIndex + 2 * constraints.count + 2, column: 0)
//        invocation.buffer.selections.setArray([XCSourceTextRange(start: start, end: end)])
        
        completionHandler(nil)
    }
}
