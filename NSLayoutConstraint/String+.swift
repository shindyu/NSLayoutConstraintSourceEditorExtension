//
//  String+.swift
//  NSLayoutConstraint
//
//  Created by shindyu on 2018/03/29.
//  Copyright © 2018年 shindyu. All rights reserved.
//

import Foundation

extension String {
    var prepared: String? {
        let line = trimmingCharacters(in: .whitespacesAndNewlines)
        return line.isEmpty ? nil : line
    }
}
