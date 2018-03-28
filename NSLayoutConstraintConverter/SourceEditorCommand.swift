//
//  SourceEditorCommand.swift
//  NSLayoutConstraintConverter
//
//  Created by 新堂　敬隆 on 2018/03/29.
//  Copyright © 2018年 shindyu. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        completionHandler(nil)
    }
    
}
