//
//  Tweet.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class Tweet: NSManagedObject
{
    // a class method which
    // returns a Tweet from the database if Twitter.Tweet has already been put in
    // or returns a newly-added-to-the-database Tweet if not

    class func tweetWithTwitterInfo(_ twitterInfo: Twitter.Tweet, inManagedObjectContext context: NSManagedObjectContext) -> Tweet?
    {
    
        let request = NSFetchRequest<Tweet>(entityName: "Tweet")
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.fetch(request))?.first /*as? Tweet */{
            // found this tweet in the database, return it ...
            return tweet
        } else if let tweet = NSEntityDescription.insertNewObject(forEntityName: "Tweet", into: context) as? Tweet {
            // created a new tweet in the database
            // load it up with information from the Twitter.Tweet ...
            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            tweet.posted = twitterInfo.created
            tweet.tweeter = TwitterUser.twitterUserWithTwitterInfo(twitterInfo.user, inManagedObjectContext: context)
            return tweet
        }

        return nil
    }
}
