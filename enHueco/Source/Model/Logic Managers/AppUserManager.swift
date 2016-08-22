//
//  AppUserInformationManager.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 2/26/16.
//  Copyright © 2016 EnHueco. All rights reserved.
//

import Foundation
import Firebase

protocol AppUserManagerDelegate: class {
    
    func appUserManagerDidReceiveAppUserInformationUpdates(manager: AppUserManager)
}

/** Handles fetching and sending of the AppUser's basic information like names, profile picture, username,
 phone number, and schedule. (Friends are not included)
*/
class AppUserManager {

    /// Delegate
    weak var delegate: AppUserManagerDelegate?

    private(set) var appUser: User?
    
    /// All references and handles for the references
    private var databaseRefsAndHandles = [(FIRDatabaseReference, FIRDatabaseHandle)]()
    
    private init?() {
        
        guard FIRAuth.auth()?.currentUser != nil else {
            assertionFailure()
            return nil
        }
        
        createFirebaseSubscriptions()
    }
    
    private func createFirebaseSubscriptions() {
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(FIRAuth.auth()!.currentUser.uid).observeEventType(.Value) { [unowned self] (snapshot) in
            
            guard let userJSON = snapshot.value as? [String : AnyObject],
                  let appUser = try? User(js: snapshot) else {
                    return
            }
            
            self.appUser = appUser
            
            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.appUserManagerDidReceiveAppUserInformationUpdates(self)
            }
        }
    }
    
    private func removeFirebaseSubscriptions() {
        
        while let (ref, handle) = databaseRefsAndHandles.popLast() {
            ref.removeObserverWithHandle(handle)
        }
    }
    
    deinit {
        removeFirebaseSubscriptions()
    }
}

extension AppUserManager {
    
    class func updateUserWith(intent: UserUpdateIntent, completionHandler: BasicCompletionHandler) {
        
        guard let appUserID = FIRAuth.auth()?.currentUser?.uid else {
            assertionFailure()
            dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.NotLoggedIn) }
            return
        }
        
        guard let updateJSON = try? intent.jsonRepresentation().foundationDictionary else {
            assertionFailure()
            dispatch_async(dispatch_get_main_queue()){ completionHandler(error: GenericError.UnknownError) }
            return
        }
        
        FIRDatabase.database().reference().child(FirebasePaths.users).child(appUserID).updateChildValues(updateJSON) { (error, reference) in
            dispatch_async(dispatch_get_main_queue()){
                completionHandler(error: error)
            }
        }
    }
    
    /*
    /// Sends a new image to the server and refreshes the pictureURL for the AppUser
    func pushProfilePicture(image: UIImage, completionHandler: BasicCompletionHandler?) {
        
        let url = NSURL(string: EHURLS.Base + EHURLS.MeImageSegment)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.setValue("attachment; filename=upload.jpg", forHTTPHeaderField: "Content-Disposition")
        
        let jpegData = NSData(data: UIImageJPEGRepresentation(image, 1)!)
        request.HTTPBody = jpegData
        
        ConnectionManager.sendAsyncDataRequest(request, successCompletionHandler: {
            (data) -> () in
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler?(success: true, error: nil)
            }
            
            }, failureCompletionHandler: {
                (error) -> () in
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(success: false, error: error)
                }
        })
    }
    
    /// Downloads the data for the pictureURL currently present in the AppUser
    func downloadProfilePictureWithCompletionHandler(completionHandler: BasicCompletionHandler?) {
        
        if let url = enHueco.appUser?.imageURL {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            
            ConnectionManager.sendAsyncDataRequest(request, successCompletionHandler: {
                (data) -> () in
                
                let path = PersistenceManager.sharedManager.documentsPath + "/profile.jpg"
                PersistenceManager.sharedManager.saveImage(data, path: path, successCompletionHandler: {
                    () -> () in
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completionHandler?(success: true, error: nil)
                    }
                })
                
            }) {
                (error) -> () in
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(success: false, error: error)
                }
            }
        }
    }*/
}