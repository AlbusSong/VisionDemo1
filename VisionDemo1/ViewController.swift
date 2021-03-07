//
//  ViewController.swift
//  VisionDemo1
//
//  Created by Albus on 3/7/21.
//

import UIKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import MapboxVision 
import MapboxVisionAR
import MapboxVisionSafety


class ViewController: UIViewController {
    
    private var videoSource: CameraVideoSource!
    
    private var visionManager: VisionManager!
    
    private var visionARManager: VisionARManager!
    private var visionSafetyManager: VisionSafetyManager!
    
    private let visionViewController = VisionPresentationViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        videoSource = CameraVideoSource()
        
        // create VisionManager with video source
        visionManager = VisionManager.create(videoSource: videoSource)
        
        visionManager.delegate = self
        
        // create VisionARManager to use AR features
        visionARManager = VisionARManager.create(visionManager: visionManager)
        // set up the `VisionARManagerDelegate`
        visionARManager.delegate = self
        
        // create VisionSafetyManager to use Safety features
        visionSafetyManager = VisionSafetyManager.create(visionManager: visionManager)
        // set up the `VisionSafetyManagerDelegate`
        visionSafetyManager.delegate = self
        
        // configure view to display sample buffers from video source
        visionViewController.set(visionManager: visionManager)
        addChild(visionViewController)
        view.addSubview(visionViewController.view)
        visionViewController.didMove(toParent: self)

        let origin = CLLocationCoordinate2D()
        let destination = CLLocationCoordinate2D()
        let routeOptions = NavigationRouteOptions(coordinates: [origin, destination], profileIdentifier: .automobile)
        
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }
                self?.visionARManager.set(route: (route as! MapboxVisionAR.Route))
                // Pass the generated route to the the NavigationViewController
//                let viewController = NavigationViewController(for: route, routeIndex: 0, routeOptions: routeOptions)
//                viewController.modalPresentationStyle = .fullScreen
//                strongSelf.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // start delivering events
        videoSource.start()
        visionManager.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // stop delivering events
        videoSource.stop()
        visionManager.stop()
    }
    
    deinit {
        // AR and Safety managers should be destroyed before the Vision manager
        visionARManager.destroy()
        visionSafetyManager.destroy()
        
        // finally destroy the instance of `VisionManager`
        visionManager.destroy()
    }
}

extension ViewController: VisionManagerDelegate {
// implement required methods of the delegate
}

extension ViewController: VisionARManagerDelegate {
// implement required methods of the delegate
}

extension ViewController: VisionSafetyManagerDelegate {
// implement required methods of the delegate
}

