//
//  ViewController.swift
//  UnusedImages
//
//  Created by CainGoodbye on 25/02/2017.
//  Copyright © 2017 say. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var searchProgress: NSProgressIndicator!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var pathTextField: NSTextField!
    @IBOutlet weak var browseButton: NSButton!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var scanner: Scanner!;
    var unusedData:[[String]]?
    var unusedDataName:[String]?
    var selectStatus:[Bool]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scanner = Scanner()
        tableView.doubleAction = #selector(ViewController.tableViewDoubleClick)
    }
    
}

// MARK: -Operation
extension ViewController {
    
    @IBAction func browseFolderPressed(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        if openPanel.runModal() == NSModalResponseOK {
            pathTextField.stringValue = (openPanel.directoryURL?.path)!
        }
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        let path = pathTextField.stringValue
        if path.isEmpty {
            showAlert(title: "Error", subtitle: "missing project path")
            return;
        }
        
        
        if !FileManager.default.fileExists(atPath: path) {
            showAlert(title: "Error", subtitle: "invalid project path")
            return;
        }
        
        scanner.setup(path: pathTextField.stringValue)
        setupUIStatus(isBeginSearch: true)
        
        DispatchQueue.global().async {
            if let allImages = self.scanner.getExistingImages() {
                let constString = self.scanner.getConstString()
                let all = Set(allImages.keys)
                let unused = all.subtracting(constString);
                print(unused.count)
                
                var unusedData = [[String]]()
                var selectStatus = [Bool]()
                var unusedName = [String]()
                for aUnused in unused {
                    unusedData.append( allImages[aUnused]!)
                    unusedName.append(aUnused)
                    selectStatus.append(false)
                }
                self.unusedData = unusedData
                self.selectStatus = selectStatus
                self.unusedDataName = unusedName
            }
            DispatchQueue.main.sync {
                self.setupUIStatus(isBeginSearch: false)
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if let data = self.unusedData {
            if let status = self.selectStatus {
                if data.count != status.count {
                    return
                }
                for i in 0 ..< data.count {
                    if status[i] {
                        for path in data[i] {
                            var needDeletePath = path
                            var needSkip = false
                            if path.contains("imageset") {
                                needDeletePath = path.replacingOccurrences(of: path.components(separatedBy: "/").last!, with: "")
                                needSkip = true
                            }
                            do {
                                print("try to delete:" + needDeletePath)
                                try FileManager.default.removeItem(atPath: needDeletePath)
                            } catch let error as NSError  {
                                self.showAlert(title: "Error", subtitle: "Delete get error" + error.domain)
                                print(error)
                                return
                            }
                            if needSkip {
                                break
                            }
                        }
                    }
                }
                self.searchPressed(searchButton)
            }
        }
    }
    
    func tableViewDoubleClick() {
        let clickRow = tableView.clickedRow;
        if tableView.clickedColumn > 1 {
            return
        }
        if let data = self.unusedData {
            if clickRow < data.count {
                let path = data[clickRow].first!
                NSWorkspace.shared().selectFile(path, inFileViewerRootedAtPath: "")
            }
        }
    }
    
}

private let imageIdentifier = "kImage"
private let imageNameIdentifier = "kImageName"
private let pathIdentifier = "kPath"
private let selectIdentifier = "kSelect"
// MARK: -NSTableViewDataSource & -NSTableViewDelegate
extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let data = unusedData {
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let info = self.unusedData![row]
        let identifier = tableColumn?.identifier
        if identifier == imageIdentifier {
            return NSImage(byReferencingFile:info.first!)
        } else if identifier == imageNameIdentifier {
            return unusedDataName?[row]
        } else if identifier == pathIdentifier {
            return info.first!
        } else {
            return selectStatus?[row]
        }
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        let identifier = tableColumn.identifier
        if identifier == selectIdentifier {
            selectStatus = selectStatus?.map({ (value) -> Bool in
                return !value
            })
            tableView.reloadData()
        }
        
        let index = tableView.tableColumns.index(of: tableColumn)
        tableView.deselectColumn(index!)
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        if let identifier = tableColumn?.identifier {
            if identifier == "kSelect"  {
                selectStatus?[row] = !(selectStatus?[row])!
                tableView.reloadData()
            }
        }
    }
    
}

// MARK: -Setting
extension ViewController {
    
    func showAlert(title: String , subtitle:String) {
        let alert = NSAlert();
        alert.alertStyle = NSAlertStyle.informational;
        alert.messageText = title;
        alert.informativeText = subtitle;
        alert.runModal();
    }
    
    func setupUIStatus(isBeginSearch: Bool) {
        searchProgress.isHidden = !isBeginSearch
        searchButton.isEnabled = !isBeginSearch
        deleteButton.isEnabled = !isBeginSearch
        if isBeginSearch {
            searchProgress.startAnimation(nil);
        } else {
            searchProgress.stopAnimation(nil);
        }
    }
    
}
