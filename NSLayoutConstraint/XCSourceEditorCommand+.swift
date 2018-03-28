//
//  XCSourceEditorCommand+.swift
//  NSLayoutConstraint
//
//  Created by 新堂　敬隆 on 2018/03/29.
//  Copyright © 2018年 shindyu. All rights reserved.
//

import Foundation
import XcodeKit

func getSelectedLinesIndexes(fromBuffer buffer: XCSourceTextBuffer) -> [Int] {
    var result: [Int] = []
    for range in buffer.selections {
        guard let range = range as? XCSourceTextRange else { preconditionFailure() }
        for lineNumber in range.start.line...range.end.line {
            result.append(lineNumber)
        }
    }
    return result
}

