//
//  LNZTreeViewTests.swift
//  PFRPG rdTests
//
//  Created by Giuseppe Lanza on 24/09/2017.
//  Copyright © 2017 Giuseppe Lanza. All rights reserved.
//

import XCTest
@testable import LNZTreeView

class LNZTreeViewTests: XCTestCase {
    let treeView = LNZTreeView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let dataSource = TreeViewMockDataSource<TestNode>()
    let delegate = TreeViewMockDelegate<TestNode>()
    
    func testNoDataSource() {
        window.addSubview(treeView)
        XCTAssertEqual(treeView.numberOfSections(), 0)
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), 0)
    }
    
    func testLoadRoot() {
        let roots: [[TestNode]] = Array(0..<100).map { (i) -> [TestNode] in
            return Array(0..<100).map { (j) -> TestNode in
                return TestNode(identifier: "sec\(i)_row\(j)", isExpandable: false, children: nil)
            }
        }
        dataSource.roots = roots
        treeView.dataSource = dataSource
        
        window.addSubview(treeView)

        XCTAssertEqual(treeView.numberOfSections(), roots.count)
        for (i, root) in roots.enumerated() {
            XCTAssertEqual(treeView.numberOfTotalNodesInSection(i), root.count)
        }
    }
    
    func testOpenEmptyNode() {
        let node = TestNode(identifier: "sec0_row0", isExpandable: true, children: nil)
        dataSource.roots = [[node]]
        delegate.roots = [[node]]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)
        XCTAssertEqual(treeView.numberOfSections(), 1)
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), 1)
        
        let expect = expectation(description: "expandWaiter")
        delegate.didExpandNodeExpectation = expect

        let expanded = treeView.expand(node: node, inSection: 0)
        XCTAssertTrue(expanded)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), 1)
        
        XCTAssertEqual(delegate.expandedNodes, [node])
        XCTAssertTrue(delegate.collapsedNodes.isEmpty)
        XCTAssertTrue(delegate.selectedNodes.isEmpty)
    }
    
    func testOpenNode() {
        let childrenNodes = Array(0..<100).map { (j) -> TestNode in
            return TestNode(identifier: "child_sec0_row\(j)", isExpandable: false, children: nil)
        }
        let nodes = [
            TestNode(identifier: "sec0_row0", isExpandable: true, children: childrenNodes),
            TestNode(identifier: "sec0_row1", isExpandable: false, children: nil)
        ]
        
        dataSource.roots = [nodes]
        delegate.roots = [nodes]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)

        XCTAssertEqual(treeView.numberOfSections(), 1)
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count)
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), 0)

        let expect = expectation(description: "expandWaiter")
        delegate.didExpandNodeExpectation = expect
        
        let expanded = treeView.expand(node: nodes[0], inSection: 0)
        XCTAssertTrue(expanded)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count + childrenNodes.count)
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), childrenNodes.count)
        
        XCTAssertEqual(delegate.expandedNodes, [nodes[0]])
        XCTAssertTrue(delegate.collapsedNodes.isEmpty)
        XCTAssertTrue(delegate.selectedNodes.isEmpty)

    }
    
    func testCloseNode() {
        let childrenNodes = Array(0..<100).map { (j) -> TestNode in
            return TestNode(identifier: "child_sec0_row\(j)", isExpandable: false, children: nil)
        }
        let nodes = [
            TestNode(identifier: "sec0_row0", isExpandable: true, children: childrenNodes),
            TestNode(identifier: "sec0_row1", isExpandable: false, children: nil)
        ]
        
        dataSource.roots = [nodes]
        delegate.roots = [nodes]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)
        
        var expect = expectation(description: "expandWaiter")
        delegate.didExpandNodeExpectation = expect

        let expanded = treeView.expand(node: nodes[0], inSection: 0)
        XCTAssertTrue(expanded)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count + childrenNodes.count)
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), (nodes[0].children?.count ?? 0))
        
        expect = expectation(description: "collapseWaiter")
        delegate.didCollapseNodeExpectation = expect


        let closed = treeView.collapse(node: nodes[0], inSection: 0)
        XCTAssertTrue(closed)
        
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count)
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), 0)

        XCTAssertEqual(delegate.expandedNodes, [nodes[0]])
        XCTAssertEqual(delegate.collapsedNodes, [nodes[0]])
        XCTAssertTrue(delegate.selectedNodes.isEmpty)

    }
    
    func testOpenMultipleNodes() {
        let childrenNodes = Array(0..<100).map { (j) -> TestNode in
            return TestNode(identifier: "child_sec0_row\(j)", isExpandable: false, children: nil)
        }
        let nodes = [
            TestNode(identifier: "sec0_row0", isExpandable: true, children: childrenNodes),
            TestNode(identifier: "sec0_row1", isExpandable: true, children: childrenNodes)
        ]

        dataSource.roots = [nodes]
        delegate.roots = [nodes]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)
        var expanded = treeView.expand(node: nodes[0], inSection: 0)
        XCTAssertTrue(expanded)
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count + (nodes[0].children?.count ?? 0))
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), (nodes[0].children?.count ?? 0))
        
        expanded = treeView.expand(node: nodes[1], inSection: 0)
        XCTAssertTrue(expanded)
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count + (nodes[0].children?.count ?? 0) + (nodes[1].children?.count ?? 0))
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[1]), (nodes[1].children?.count ?? 0))
    }
    
    func testCloseMultipleNodes() {
        let childrenNodes = Array(0..<100).map { (j) -> TestNode in
            return TestNode(identifier: "child_sec0_row\(j)", isExpandable: false, children: nil)
        }
        let nodes = [
            TestNode(identifier: "sec0_row0", isExpandable: true, children: childrenNodes),
            TestNode(identifier: "sec0_row1", isExpandable: true, children: childrenNodes)
        ]
        
        dataSource.roots = [nodes]
        delegate.roots = [nodes]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)

        var expect = expectation(description: "expandWaiter")
        delegate.didExpandNodeExpectation = expect

        treeView.expand(node: nodes[0], inSection: 0)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        expect = expectation(description: "expandWaiter")
        delegate.didExpandNodeExpectation = expect
        
        treeView.expand(node: nodes[1], inSection: 0)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        expect = expectation(description: "collapseWaiter")
        delegate.didCollapseNodeExpectation = expect

        var collapsed = treeView.collapse(node: nodes[1], inSection: 0)
        XCTAssertTrue(collapsed)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count + (nodes[0].children?.count ?? 0))
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[1]), 0)

        expect = expectation(description: "collapseWaiter")
        delegate.didCollapseNodeExpectation = expect

        collapsed = treeView.collapse(node: nodes[0], inSection: 0)
        XCTAssertTrue(collapsed)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count)
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), 0)
        
        XCTAssertEqual(delegate.expandedNodes, nodes)
        XCTAssertEqual(delegate.collapsedNodes, [nodes[1], nodes[0]])
        XCTAssertTrue(delegate.selectedNodes.isEmpty)
    }
    
    func testDoubleOpenNode() {
        let node = TestNode(identifier: "sec0_row0", isExpandable: true, children: nil)
        dataSource.roots = [[node]]
        delegate.roots = [[node]]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)
        
        let expect = expectation(description: "expandWaiter")
        delegate.didExpandNodeExpectation = expect

        var expanded = treeView.expand(node: node, inSection: 0)
        waitForExpectations(timeout: 1, handler: nil)
        
        
        expanded = treeView.expand(node: node, inSection: 0)
        XCTAssertTrue(expanded)
        
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), 1)
        
        XCTAssertEqual(delegate.expandedNodes, [node])
        XCTAssertTrue(delegate.collapsedNodes.isEmpty)
        XCTAssertTrue(delegate.selectedNodes.isEmpty)
    }
    
    func testCloseEmptyNode() {
        let node = TestNode(identifier: "sec0_row0", isExpandable: true, children: nil)
        dataSource.roots = [[node]]
        delegate.roots = [[node]]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)
        
        var expect = expectation(description: "expandWaiter")
        delegate.didExpandNodeExpectation = expect

        let expanded = treeView.expand(node: node, inSection: 0)
        XCTAssertTrue(expanded)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        expect = expectation(description: "expandWaiter")
        delegate.didCollapseNodeExpectation = expect

        let collapsed = treeView.collapse(node: node, inSection: 0)
        XCTAssertTrue(collapsed)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(delegate.expandedNodes, [node])
        XCTAssertEqual(delegate.collapsedNodes, [node])
        XCTAssertTrue(delegate.selectedNodes.isEmpty)
    }
    
    func testSelectExpandable() {
        let node = TestNode(identifier: "sec0_row0", isExpandable: true, children: nil)
        dataSource.roots = [[node]]
        delegate.roots = [[node]]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)
        
        var didSelectNodeExpectation = expectation(description: "selectd node")
        delegate.didSelectNodeExpectation = didSelectNodeExpectation
        
        let didExpandNodeExpectation = expectation(description: "expand parent node")
        delegate.didExpandNodeExpectation = didExpandNodeExpectation

        var selected = treeView.select(node: node, inSection: 0)
        XCTAssertTrue(selected)

        wait(for: [didExpandNodeExpectation, didSelectNodeExpectation], timeout: 1)
        
        XCTAssertEqual(delegate.expandedNodes, [node])
        XCTAssertTrue(delegate.collapsedNodes.isEmpty)
        XCTAssertEqual(delegate.selectedNodes, [node])

        didSelectNodeExpectation = expectation(description: "selectd node")
        delegate.didSelectNodeExpectation = didSelectNodeExpectation
        
        let didCollapseNodeExpectation = expectation(description: "didCollapseNodeExpectation parent node")
        delegate.didCollapseNodeExpectation = didCollapseNodeExpectation

        selected = treeView.select(node: node, inSection: 0)
        XCTAssertTrue(selected)

        wait(for: [didCollapseNodeExpectation, didSelectNodeExpectation], timeout: 1)
        
        XCTAssertEqual(delegate.expandedNodes, [node])
        XCTAssertEqual(delegate.collapsedNodes, [node])
        XCTAssertTrue(delegate.selectedNodes.isEmpty)
    }
    
    func testSelectNotExpandable() {
        let node = TestNode(identifier: "sec0_row0", isExpandable: false, children: nil)
        dataSource.roots = [[node]]
        delegate.roots = [[node]]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        
        window.addSubview(treeView)
        
        let selected = treeView.select(node: node, inSection: 0)
        XCTAssertTrue(selected)
        
        XCTAssertTrue(delegate.expandedNodes.isEmpty)
        XCTAssertTrue(delegate.collapsedNodes.isEmpty)
        XCTAssertEqual(delegate.selectedNodes, [node])

    }
    
    func testShouldSelectNodeNotExpand() {
        // given isExpandOnSelect = false in first node
        let childrenNodes = Array(0..<100).map { (j) -> TestNode in
            return TestNode(identifier: "child_sec0_row\(j)", isExpandable: false, children: nil)
        }
        let nodes = [
            TestNode(identifier: "sec0_row0", isExpandable: true, children: childrenNodes),
            TestNode(identifier: "sec0_row1", isExpandable: false, children: nil)
        ]
        
        dataSource.roots = [nodes]
        delegate.roots = [nodes]
        
        treeView.dataSource = dataSource
        treeView.delegate = delegate
        // when
        treeView.isExpandOnSelect = false
        window.addSubview(treeView)
        // then tree is populated
        XCTAssertEqual(treeView.numberOfSections(), 1)
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count)
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), 0)
        
        let didSelectNodeExpectation = expectation(description: "select")
        delegate.didSelectNodeExpectation = didSelectNodeExpectation
        
        // when call expand
        let expanded = treeView.select(node: nodes[0], inSection: 0)
        // them should not expand and selected
        XCTAssertTrue(expanded)
        
        wait(for: [didSelectNodeExpectation], timeout: 1)
        
        XCTAssertEqual(treeView.numberOfTotalNodesInSection(0), nodes.count)
        XCTAssertEqual(treeView.numberOfNodesForSection(0, inParent: nodes[0]), 0)
        
        XCTAssertTrue(delegate.expandedNodes.isEmpty)
        XCTAssertTrue(delegate.collapsedNodes.isEmpty)
        XCTAssertEqual(delegate.selectedNodes, [nodes[0]])
        
    }
}
