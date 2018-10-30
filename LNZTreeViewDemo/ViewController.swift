//
//  ViewController.swift
//  LNZTreeViewDemo
//
//  Created by Giuseppe Lanza on 07/11/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import UIKit
import LNZTreeView

class CustomUITableViewCell: UITableViewCell
{
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        guard var imageFrame = imageView?.frame else { return }
        
        let offset = CGFloat(indentationLevel) * indentationWidth
        imageFrame.origin.x += offset
        imageView?.frame = imageFrame
    }
}


class Node: NSObject, TreeNodeProtocol {
    
    var identifier: String
    var isExpandable: Bool {
        return children != nil
    }
    
    var children: [Node]?
    
    init(withIdentifier identifier: String, andChildren children: [Node]? = nil) {
        self.identifier = identifier
        self.children = children
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var treeView: LNZTreeView!
    var root = [Node]()
    var selectedNode: Node?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        treeView.register(UINib(nibName: "ExpandArrowCell", bundle: nil), forCellReuseIdentifier: "ExpandArrowCell")

        treeView.tableViewRowAnimation = .right

        treeView.isExpandOnSelect = false
        generateRandomNodes()
        treeView.resetTree()
    }
    
    func generateRandomNodes() {
        let depth = 2
        let rootSize = 5
        
        var root: [Node]!
        
        var lastLevelNodes: [Node]?
        for i in 0..<depth {
            guard let lastNodes = lastLevelNodes else {
                root = generateNodes(rootSize, depthLevel: i)
                lastLevelNodes = root
                continue
            }
            
            var thisDepthLevelNodes = [Node]()
            for node in lastNodes {
                guard arc4random()%2 == 1 else { continue }
                let childrenNumber = Int(arc4random()%5 + 1)
                let children = generateNodes(childrenNumber, depthLevel: i)
                node.children = children
                thisDepthLevelNodes += children
            }
            
            lastLevelNodes = thisDepthLevelNodes
        }
        
        self.root = root
    }
    
    func generateNodes(_ numberOfNodes: Int, depthLevel: Int) -> [Node] {
        let nodes = Array(0..<numberOfNodes).map { i -> Node in
            return Node(withIdentifier: "\(arc4random()%UInt32.max)")
        }
        
        return nodes
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: LNZTreeViewDataSource {
    func numberOfSections(in treeView: LNZTreeView) -> Int {
        return 1
    }
    
    func treeView(_ treeView: LNZTreeView, numberOfRowsInSection section: Int, forParentNode parentNode: TreeNodeProtocol?) -> Int {
        guard let parent = parentNode as? Node else {
            return root.count
        }
        
        return parent.children?.count ?? 0
    }
    
    func treeView(_ treeView: LNZTreeView, nodeForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> TreeNodeProtocol {
        guard let parent = parentNode as? Node else {
            return root[indexPath.row]
        }

        return parent.children![indexPath.row]
    }
    
    func treeView(_ treeView: LNZTreeView, cellForRowAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?, isExpanded: Bool) -> UITableViewCell {
        
        let node: Node
        if let parent = parentNode as? Node {
            node = parent.children![indexPath.row]
        } else {
            node = root[indexPath.row]
        }
        
        let cell = treeView.dequeueReusableCell(withIdentifier: "ExpandArrowCell", for: node, inSection: indexPath.section) as! ExpandArrowCell

        if node.isExpandable {
            if isExpanded {
                cell.expandButton.setImage(UIImage(named: "index_folder_indicator_open"), for: .normal)
            } else {
                cell.expandButton.setImage(UIImage(named: "index_folder_indicator"), for: .normal)
            }
        } else {
            cell.expandButton.setImage(nil, for: .normal)
        }
        cell.onExpand = {
            treeView.toggle(node: node, inSection: 0)
        }
        cell.nodeTitleLabel?.text = node.identifier
        cell.accessoryType = selectedNode == node ? .checkmark : .none
        return cell
    }
}

extension ViewController: LNZTreeViewDelegate {
    func treeView(_ treeView: LNZTreeView, heightForNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) -> CGFloat {
        return 60
    }
    
    func treeView(_ treeView: LNZTreeView, didSelectNodeAt indexPath: IndexPath, forParentNode parentNode: TreeNodeProtocol?) {
        
        if let parent = parentNode as? Node {
            selectedNode = parent.children![indexPath.row]
        } else {
            selectedNode = root[indexPath.row]
        }
        
        treeView.reloadNode(node: selectedNode!)
        
    }
}
