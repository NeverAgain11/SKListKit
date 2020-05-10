//
//  SKCollectionNodeAdapter.swift
//  SKListKit
//
//  Created by ljk on 2020/5/10.
//

import Foundation
import AsyncDisplayKit
import DifferenceKit

public class SKCollectionNodeAdapter: NSObject {
    
    public var sectionModels: [SKSectionModel] = []
    
    public lazy var collectionNode: ASCollectionNode = {
        let node = ASCollectionNode(collectionViewLayout: collectionLayout)
        node.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
        node.registerSupplementaryNode(ofKind: UICollectionElementKindSectionFooter)
        node.view.alwaysBounceVertical = true
        node.allowsSelection = true
        node.delegate = self;
        node.dataSource = self;
        node.leadingScreensForBatching = 4;
        return node
    }()
    
    public lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()
    
    public private(set) var reloadedIndexPathes: Set<IndexPath> = []
}

extension SKCollectionNodeAdapter {
    func cellModelForItem(at indexPath: IndexPath) -> SKCellNodeModel? {
        if let sectionModel = self.sectionModelForSection(indexPath.section) {
            if sectionModel.cellModels.indices.contains(indexPath.item) {
                return sectionModel.cellModels[indexPath.item]
            }
        }
        return nil
    }
    
    func sectionModelForSection(_ section: Int) -> SKSectionModel? {
        if sectionModels.indices.contains(section) {
            return sectionModels[section]
        }
        return nil
    }
}


extension SKCollectionNodeAdapter: ASCollectionDataSource {
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return sectionModels.count
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        if sectionModels.indices.contains(section) {
            return sectionModels[section].cellModels.count
        }
        return 0
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let cellModel = cellModelForItem(at: indexPath)
        
        let isFirstCell = indexPath.item == 0
        let isLastCell = self.collectionNode(collectionNode, numberOfItemsInSection: indexPath.section) == indexPath.item + 1
        
        return { [weak self] in
            guard let `self` = self else { return ASCellNode() }

            var cell: ASCellNode?
            if let nodeBlock = cellModel?.cellNodeBlock {
                cell = nodeBlock()
            }
            
            if let node = cell as? SKCellNodeProtocol {
                node.isFirstCell = isFirstCell
                node.isLastCell = isLastCell
                if let dataModel = cellModel {
                    node.config(dataModel)
                }
            }
            
            if self.reloadedIndexPathes.contains(indexPath) {
                cell?.neverShowPlaceholders = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    cell?.neverShowPlaceholders = false
                    self.reloadedIndexPathes.remove(indexPath)
                    
                    cell?.invalidateCalculatedLayout()
                }
            }
            
            if let cell = cell {
                return cell
            }
            return ASCellNode()
        }
    }
    
    public func reloadData() {
        let indexPaths = collectionNode.indexPathsForVisibleItems
        reloadedIndexPathes = Set(indexPaths)
        
        collectionNode.reloadData()
    }
    
    typealias SKArraySection = ArraySection<SKSectionModel, SKCellNodeModel>
    
    public func apply(_ newSectionModels: [SKSectionModel]) {
        let indexPaths = collectionNode.indexPathsForVisibleItems
        reloadedIndexPathes = Set(indexPaths)
        
        let source: [SKArraySection] = sectionModels.map {
            return ArraySection(model: $0, elements: $0.cellModels)
        }
        
        let target: [SKArraySection] = sectionModels.map {
            return ArraySection(model: $0, elements: $0.cellModels)
        }
        
        let changeset = StagedChangeset(source: source, target: target)
        
        self.reload(using: changeset)
        
    }
    
    func reload(using stagedChangeset: StagedChangeset<[SKArraySection]>) {
        collectionNode.view.reload(using: stagedChangeset) { (data) in
            sectionModels = data.map { $0.model }
        }
    }
}

extension SKCollectionNodeAdapter: ASCollectionDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let sectionModel = self.sectionModelForSection(section) {
            return sectionModel.sectionInset
        }
        return .zero
    }
}

extension SKCollectionNodeAdapter: ASCollectionDelegate {
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModelForItem(at: indexPath)
        
        cellModel?.cellNodeTapAction?()
    }
    
}
