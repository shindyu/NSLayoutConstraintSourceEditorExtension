//
//  SourceEditorCommand.swift
//  NSLayoutConstraint
//
//  Created by 新堂　敬隆 on 2018/03/28.
//  Copyright © 2018年 shindyu. All rights reserved.
//

import Foundation
import XcodeKit

class CreateCommand: NSObject, XCSourceEditorCommand {
    private func extractTargetViews(fromBuffer buffer: XCSourceTextBuffer) -> [String] {
        var result: [String] = []
        let idx = getSelectedLinesIndexes(fromBuffer: buffer)
        for index in idx {
            guard let line = buffer.lines[index] as? String else { preconditionFailure() }
            guard let l = line.prepared else { continue }
            result.append(l)
        }
        return result
    }
    
    private func generateConstraints(for targetViews: [String], tabWidth: Int) -> String {
        let indent = String(repeating: " ", count: tabWidth)
        return targetViews.map { targetView in
            """
            \(indent)\(indent)\(targetView).translatesAutoresizingMaskIntoConstraints = false
            \(indent)\(indent)NSLayoutConstraint.activate([
            \(indent)\(indent)\(indent)\(targetView).topAnchor.constraint(equalTo: <#targetView#>.topAnchor),
            \(indent)\(indent)\(indent)\(targetView).leftAnchor.constraint(equalTo: <#targetView#>.leftAnchor),
            \(indent)\(indent)\(indent)\(targetView).rightAnchor.constraint(equalTo: <#targetView#>.rightAnchor),
            \(indent)\(indent)\(indent)\(targetView).bottomAnchor.constraint(equalTo: <#targetView#>.bottomAnchor)
            \(indent)\(indent)\(indent)])
            """
        }.joined(separator: "\n\n")
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
        
        let targetViews = extractTargetViews(fromBuffer: invocation.buffer)
        
        let str = generateConstraints(for: targetViews, tabWidth: invocation.buffer.tabWidth)
        invocation.buffer.lines.insert(str, at: lastIndex + 1)
        
        defer {
            completionHandler(nil)
        }
    }
}

