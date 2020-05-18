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
        node.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionHeader)
        node.registerSupplementaryNode(ofKind: UICollectionView.elementKindSectionFooter)
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
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    public private(set) var reloadedIndexPathes: Set<IndexPath> = []
    
    public weak var delegate: ASCollectionDelegate?
    
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
                if let dataModel = cellModel?.dataModel {
                    node.configure(dataModel)
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
    
    
}

extension SKCollectionNodeAdapter: ASCollectionDelegate {
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModelForItem(at: indexPath)
        
        cellModel?.cellNodeTapAction?()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        guard let indexPath = collectionNode.indexPath(for: node) else { return }
        let cellModel = cellModelForItem(at: indexPath)
        
        cellModel?.cellNodeDisplay?(node)
    }
}

extension SKCollectionNodeAdapter: ASCollectionDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let sectionModel = self.sectionModelForSection(section) {
            return sectionModel.sectionInsets
        }
        return .zero
    }
}

extension SKCollectionNodeAdapter {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
}

public extension SKCollectionNodeAdapter {
    
    public func reloadData() {
        let indexPaths = collectionNode.indexPathsForVisibleItems
        reloadedIndexPathes = Set(indexPaths)
        
        collectionNode.reloadData()
    }
    
    public func apply(_ newSectionModels: [SKSectionModel], animated: Bool = false) {
        let indexPaths = collectionNode.indexPathsForVisibleItems
        reloadedIndexPathes = Set(indexPaths)
        
        let source: [SKArraySection] = sectionModels.map {
            return ArraySection(model: $0, elements: $0.cellModels)
        }
        
        let target: [SKArraySection] = newSectionModels.map {
            return ArraySection(model: $0, elements: $0.cellModels)
        }
        
        let changeset = StagedChangeset(source: source, target: target)
        
        collectionNode.reload(using: changeset, animated: animated) { (data) in
            self.sectionModels = data.map { $0.model }
        }
    }
}

typealias SKArraySection = ArraySection<SKSectionModel, SKCellNodeModel>

extension ASCollectionNode {
    func reload(using stagedChangeset: StagedChangeset<[SKArraySection]>, animated: Bool, setData: ([SKArraySection])->Void) {
        
        for changeset in stagedChangeset {
            performBatch(animated: animated, updates: {
                setData(changeset.data)
                
                if !changeset.sectionDeleted.isEmpty {
                    deleteSections(IndexSet(changeset.sectionDeleted))
                }
                
                if !changeset.sectionInserted.isEmpty {
                    insertSections(IndexSet(changeset.sectionInserted))
                }
                
                if !changeset.sectionUpdated.isEmpty {
                    reloadSections(IndexSet(changeset.sectionUpdated))
                }
                
                for (source, target) in changeset.sectionMoved {
                    moveSection(source, toSection: target)
                }
                
                if !changeset.elementDeleted.isEmpty {
                    deleteItems(at: changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
                }
                
                if !changeset.elementInserted.isEmpty {
                    insertItems(at: changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
                }
                
                if !changeset.elementUpdated.isEmpty {
                    reloadItems(at: changeset.elementUpdated.map { IndexPath(item: $0.element, section: $0.section) })
                }
                
                for (source, target) in changeset.elementMoved {
                    moveItem(at: IndexPath(item: source.element, section: source.section), to: IndexPath(item: target.element, section: target.section))
                }
                
            }, completion: nil)
        }
        
    }
}
