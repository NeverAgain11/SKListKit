//
//  SKSectionModel.swift
//  SKListKit
//
//  Created by ljk on 2020/5/10.
//

import Foundation

open class SKSectionModel: NSObject {
    public var sectionInset = UIEdgeInsets.zero
    
    public var cellModels: [SKCellNodeModelProtocol] = []
}
