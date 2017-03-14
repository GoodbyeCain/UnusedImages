//
//  FileOperation.swift
//  UnusedImages
//
//  Created by baidu on 2017/2/27.
//  Copyright © 2017年 say. All rights reserved.
//

import Foundation

private let bundleIdentifier = ".bundle"
private let iconIdentifier = "AppIcon.appiconset"
private let launchIdentifier = "LaunchImage.launchimage"

class Scanner {
    var path: String = "";
    
    func setup(path: String)  {
        self.path = path
    }
    
    func getExistingImages() -> [String:[String]]? {
        let command = "/usr/bin/find \(path) -name *.png -o -name *.jpg -o -name *.jpeg -o -name *.gif";
        if let result = Process.process(command: command) {
            
            var resultMap = [String:[String]]()
            var existingImages = result.components(separatedBy: "\n")
            
            existingImages = existingImages.filter({ (imagePath) -> Bool in
                if imagePath.contains(bundleIdentifier) || imagePath.contains(iconIdentifier) ||
                   imagePath.contains(launchIdentifier) || imagePath == "" {
                    return false;
                }
                return true;
            }).map({ (imagePath) -> String in
                var name: String? = nil
                if(imagePath.contains(".imageset")) {
                    name = imagePath.components(separatedBy: ".imageset").first?.components(separatedBy: "/").last
                } else {
                    name = imagePath.components(separatedBy: "/").last?.components(separatedBy: "@").first?.components(separatedBy: ".").first
                }
                if let theName = name {
                    if resultMap[theName] != nil {
                        resultMap[theName]?.append(imagePath)
                    } else {
                        resultMap[theName] = [imagePath]
                    }
                    return theName;
                }
                return ""
            })
            return resultMap
        }
        return nil
    }
    
    func getConstString() -> Set<String> {
        var constStringSet = Set<String>()
        
        let shellPath = Bundle.main.path(forResource: "search", ofType: "sh");
        if let resultString = Process.processShell(args: [shellPath!, path]) {
            let constStringArray = resultString.components(separatedBy: " ")
            constStringSet = Set(constStringArray)
            return constStringSet
        }
        
        return constStringSet
    }
}
