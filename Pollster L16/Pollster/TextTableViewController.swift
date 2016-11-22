//
//  TextTableViewController.swift
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class TextTableViewController: UITableViewController, UITextViewDelegate
{
    // MARK: Public API
    
    // outer Array is the sections
    // inner Array is the data in each row

    var data: [Array<String>]? {
        didSet {
            if oldValue == nil || data == nil {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: Text View Handling
    
    // this can be overridden to customize the look of the UITextViews

    func createTextViewForIndexPath(_ indexPath: IndexPath?) -> UITextView {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textView.isScrollEnabled = true
        textView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        textView.isOpaque = false
        textView.backgroundColor = UIColor.clear
        return textView
    }
    
    private func cellForTextView(_ textView: UITextView) -> UITableViewCell? {
        var view = textView.superview
        while (view != nil) && !(view! is UITableViewCell) { view = view!.superview }
        return view as? UITableViewCell
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?[section].count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let textView = createTextViewForIndexPath(indexPath)
        textView.frame = cell.contentView.bounds
        textViewWidth = textView.frame.size.width
        textView.text = data?[indexPath.section][indexPath.row]
        textView.delegate = self
        cell.contentView.addSubview(textView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        if data != nil {
            data![toIndexPath.section].insert(data![fromIndexPath.section][fromIndexPath.row], at: toIndexPath.row)
            let fromRow = fromIndexPath.row + ((toIndexPath.row < fromIndexPath.row) ? 1 : 0)
            data![fromIndexPath.section].remove(at: fromRow)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            data?[indexPath.section].remove(at: indexPath.row)
        }
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAtIndexPath(indexPath)
    }
    
    private var textViewWidth: CGFloat?
    private lazy var sizingTextView: UITextView = self.createTextViewForIndexPath(nil)

    private func heightForRowAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
        if let dataQandA = data,
            indexPath.section < dataQandA.count &&
            indexPath.row < dataQandA[indexPath.section].count {
            if let contents = data?[indexPath.section][indexPath.row] {
                if let textView = visibleTextViewWithContents(contents) {
                    return textView.sizeThatFits(CGSize(width: textView.bounds.size.width, height: tableView.bounds.size.height)).height + 1.0
                } else {
                    let width = textViewWidth ?? tableView.bounds.size.width
                    sizingTextView.text = contents
                    return sizingTextView.sizeThatFits(CGSize(width: width, height: tableView.bounds.size.height)).height + 1.0
                }
            }
        }
        return UITableViewAutomaticDimension
    }
    
    private func visibleTextViewWithContents(_ contents: String) -> UITextView? {
        for cell in tableView.visibleCells {
            for subview in cell.contentView.subviews {
                if let textView = subview as? UITextView , textView.text == contents {
                    return textView
                }
            }
        }
        return nil
    }

    // MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        if let cell = cellForTextView(textView), let indexPath = tableView.indexPath(for: cell) {
            data?[indexPath.section][indexPath.row] = textView.text
        }
        updateRowHeights()
        let editingRect = textView.convert(textView.bounds, to: tableView)
        if !tableView.bounds.contains(editingRect) {
            // should actually scroll to be clear of keyboard too
            // but for now at least scroll to visible ...
            tableView.scrollRectToVisible(editingRect, animated: true)
        }
        textView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: CharacterSet.newlines) != nil {
            returnKeyPressed(inTextView: textView)
            return false
        } else {
            return true
        }
    }
    
    func returnKeyPressed(inTextView textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @objc private func updateRowHeights() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: Content Size Category Change Notifications
    
    private var contentSizeObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentSizeObserver = NotificationCenter.default.addObserver(
        forName: NSNotification.Name.UIContentSizeCategoryDidChange,
        object: nil,
        queue: OperationQueue.main
        ) { notification in
            // give all the UITextViews a chance to react, then resize our row heights
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateRowHeights), userInfo: nil, repeats: false)
        }
    }
    
    deinit {
        if contentSizeObserver != nil {
            NotificationCenter.default.removeObserver(contentSizeObserver!)
            contentSizeObserver = nil
        }
    }
}
