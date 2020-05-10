//
//  SKSectionModel.swift
//  SKListKit
//
//  Created by ljk on 2020/5/10.
//

import Foundation
import DifferenceKit

open class SKSectionModel: NSObject, Differentiable {
    public var identifier: String
    
    public var differenceIdentifier: String {
        return identifier
    }
    
    public typealias DifferenceIdentifier = String
    
    public var sectionInset = UIEdgeInsets.zero
    
    public var cellModels: [SKCellNodeModel] = []
    
    public init(identifier: String = UUID().uuidString) {
        self.identifier = identifier
        
        super.init()
    }
    
}
