//
//  QandATableViewController
//  Pollster
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


struct QandA {
    var question: String
    var answers: [String]
}

class QandATableViewController: TextTableViewController
{
    // MARK: - Public API

    var qanda: QandA {
        get {
            var answers = [String]()
            if data?.count > 1 {
                for answer in data?.last ?? [] {
                    if !answer.isEmpty { answers.append(answer) }
                }
            }
            return QandA(question: data?.first?.first ?? "", answers: answers)
        }
        set {
            data = [[newValue.question], newValue.answers]
            manageEmptyRow()
        }
    }
    
    var asking = false {
        didSet {
            if asking != oldValue {
                tableView.isEditing = asking
                tableView.reloadData()
                manageEmptyRow()
            }
        }
    }
    
    var answering: Bool {
        get { return !asking }
        set { asking = !newValue }
    }

    var answer: String? {
        didSet {
            var answerIndex = 0
            while answerIndex < qanda.answers.count {
                if qanda.answers[answerIndex] == answer {
                    let indexPath = IndexPath(row: answerIndex, section: Section.Answers)
                    // be sure we're on screen before we do this (for animation, etc.)
                    Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(chooseAnswer(_:)), userInfo: indexPath , repeats: false)
                    break
                }
                answerIndex += 1
            }
        }
    }
    
    struct Section {
        static let Question = 0
        static let Answers = 1
    }
    
    // MARK: - Private Implementation
    
    func chooseAnswer(_ timer: Timer) {
        if let indexPath = timer.userInfo as? IndexPath {
            if tableView.indexPathForSelectedRow != indexPath {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
    }

    // override this to set the UITextView up like we want
    // want .Body font, some margin around the text, and only editable if we are editing the Q&A

    override func createTextViewForIndexPath(_ indexPath: IndexPath?) -> UITextView {
        let textView = super.createTextViewForIndexPath(indexPath)
        let font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        textView.font = font.withSize(font.pointSize * 1.7)
        textView.textContainerInset = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        textView.isUserInteractionEnabled = asking
        return textView
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case Section.Question: return "Question"
            case Section.Answers: return "Answers"
            default: return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // only answers can be selected
        cell.selectionStyle = ((indexPath as NSIndexPath).section == Section.Answers) ? .gray : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return asking && (indexPath as NSIndexPath).section == Section.Answers
    }
    
    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        answer = data?[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // only answers can be selected
        return ((indexPath as NSIndexPath).section == Section.Answers) ? indexPath : nil
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        manageEmptyRow()
    }
    
    fileprivate func manageEmptyRow() {
        if data != nil {
            var emptyRow: Int?
            var row = 0
            while row < data![Section.Answers].count {
                let answer = data![Section.Answers][row]
                if answer.isEmpty {
                    if emptyRow != nil {
                        data![Section.Answers].remove(at: emptyRow!)
                        tableView.deleteRows(at: [IndexPath(row: emptyRow!, section: Section.Answers)], with: .automatic)
                        emptyRow = row-1
                    } else {
                        emptyRow = row
                        row += 1
                    }
                } else {
                    row += 1
                }
            }
            if emptyRow == nil {
                if asking {
                    data![Section.Answers].append("")
                    let indexPath = IndexPath(row: data![Section.Answers].count-1, section: Section.Answers)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            } else if !asking {
                data![Section.Answers].remove(at: emptyRow!)
                tableView.deleteRows(at: [IndexPath(row: emptyRow!, section: Section.Answers)], with: .automatic)
            }
        }
    }
}
