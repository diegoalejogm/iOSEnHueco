//
//  LoginViewController.swift
//  enHueco
//
//  Created by Diego Gómez on 12/6/14.
//  Copyright (c) 2014 Diego Gómez. All rights reserved.
//

import UIKit


@IBDesignable class LoginViewController : UIViewController
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var verticalSpaceToBottomConstraint: NSLayoutConstraint!
    var verticalSpaceToBottomInitialValue:CGFloat!
    
    override func viewDidLoad()
    {
        navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemDidLogin:"), name: EHSystemNotification.SystemDidLogin.rawValue, object: system)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("systemCouldNotLoginWithError:"), name: EHSystemNotification.SystemCouldNotLoginWithError.rawValue, object: system)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        verticalSpaceToBottomInitialValue = verticalSpaceToBottomConstraint.constant
        
        loginButton.clipsToBounds = true
        loginButton.layer.cornerRadius = loginButton.frame.height/2
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    @IBAction func login(sender: AnyObject)
    {
        view.endEditing(true)
        guard let username = usernameTextField.text, password = passwordTextField.text where username != "" && password != "" else
        {
            if usernameTextField.text == "" { TSMessage.showNotificationWithTitle("El login se encuentra vacío", type: TSMessageNotificationType.Warning) }
            else if passwordTextField.text == "" { TSMessage.showNotificationWithTitle("La contraseña se encuentra vacía", type: TSMessageNotificationType.Warning) }
            return
        }
            
        if usernameTextField.text == "test" && passwordTextField.text == "test"
        {
            // Test
            let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController") as! MainTabBarViewController
            navigationController!.pushViewController(mainViewController, animated: true)
            return
            /////////
        }
        
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, title: "", mode: MRProgressOverlayViewMode.Indeterminate, animated: true).setTintColor(EHIntefaceColor.mainInterfaceColor)
        
        system.login(username, password: password)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func systemDidLogin (notification: NSNotification)
    {
        NSThread.sleepForTimeInterval(0.5)
        let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarViewController") as! MainTabBarViewController
        dispatch_async(dispatch_get_main_queue())
        {
            self.presentViewController(mainViewController, animated: true, completion: nil)
            MRProgressOverlayView.dismissOverlayForView(self.view, animated:true);
        }
        

    }
    
    func systemCouldNotLoginWithError (notification: NSNotification)
    {
        //TODO: Show error
        NSThread.sleepForTimeInterval(0.5)
        dispatch_async(dispatch_get_main_queue())
        {
            TSMessage.showNotificationWithTitle("Credenciales Inválidas", type: TSMessageNotificationType.Error)
            MRProgressOverlayView.dismissOverlayForView(self.view, animated:true);
        }
    }
    
    func keyboardWillShow (notification: NSNotification)
    {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
     
        self.view.layoutIfNeeded()

        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.verticalSpaceToBottomConstraint.constant = keyboardFrame.size.height + 20
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
        })
    }
    
    func keyboardWillHide (notification: NSNotification)
    {
        self.view.layoutIfNeeded()

        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.verticalSpaceToBottomConstraint.constant = self.verticalSpaceToBottomInitialValue
            self.view.layoutIfNeeded()
            self.view.setNeedsUpdateConstraints()
            
        }, completion:{ (finished) -> Void in
            
            self.view.layoutIfNeeded()
        })
    }
}
