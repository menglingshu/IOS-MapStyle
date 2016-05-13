//
//  MKMapViewUtils.swift
//  RotateAnnotation
//
//  Created by user on 6/30/15.
//  Copyright (c) 2015 ken. All rights reserved.
//

import UIKit
import MapKit

let MERCATOR_OFFSET:Double = 268435456
let MERCATOR_RADIUS:Double = 85445659.44705395

extension MKMapView {
    
    func longitudeToPixelSpaceX(longitude:Double) -> Double {
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0)
    }
    
    func latitudeToPixelSpaceY(latitude:Double) -> Double {
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * Double(logf((1 + sinf(Float(latitude * M_PI) / 180.0)) / (1 - sinf(Float(latitude * M_PI) / 180.0)))) / 2.0)
    }
    
    func pixelSpaceXToLongitude(pixelX:Double) -> Double {
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI
    }
    
    func pixelSpaceYToLatitude(pixelY:Double) -> Double {
        return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI
    }
    
    // MARK: Helper methods
    
    func coordinateSpanWithMapView(mapView:MKMapView, centerCoordinate:CLLocationCoordinate2D, andZoomLevel zoomLevel:Double) -> MKCoordinateSpan
    {
        // convert center coordiate to pixel space
        let centerPixelX = self.longitudeToPixelSpaceX(centerCoordinate.longitude)
        let centerPixelY = self.latitudeToPixelSpaceY(centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent:Double = 20 - zoomLevel;
        let zoomScale = pow(2, zoomExponent)
        
        // scale the map’s size in pixel space
        let mapSizeInPixels = mapView.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2)
        
        // find delta between left and right longitudes
        let minLng = self.pixelSpaceXToLongitude(topLeftPixelX)
        let maxLng = self.pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng;
        
        // find delta between top and bottom latitudes
        let minLat = self.pixelSpaceYToLatitude(topLeftPixelY)
        let maxLat = self.pixelSpaceYToLatitude(topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // create and return the lat/lng span
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        return span
    }
    
    // MARK: Public methods
    /*
    func setCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double, animated:Bool)
    {
        // clamp large numbers to 28
        let nZoomLevel = min(zoomLevel, 28)
        
        // use the zoom level to compute the region
        let span = self.coordinateSpanWithMapView(self, centerCoordinate: centerCoordinate, andZoomLevel: nZoomLevel)
        //let region = MKCoordinateRegionMake(centerCoordinate, span)
        
        // set the region like normal
        self.setRegion(region, animated: animated)
    }
    
    // Return the current map zoomLevel equivalent, just like above but in reverse
    func getZoomLevel() -> Double {
        //let reg = self.region // the current visible region
        let span = reg.span // the deltas
        let centerCoordinate = reg.center // the center in degrees
        // Get the left and right most lonitudes
        let leftLongitude = (centerCoordinate.longitude-(span.longitudeDelta/2))
        let rightLongitude = (centerCoordinate.longitude+(span.longitudeDelta/2))
        let mapSizeInPixels = self.bounds.size // the size of the display window
        
        // Get the left and right side of the screen in fully zoomed-in pixels
        let leftPixel = self.longitudeToPixelSpaceX(leftLongitude)
        let rightPixel = self.longitudeToPixelSpaceX(rightLongitude)
        // The span of the screen width in fully zoomed-in pixels
        let pixelDelta = abs(rightPixel-leftPixel)
        
        // The ratio of the pixels to what we're actually showing
        let zoomScale = Double(mapSizeInPixels.width) / pixelDelta
        // Inverse exponent
        let zoomExponent = log2(zoomScale)
        // Adjust our scale
        let zoomLevel = zoomExponent + 20
        return zoomLevel
    }*/
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
