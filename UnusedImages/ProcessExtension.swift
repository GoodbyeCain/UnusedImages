//
//  ProcessExtension.swift
//  UnusedImages
//
//  Created by baidu on 2017/2/27.
//  Copyright © 2017年 say. All rights reserved.
//

import Foundation

extension Process {
    class func process(command:String) -> String? {
        let process = Process()
        var ary = command.components(separatedBy: " ");
        if ary.count < 1 {
            return nil;
        }
        process.launchPath = ary.first;
        ary.removeFirst();
        process.arguments = ary;
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String.init(data: data, encoding: String.Encoding.utf8)
    }
    
    class func processShell(args:[String]) -> String? {        
        let process = Process()
        process.launchPath = "/bin/sh";
        process.arguments = args
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String.init(data: data, encoding: String.Encoding.utf8)
    }
}
