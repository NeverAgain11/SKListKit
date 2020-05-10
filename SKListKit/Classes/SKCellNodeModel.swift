//
//  SKCellNodeModel.swift
//  SKListKit
//
//  Created by ljk on 2020/5/10.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit

public protocol SKCellNodeProtocol: AnyObject {
    var isFirstCell: Bool { get set }
    var isLastCell: Bool { get set }
    
    func config(_ model: SKCellNodeModel)
}

typealias SKCellModelProtocol = SKCellNodeModelProtocol & Differentiable

public typealias SKCellNodeTapAction = (()->Void)
public typealias SKCellNodeBlock = (()->ASCellNode)

public protocol SKCellNodeModelProtocol: Differentiable {
    
    var identifier: String { get }
    
    var cellNodeBlock: SKCellNodeBlock? { get }
    var cellNodeTapAction: SKCellNodeTapAction? { get }
    
}

open class SKCellNodeModel: NSObject, SKCellNodeModelProtocol {
    public var identifier: String
    
    open var cellNodeBlock: SKCellNodeBlock?
    
    open var cellNodeTapAction: SKCellNodeTapAction?
    
    public typealias DifferenceIdentifier = String
    
    public var differenceIdentifier: String {
        return identifier
    }
    
    public init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
        
        super.init()
    }
    
    @discardableResult
    public func setIdentifier(_ identifier: String) -> SKCellNodeModel {
        self.identifier = identifier
        return self
    }
    
    @discardableResult
    public func setCellNodeBlock(_ nodeBlock: @escaping SKCellNodeBlock) -> SKCellNodeModel {
        self.cellNodeBlock = nodeBlock
        return self
    }
    
    @discardableResult
    public func setCellNodeTapAction(_ tapAction: @escaping SKCellNodeTapAction) -> SKCellNodeModel {
        self.cellNodeTapAction = tapAction
        return self
    }
}
