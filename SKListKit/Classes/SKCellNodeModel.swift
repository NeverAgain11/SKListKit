//
//  SKCellNodeModel.swift
//  SKListKit
//
//  Created by ljk on 2020/5/10.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit
import ObjectiveC

private var identifierContext: UInt8 = 0

public extension NSObject {
    var skIdentifier: String {
        get {
            if let id = objc_getAssociatedObject(self, &identifierContext) as? String {
                return id
            }
            let id = UUID().uuidString
            objc_setAssociatedObject(self, &identifierContext, id, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return id
        }
        set {
            objc_setAssociatedObject(self, &identifierContext, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

public protocol SKCellNodeProtocol: AnyObject {
    var isFirstCell: Bool { get set }
    var isLastCell: Bool { get set }
    
    func configure(_ model: AnyObject)
}

typealias SKCellModelProtocol = SKCellNodeModelProtocol & Differentiable

public typealias SKCellNodeTapAction = (()->Void)
public typealias SKCellNodeBlock = (()->ASCellNode)

public protocol SKCellNodeModelProtocol: Differentiable {
    
    var cellNodeBlock: SKCellNodeBlock? { get }
    var cellNodeTapAction: SKCellNodeTapAction? { get }
    var cellNodeDisplay: ((ASCellNode)->Void)? { get }
}

open class SKCellNodeModel: NSObject, SKCellNodeModelProtocol {
    
    open var cellNodeBlock: SKCellNodeBlock?
    
    open var cellNodeTapAction: SKCellNodeTapAction?
    
    open var cellNodeDisplay: ((ASCellNode)->Void)?
    
    public var dataModel: AnyObject?
    
    public typealias DifferenceIdentifier = String
    
    public var differenceIdentifier: String {
        return skIdentifier
    }
    
    open func isContentEqual(to source: SKCellNodeModel) -> Bool {
        return self.differenceIdentifier == source.differenceIdentifier
    }
}

open class SKNodeModel<Node, Model: NSObject>: SKCellNodeModel where Node: ASCellNode {
    let model: Model
    
    public init(_ nodeType: Node.Type, model: Model) {
        self.model = model
        
        super.init()
        
        self.skIdentifier = model.skIdentifier
        
        self.dataModel = model
        
        self.cellNodeBlock = {
            return nodeType.init()
        }
    }
    
    @discardableResult
    public func didSelect<Observer: AnyObject>(observer: Observer, tapAction: @escaping ((Observer, Model)->Void)) -> SKNodeModel {
        self.cellNodeTapAction = { [weak self, weak observer] in
            guard let `self` = self,
                let ob = observer
                else { return }
            tapAction(ob, self.model)
        }
        return self
    }
    
    @discardableResult
    open func willDisplay<Observer: AnyObject>(observer: Observer, closure: @escaping ((Observer, Node)->Void)) -> SKNodeModel {
        
        self.cellNodeDisplay = { [weak observer] node in
            guard let ob = observer,
                let node = node as? Node
                else { return }
            closure(ob, node)
        }
        return self
    }
}
