//
//  MKGPX.swift
//  Trax
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//
//  Enhancements to GPX.Waypoint to support MKMapView

import MapKit

// EditableWaypoints are draggable
// so their coordinate needs to be settable

class EditableWaypoint : GPX.Waypoint
{
    override var coordinate: CLLocationCoordinate2D {
        get {
            return super.coordinate
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}

extension GPX.Waypoint : MKAnnotation
{
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { return name }
    
    var subtitle: String? { return info }
    
    var thumbnailURL: URL? {
        return getImageURLofType("thumbnail")
    }
    
    var imageURL: URL? {
        return getImageURLofType("large")
    }
    
    // look in the hyperlink information from the GPX file
    // try to find a url with a given type

    fileprivate func getImageURLofType(_ type: String?) -> URL? {
        for link in links {
            if link.type == type {
                return link.url as URL?
            }
        }
        return nil
    }
}
