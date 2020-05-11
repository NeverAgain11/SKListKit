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
    
    open func configure(_ model: AnyObject) {
        
    }
    
}
