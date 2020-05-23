//
//  ViewController.swift
//  SKListKit
//
//  Created by ljk on 05/10/2020.
//  Copyright (c) 2020 ljk. All rights reserved.
//

import UIKit
import SKListKit
import AsyncDisplayKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func setupUI() {
        let sectionModel = SKSectionModel()
        
        let cellModel = SKCellNodeModel().setCellNodeBlock {
                            return DemoCellNode()
                        }.setCellNodeTapAction {
                            
                        }
        
        sectionModel.cellModels.append(cellModel)
        
        let adapter = SKCollectionNodeAdapter()
        
        adapter.sectionModels = [sectionModel]
    }
}

class DemoCellNode: ASCellNode {
    
}
