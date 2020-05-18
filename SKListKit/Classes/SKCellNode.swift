//
//  SKCellNode.swift
//  SKListKit
//
//  Created by ljk on 2020/5/10.
//

import Foundation
import AsyncDisplayKit

open class SKCellNode: ASCellNode, SKCellNodeProtocol {
    
    public var isFirstCell: Bool = false
    
    public var isLastCell: Bool = false
    
    public override init() {
        super.init()
        
        automaticallyManagesSubnodes = true
    }
    
    open override func didLoad() {
        super.didLoad()
        accessibilityIdentifier = String(reflecting: type(of: self))
    }
    
    open func configure(_ model: AnyObject) {
        
    }
    
}

func LLog(_ items: Any...,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line) {
    #if DEBUG
    var output = ""
    for item in items {
        output += "\(item) "
    }
    output += "\n"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss:SSS"
    let timestamp = dateFormatter.string(from: Date())
    print("\(timestamp) | \((file as NSString).lastPathComponent)[\(line)] > \(method): ")
    print(output)
    #endif
}
