//
//  ImageViewController.swift
//  Cassini
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    var imageURL: URL? {
        didSet {
            image = nil
            // we'll postpone our (expensive) fetch
            // until we know we're going to appear on screen
            // (we know this below in viewWillAppear)
            // otherwise why waste the resources?
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            // fire up the spinner
            // because we're about to fork something off on another thread
            spinner?.startAnimating()
           
            DispatchQueue.global(qos: .userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                            // image's set will stop the spinner animating
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        // just so you can see in the console when this happens
                        print("ignored data returned from url \(url)")
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            // all three of the next lines of code
            // are necessary to make zooming work
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    // zooming will not work if you don't implement
    // this UIScrollViewDelegate method
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private var imageView = UIImageView()
    
    // a little helper var
    // it just makes sure things are kept in sync
    // whenever we change the image we're displaying
    // it's purely to make our code look prettier elsewhere in this class
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    // MARK: View Controller Lifecycle

    // we know we're going to go on screen in this method
    // so we can no longer wait to fire off our (expensive) image fetch

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }

    // note that we build some of our UI in the storyboard
    // by dragging a UIScrollView out into our scene
    // and we build some of it here by adding our UIImageView
    // as a subview of the UIScrollView

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
}
