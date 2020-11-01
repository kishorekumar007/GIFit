//
//  Controller_Extension.swift
//  GIFfit
//
//  Created by kishore Kumar on 28/10/20.
//

import Foundation
import UIKit
extension UIViewController {
    
    /// From any where in the controller you can show alert within just one line
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    ///   - action: Custom alert action by default "Ok" will be shown
    func showAlert(title:String,message:String,
                   style:UIAlertController.Style = .alert,
                   action:[UIAlertAction] = [UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default, handler: nil)])
    {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: style)
        action.forEach({alert.addAction($0)})
        self.present(alert, animated: true, completion: nil)
    }
    
}



public extension UIPopoverArrowDirection {
    func defaultSourceRect(from view:UIView) -> CGRect? {
        switch self {
        case .down:
            return CGRect(origin: CGPoint(x: (view.frame.width/2), y: 0), size: .zero)
        case .up:
            return CGRect(origin: CGPoint(x: (view.frame.width/2), y: view.frame.height), size: .zero)
        case .left:
            return CGRect(origin: CGPoint(x: 0, y: (view.frame.height/2)), size: .zero)
        case .right:
            return CGRect(origin: CGPoint(x: view.frame.width, y: (view.frame.height/2)), size: .zero)
        default:
            return nil
        }
    }
    
    var isVerticalDirection:Bool {
        return self == .up || self == .down
    }
}

public extension UIViewController {
    @objc func openShareSheet(_ data:[Any], popFromView view:UIView, completionHandler completionBlock: ((Bool)->Void)? = nil) {
        let actionSheet = UIActivityViewController(activityItems: data, applicationActivities: nil)
        actionSheet.completionWithItemsHandler = {[weak self] (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            guard nil != self else {
                return
            }
            completionBlock?(completed)
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.prepareAsPopoverController(from: view, soruceRect: CGRect(origin: CGPoint(x: (view.frame.width/2), y: 0), size: .zero))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openShareSheet(_ data:[Any], popFromView barbutton:UIBarButtonItem, completionHandler completionBlock: ((Bool)->Void)? = nil) {
        let actionSheet = UIActivityViewController(activityItems: data, applicationActivities: nil)
        actionSheet.completionWithItemsHandler = {[weak self] (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            guard nil != self else {
                return
            }
            completionBlock?(completed)
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.prepareAsPopoverController(from: barbutton, soruceRect: nil)
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
//    @objc func showShare(sender:UIMenuItem) {}
    
    func prepareAsPopoverController(from view:UIView, soruceRect:CGRect?,
                                    preferedSize contentSize:CGSize = .zero,
                                    permittedArrowDirections directions:UIPopoverArrowDirection = .down)
    {
        self.modalPresentationStyle = .popover
        let popoverController = self.popoverPresentationController
        popoverController?.sourceView = view
        popoverController?.sourceRect = ((soruceRect == nil ? directions.defaultSourceRect(from: view) : soruceRect) ?? .zero)
        setupPopoverController(popoverController, contentSize: contentSize, permittedArrowDirections: directions)
        
    }
    private func setupPopoverController(_ popoverController:UIPopoverPresentationController?, contentSize:CGSize, permittedArrowDirections directions:UIPopoverArrowDirection) {
        
        popoverController?.permittedArrowDirections = directions
        self.preferredContentSize = contentSize
        popoverController?.canOverlapSourceViewRect = false
        popoverController?.delegate = self
        popoverController?.backgroundColor = .white
    }
    
    func prepareAsPopoverController(from barButton:UIBarButtonItem, soruceRect:CGRect?,
                                    preferedSize contentSize:CGSize = .zero,
                                    permittedArrowDirections directions:UIPopoverArrowDirection = .down )
    {
        self.modalPresentationStyle = .popover
        let popoverController = self.popoverPresentationController
        popoverController?.barButtonItem = barButton
        setupPopoverController(popoverController, contentSize: contentSize, permittedArrowDirections: directions)
        
        guard let view = barButton.value(forKey: "view") as? UIView else {
            return
        }
        popoverController?.barButtonItem = nil
        popoverController?.sourceView = view
        popoverController?.sourceRect = ((soruceRect == nil ? directions.defaultSourceRect(from: view) : soruceRect) ?? .zero)
        
        
    }
    
    //    func presentAsPageSheet() {
    //        self.modalPresentationStyle = .pageSheet
    //    }
    
    func dismissPopoverIfExist() {
        DispatchQueue.main.async {
            if self.presentedViewController?.popoverPresentationController != nil{
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

 extension UIViewController:UIPopoverPresentationControllerDelegate {
    
    open func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        //print(popoverPresentationController.arrowDirection, "willRepositionPopoverTo" )
    }
    
    open func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        //print(popoverPresentationController.arrowDirection,"prepareForPopoverPresentation")
    }
    
    open func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}

