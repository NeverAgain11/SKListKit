//
//  SKCellNodeModel.swift
//  SKListKit
//
//  Created by ljk on 2020/5/10.
//

import Foundation
import AsyncDisplayKit

public protocol SKCellNodeProtocol: class {
    var isFirstCell: Bool { get set }
    var isLastCell: Bool { get set }
    
    func config(_ model: Any)
}

public typealias SKCellNodeTapAction = (()->Void)
public typealias SKCellNodeBlock = (()->ASCellNode)

@objc public protocol SKCellNodeModelProtocol: class {
    var cellNodeBlock: SKCellNodeBlock? { get }
    var cellNodeTapAction: SKCellNodeTapAction? { get }
    
    var dataModel: Any? { get set }
}

open class SKCellNodeModel<T: ASCellNode>: NSObject, SKCellNodeModelProtocol {
    
    public var dataModel: Any?
    
    open var cellNodeBlock: SKCellNodeBlock? {
        return {
            return T()
        }
    }
    
    open var cellNodeTapAction: SKCellNodeTapAction?
    
}
