//
//  MediaItem.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

// holds the network url and aspectRatio of an image attached to a Tweet
// created automatically when a Tweet object is created

public class MediaItem: NSObject
{
    public let url: URL
    public let aspectRatio: Double
    
    public override var description: String { return "\(url.absoluteString) (aspect ratio = \(aspectRatio))" }
    
    // MARK: - Internal Implementation
    
    init?(data: NSDictionary?) {
        guard
            let height = data?.value(forKeyPath: TwitterKey.Height) as? Double , height > 0,
            let width = data?.value(forKeyPath: TwitterKey.Width) as? Double , width > 0,
            let urlString = data?.value(forKeyPath: TwitterKey.MediaURL) as? String,
            let url = URL(string: urlString)
        else {
            return nil
        }
        self.url = url
        self.aspectRatio = width/height
    }
    
    struct TwitterKey {
        static let MediaURL = "media_url_https"
        static let Width = "sizes.small.w"
        static let Height = "sizes.small.h"
    }
}
