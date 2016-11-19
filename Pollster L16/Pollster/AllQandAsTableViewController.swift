//
//  AllQandAsTableViewController.swift
//  Pollster
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit
import CloudKit

class AllQandAsTableViewController: UITableViewController
{
    // MARK: Model
    
    var allQandAs = [CKRecord]() { didSet { tableView.reloadData() } }
    
    // MARK: View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllQandAs()
        iCloudSubscribeToQandAs()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        iCloudUnsubscribeToQandAs()
    }
    
    // MARK: Private Implementation
    
    private let database = CKContainer.default().publicCloudDatabase
    
    private func fetchAllQandAs() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: Cloud.Entity.QandA, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: Cloud.Attribute.Question, ascending: true)]
        database.perform(query, inZoneWith: nil) { (records, error) in
            if records != nil {
                DispatchQueue.main.async {
                    self.allQandAs = records!
                }
            }
        }
    }
    
    // MARK: Subscription
    
    private let subscriptionID = "All QandA Creations and Deletions"
    private var cloudKitObserver: NSObjectProtocol?
    
    private func iCloudSubscribeToQandAs() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKSubscription(
            recordType: Cloud.Entity.QandA,
            predicate: predicate,
            subscriptionID: self.subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordDeletion]
        )
        // subscription.notificationInfo = ...
        database.save(subscription, completionHandler: { (savedSubscription, error) in
            if error?._code == CKError.serverRejectedRequest.rawValue {
                // ignore
            } else if error != nil {
                // report
            }
        }) 
        cloudKitObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: CloudKitNotifications.NotificationReceived),
            object: nil,
            queue: OperationQueue.main,
            using: { notification in
                if let ckqn = (notification as NSNotification).userInfo?[CloudKitNotifications.NotificationKey] as? CKQueryNotification {
                    self.iCloudHandleSubscriptionNotification(ckqn)
                }
            }
        )
    }
    
    private func iCloudUnsubscribeToQandAs() {
        // we forgot to stop listening to the radio station in the lecture demo!
        // here's how we do that ...
        if let observer = cloudKitObserver {
            NotificationCenter.default.removeObserver(observer)
            cloudKitObserver = nil
        }
        database.delete(withSubscriptionID: self.subscriptionID) { (subscription, error) in
            // handle it
        }
    }
    
    private func iCloudHandleSubscriptionNotification(_ ckqn: CKQueryNotification)
    {
        if ckqn.subscriptionID == self.subscriptionID {
            if let recordID = ckqn.recordID {
                switch ckqn.queryNotificationReason {
                case .recordCreated:
                    database.fetch(withRecordID: recordID) { (record, error) in
                        if record != nil {
                            DispatchQueue.main.async {
                                self.allQandAs = (self.allQandAs + [record!]).sorted {
                                    return $0.question < $1.question
                                }
                            }
                        }
                    }
                    
                case .recordDeleted:
                    DispatchQueue.main.async {
                        self.allQandAs = self.allQandAs.filter { $0.recordID != recordID }
                    }
                default:
                    break
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allQandAs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QandA Cell", for: indexPath)
        cell.textLabel?.text = allQandAs[(indexPath as NSIndexPath).row].question
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allQandAs[(indexPath as NSIndexPath).row].wasCreatedByThisUser
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = allQandAs[(indexPath as NSIndexPath).row]
            database.delete(withRecordID: record.recordID) { (deletedRecord, error) in
                // handle errors
            }
            allQandAs.remove(at: (indexPath as NSIndexPath).row)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show QandA" {
            if let ckQandATVC = segue.destination as? CloudQandATableViewController {
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    ckQandATVC.ckQandARecord = allQandAs[(indexPath as NSIndexPath).row]
                } else {
                    ckQandATVC.ckQandARecord = CKRecord(recordType: Cloud.Entity.QandA)
                }
            }
        }
    }
}
