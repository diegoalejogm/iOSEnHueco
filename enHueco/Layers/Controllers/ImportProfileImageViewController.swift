//
//  ImportProfileImageViewController.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 1/1/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import RSKImageCropper
import MobileCoreServices

protocol ImportProfileImageViewControllerDelegate: class
{
    func importProfileImageViewControllerDidFinishImportingImage(controller: ImportProfileImageViewController)
    
    func importProfileImageViewControllerDidCancel(controller: ImportProfileImageViewController)
}

class ImportProfileImageViewController: UIViewController, UINavigationControllerDelegate
{
    @IBOutlet weak var importFromLocalStorageButton: UIButton!
    @IBOutlet weak var importFromFacebookButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var cancelButtonText: String?
    var hideCancelButton = false
    var translucent = false
    
    weak var delegate: ImportProfileImageViewControllerDelegate?
    
    /// Status bar style before presenting this controller
    private var originalStatusBarStyle: UIStatusBarStyle!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        originalStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        
        modalPresentationStyle = .OverCurrentContext
        
        if hideCancelButton
        {
            cancelButton.hidden = true
        }
        
        if let cancelButtonText = cancelButtonText
        {
            cancelButton.setTitle(cancelButtonText, forState: .Normal)
        }
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        
        if translucent
        {
            view.backgroundColor = UIColor.clearColor()
            view.insertSubview(effectView, atIndex: 0)
        }
        else
        {
            effectView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
            
            let backgroundImageView = UIImageView(imageNamed: "blurryBackground")
            view.insertSubview(backgroundImageView, atIndex: 0)
            backgroundImageView.autoPinEdgesToSuperviewEdges()
            backgroundImageView.addSubview(effectView)
        }
        
        effectView.autoPinEdgesToSuperviewEdges()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        importFromFacebookButton.roundCorners()
        importFromLocalStorageButton.roundCorners()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(originalStatusBarStyle, animated: animated)
    }
    
    @IBAction func importFromLocalStorageButtonPressed(sender: UIButton)
    {
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            // There is a camera on this device, so show the take photo button.
            
            alertController.addAction(UIAlertAction(title: "TakePhoto".localizedUsingGeneralFile(), style: .Default, handler: { (action) -> Void in
                
                self.imagePicker.sourceType = .Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "ChoosePhoto".localizedUsingGeneralFile(), style: .Default, handler: { (action) -> Void in
            
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel".localizedUsingGeneralFile(), style: .Cancel, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func importFromFacebookButtonPressed(sender: UIButton)
    {
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) { (result, error) -> Void in
            
            guard error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            if !result.isCancelled
            {
                //We are logged into Facebook
                
                FBSDKGraphRequest(graphPath: "me/picture", parameters: ["fields":"url", "width":"500", "redirect":"false"], HTTPMethod: "GET").startWithCompletionHandler() { (_, result, error) -> Void in
                    
                    guard let data = result["data"],
                          let imageURL = data?["url"] as? String,
                          let imageData = NSData(contentsOfURL: NSURL(string: imageURL)!),
                          let image = UIImage(data: imageData)
                        where error == nil
                    else
                    {
                        EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                        return
                    }
                    
                    let imageCropVC = RSKImageCropViewController(image: image)
                    imageCropVC.delegate = self
                    self.presentViewController(imageCropVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        delegate?.importProfileImageViewControllerDidCancel(self)
    }
}

extension ImportProfileImageViewController: UIImagePickerControllerDelegate
{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String:AnyObject]?)
    {
        let imageCropVC = RSKImageCropViewController(image: image)
        imageCropVC.delegate = self
        picker.dismissViewControllerAnimated(true) { 
            self.presentViewController(imageCropVC, animated: true, completion: nil)
        }
    }
}

extension ImportProfileImageViewController: RSKImageCropViewControllerDelegate
{
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect)
    {
        EHProgressHUD.showSpinnerInView(controller.view)
        let finalImage = RBResizeImage(croppedImage, targetSize: CGSizeMake(275, 275))
        AppUserInformationManager.sharedManager.pushProfilePicture(finalImage) { success, error in
            
            guard error == nil else
            {
                EHNotifications.tryToShowErrorNotificationInViewController(self, withPossibleTitle: error?.localizedUserSuitableDescriptionOrDefaultUnknownErrorMessage())
                return
            }
            
            controller.dismissViewControllerAnimated(true)
            {
                self.delegate?.importProfileImageViewControllerDidFinishImportingImage(self)
            }
        }
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
