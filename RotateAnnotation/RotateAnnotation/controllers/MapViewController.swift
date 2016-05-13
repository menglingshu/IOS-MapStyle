//
//  MapViewController.swift
//  RotateAnnotation
//
//  Created by user on 6/30/15.
//  Copyright (c) 2015 ken. All rights reserved.
//

import UIKit
import MapKit
struct AreaLocation {
    var latitudeLeft:CLLocationDegrees
    var latitudeRight:CLLocationDegrees
    var longitudeUp:CLLocationDegrees
    var longitudeDown:CLLocationDegrees
}

protocol MapViewControllerDelegate : NSObjectProtocol {
    func clickBgButton(aView:UIView)
    func clickCloseButton()
}

func oriSpan() -> MKCoordinateSpan {
    return MKCoordinateSpanMake(0.00494, 0.00538)
}

func oriCenterCoordinate() -> CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(30.658273, 104.067864)
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    var newLocCoordinate:CLLocationCoordinate2D!
    var strTitle:String = ""
    var dataArray:NSMutableArray = []
    weak var delegate: MapViewControllerDelegate!
    
    // const
    let spaceFNum = 0.003
    let oriZoomLevel:Double = 12
    var oriSpan:MKCoordinateSpan {
        get {
            return MKCoordinateSpanMake(0.00494, 0.00538)
        }
    }
    var oriCenterCoordinate:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(30.658273, 104.067864)
        }
    }
    let MERCATOR_OFFSET = 268435456
    let MERCATOR_RADIUS = 85445659.44705395
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initData()
        newLocCoordinate = oriCenterCoordinate
        _detailsAnnoArray = NSMutableArray()
        mapView.showsUserLocation = true
        mapView.scrollEnabled = true
        mapView.zoomEnabled = true
        mapView.delegate = self
        
        segmentController.addTarget(self, action: Selector("segmentValueChanged"), forControlEvents: UIControlEvents.ValueChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // add for test by ken
        self.setMapRegin(newLocCoordinate)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    // 初始化数据
    func initData() {
        let childAry = NSMutableArray()
        for(var i = 0; i < 8; i++ ){
            let child = MapItemInfoVO()
            child.strId = "\(i)"
            child.strTitle = "child\(i)"
            childAry.addObject(child)
        }
        for (var j = 0; j < 8; j++) {
            let item = MapItemInfoVO()
            item.strId = "\(j)"
            item.strTitle = "Item\(j)"
            let ary = NSMutableArray()
            let childCount = j
            for (var n = 0; n < childCount; n++) {
                if n < childAry.count {
                    ary.addObject(childAry.objectAtIndex(n))
                }
            }
            item.aryChild = ary
            self.dataArray .addObject(item)
        }
    }
    // 分割改变的数据
    func segmentValueChanged() {
        if _pinAnnotation != nil && self._detailsAnnoArray.count > 0 {
            if _detailsAnnoArray.count > 0 {
                let last = _detailsAnnoArray.lastObject as! DetailsAnnotation
                let pV = mapView.viewForAnnotation(_pinAnnotation) as! PinAnnotationView
                let dV = mapView.viewForAnnotation(last) as! DetailsAnnotationView
                dV.superview?.bringSubviewToFront(dV)
                pV.superview?.bringSubviewToFront(pV)
                
                let annoView = mapView.viewForAnnotation(last) as! DetailsAnnotationView
                annoView.cell.disapperItems({ () -> Void in
                    self.mapView .removeAnnotation(last)
                    self._detailsAnnoArray.removeLastObject()
                    if self._detailsAnnoArray.count > 0 {
                        self._detailsAnnotation = self._detailsAnnoArray.objectAtIndex(0) as! DetailsAnnotation
                    }else{
                        self._detailsAnnotation = nil
                    }
                    self.mapView(self.mapView, didSelectAnnotationView:self.mapView.viewForAnnotation(self._pinAnnotation))
//
//                    mapView(self.mapView, didSelectAnnotationView: _pinAnnotation)
                    
                    
                    // ken
//                    [self mapView:self.mapView didSelectAnnotationView:[self.mapView viewForAnnotation:_pinAnnotation]];
                })
            }
        }
    }
    
    func clickItemButton(btn:ItemView) {
        NSLog("Click item button _ \(btn.tag)")
    }
    
    func removeAllAnnotations() {
        let userAnnotation = mapView.userLocation
        let annotations = NSMutableArray(array: mapView.annotations)
        annotations.removeObject(userAnnotation)
        mapView.removeAnnotations(annotations as! [MKAnnotation])
    }
    
    func placeTempPins() {
        if _pinAnnotation != nil {
            mapView.deselectAnnotation(_pinAnnotation, animated: false)
        }
        self.removeAllAnnotations()
        let pinAnno = PinAnnotation(lat: newLocCoordinate.latitude, andLongitude: newLocCoordinate.longitude)
        mapView .addAnnotation(pinAnno)
    }
    
    func setMapRegin(coordinate:CLLocationCoordinate2D) {
        newLocCoordinate = coordinate
        var level = mapView.getZoomLevel()
        if level < oriZoomLevel {
            level = oriZoomLevel
        }
        mapView.setCenterCoordinate(newLocCoordinate, zoomLevel: level, animated: true)
        self.placeTempPins()
    }
    
    
    
    
    
    
    
    
    // MARK: Location
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        newLocCoordinate = userLocation.coordinate
        self.setMapRegin(newLocCoordinate)
        self.mapView.showsUserLocation = false
    }
    
    func mapView(mapView: MKMapView!, didFailToLocateUserWithError error: NSError!) {
        if error != nil {
            NSLog("locate failed: \(error.localizedDescription)")
        }else{
            NSLog("locate failed")
        }
    }
    
    func mapViewWillStartLocatingUser(mapView: MKMapView) {
        NSLog("start locate")
    }
    
    // MARK: Range
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if _detailsAnnoArray.count > 0 {
            let first = _detailsAnnoArray.objectAtIndex(0) as! DetailsAnnotation
            let pV = mapView.viewForAnnotation(_pinAnnotation) as! PinAnnotationView
            let dV = mapView.viewForAnnotation(first) as! DetailsAnnotationView
            dV.superview?.bringSubviewToFront(dV)
            pV.superview?.bringSubviewToFront(pV)
        }
        
        if _detailsAnnotation == nil {
            return
        }
        
        let pinPoint = mapView.convertCoordinate(_detailsAnnotation.coordinate, toPointToView: self.view)
        let bContains = CGRectContainsPoint(self.view.bounds, pinPoint)
        if bContains {
            let annoView = mapView.viewForAnnotation(_detailsAnnotation) as! DetailsAnnotationView
            let center = self.view.center
            let angle = Utils.getAngleByPoint(pinPoint, center: center)
            annoView.cell .rotationView(angle)
        }else{
            mapView .deselectAnnotation(_pinAnnotation, animated: false)
        }
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if _detailsAnnoArray.count > 0 {
            let first = _detailsAnnoArray.objectAtIndex(0) as! DetailsAnnotation
            let pV = mapView.viewForAnnotation(_pinAnnotation) as! PinAnnotationView
            let dV = mapView.viewForAnnotation(first) as! DetailsAnnotationView
            dV.superview?.bringSubviewToFront(dV)
            pV.superview?.bringSubviewToFront(pV)
        }
        if _detailsAnnotation != nil {
            let pinPoint = mapView.convertCoordinate(_detailsAnnotation.coordinate, toPointToView: self.view)
            let bContains = CGRectContainsPoint(self.view.bounds, pinPoint)
            if bContains == false {
                mapView.deselectAnnotation(_pinAnnotation, animated: false)
            }
        }
    }
    
    // MARK: Annotation
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        NSLog("【didChangeDragState】")
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if view.annotation!.isKindOfClass(PinAnnotation) {
            if _detailsAnnotation != nil && _detailsAnnotation.coordinate.latitude == view.annotation!.coordinate.latitude && _detailsAnnotation.coordinate.longitude == view.annotation!.coordinate.longitude {
                return;
            }
            _pinAnnotation = view.annotation as! PinAnnotation
            let detailsAnno = DetailsAnnotation(lat: view.annotation!.coordinate.latitude, andLongitude: view.annotation!.coordinate.longitude)
            detailsAnno.tag = self.segmentController.selectedSegmentIndex
            mapView.addAnnotation(detailsAnno)
            _detailsAnnoArray.insertObject(detailsAnno, atIndex: 0)
            
            if (_detailsAnnotation == nil) {
                _detailsAnnotation = detailsAnno
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if _detailsAnnoArray.count > 0 {
            let last = _detailsAnnoArray.lastObject as! DetailsAnnotation
            let pV = mapView.viewForAnnotation(_pinAnnotation) as! PinAnnotationView
            let dV = mapView.viewForAnnotation(last) as! DetailsAnnotationView
            dV.superview?.bringSubviewToFront(dV)
            pV.superview?.bringSubviewToFront(pV)
            
            let annoView = mapView.viewForAnnotation(last) as! DetailsAnnotationView
            annoView.cell .disapperItems({ () -> Void in
                mapView.removeAnnotation(last)
                self._detailsAnnoArray .removeLastObject()
                if self._detailsAnnoArray.count > 0 {
                    self._detailsAnnotation =  self._detailsAnnoArray.objectAtIndex(0) as! DetailsAnnotation
                }else{
                    self._detailsAnnotation = nil
                }
            })
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(DetailsAnnotation) {
            let anno = annotation as! DetailsAnnotation
            _detailsAnnotation = anno
            let num = anno.tag
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("DetailsAnnotationView")
            
            if annotationView == nil {
                annotationView = DetailsAnnotationView(annotation: annotation, reuseIdentifier: "DetailsAnnotationView")
            }
            let dV = annotationView as! DetailsAnnotationView
            dV.tag = num
            let vo = self.dataArray.objectAtIndex(num) as! MapItemInfoVO
            dV.setCellUI(vo)
            let selectCenter = mapView.convertCoordinate(annotation.coordinate, toPointToView: self.view)
            let center = self.view.center
            let angle = Utils.getAngleByPoint(selectCenter, center: center)
            let newCenter = CGPointMake(dV.cell.center.x - (dV.cell.bounds.size.width/2 * sin(angle)), dV.cell.center.y - (dV.cell.bounds.size.width/2 * cos(angle)))
            dV.cell.toAppearItemsViw(newCenter, angle: angle)
            dV.cell.setDetailsViewBlock({ (btn) -> Void in
                self.clickItemButton(btn as! ItemView)
            })
            return dV
        }else if (annotation.isKindOfClass(PinAnnotation)) {
            let anno = annotation as! PinAnnotation
            let num = anno.tag
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("PinAnnotationView")
            if annotationView == nil {
                annotationView = PinAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotationView")
            }
            annotationView!.tag = num
            return annotationView
            
        }
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
