//
//  CloudQandATableViewController.swift
//  Pollster
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CloudKit

class CloudQandATableViewController: QandATableViewController
{
    // MARK: Model

    var ckQandARecord: CKRecord {
        get {
            if _ckQandARecord == nil {
                _ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
            }
            return _ckQandARecord!
        }
        set {
            _ckQandARecord = newValue
        }
    }
    
    // MARK: UITextViewDelegate
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        super.textViewDidEndEditing(textView)
        iCloudUpdate()
    }
    
    // MARK: Private Implementation

    private var _ckQandARecord: CKRecord? {
        didSet {
            let question = ckQandARecord[Cloud.Attribute.Question] as? String ?? ""
            let answers = ckQandARecord[Cloud.Attribute.Answers] as? [String] ?? []
            qanda = QandA(question: question, answers: answers)
            
            asking = ckQandARecord.wasCreatedByThisUser
        }
    }
    
    private let database = CKContainer.default().publicCloudDatabase
    
    @objc private func iCloudUpdate() {
        if !qanda.question.isEmpty && !qanda.answers.isEmpty {
            ckQandARecord[Cloud.Attribute.Question] = qanda.question as CKRecordValue?
            ckQandARecord[Cloud.Attribute.Answers] = qanda.answers as CKRecordValue?
            iCloudSaveRecord(ckQandARecord)
        }
    }
    
    private func iCloudSaveRecord(_ recordToSave: CKRecord) {
        database.save(recordToSave, completionHandler: { (savedRecord, error) in
            if error?._code == CKError.serverRecordChanged.rawValue {
                // optimistic locking failed, ignore
            } else if error != nil {
                self.retryAfterError(error as NSError?, withSelector: #selector(self.iCloudUpdate))
            }
        }) 
    }
    
    private func retryAfterError(_ error: NSError?, withSelector selector: Selector) {
        if let retryInterval = error?.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            DispatchQueue.main.async {
                Timer.scheduledTimer(
                    timeInterval: retryInterval,
                    target: self, selector: selector,
                    userInfo: nil, repeats: false
                )
            }
        }
    }
}
