//
//  TreeViewMockDelegate.swift
//  PFRPG rdTests
//
//  Created by Giuseppe Lanza on 24/09/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import XCTest
import UIKit
@testable import LNZTreeView

class TreeViewMockDelegate<T: ExpandableNode>: LNZTreeViewDelegate {
    var roots: [[T]]!
    
    var expandedNodes = [T]()
    var collapsedNodes = [T]()
    
    var selectedNodes = [T]()
    
    var didSelectNodeExpectation: XCTestExpectation?
    var didExpandNodeExpectation: XCTestExpectation?
    var didCollapseNodeExpectation: XCTestExpectation?
    
    func node(at indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> T {
        var node: T!
        if let parent = parentNode as? T {
            node = (parent.children![indexPath.row] as! T)
        } else {
            node = roots[indexPath.section][indexPath.row]
        }
        return node
    }
    
    func treeView(_ treeView: LNZTreeView, didExpandNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) {
        expandedNodes.append(node(at: indexPath, forParentNode: parentNode))
        didExpandNodeExpectation?.fulfill()
    }
    
    func treeView(_ treeView: LNZTreeView, didCollapseNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) {
        collapsedNodes.append(node(at: indexPath, forParentNode: parentNode))
        didCollapseNodeExpectation?.fulfill()
    }
    
    func treeView(_ treeView: LNZTreeView, didSelectNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) {
        // Unselect
        let node = self.node(at: indexPath, forParentNode: parentNode)
        if let idx = selectedNodes.firstIndex(where: {$0.identifier == node.identifier}) {
            selectedNodes.remove(at: idx)
        } else {
            selectedNodes.append(node)
        }
        didSelectNodeExpectation?.fulfill()
    }
    
    
}
