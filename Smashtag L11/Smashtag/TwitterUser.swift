//
//  TwitterUser.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class TwitterUser: NSManagedObject
{
    // a class method which
    // returns a TwitterUser from the database if Twitter.User has already been put in
    // or returns a newly-added-to-the-database TwitterUser if not

    class func twitterUserWithTwitterInfo(_ twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser?
    {
      
        let request = NSFetchRequest<TwitterUser>(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
   //     let twitterUser = try? context.fetch(request)
        if let twitterUser = (try? context.fetch(request))?.first /*as? TwitterUser*/ {
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObject(forEntityName: "TwitterUser", into: context) as? TwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            return twitterUser
        }
        return nil
    }
}
