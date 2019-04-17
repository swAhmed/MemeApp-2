//
//  ViewController.swift
//  MemeApp
//
//  Created by AHMED ALRASHEED on 15/04/2019.
//  Copyright © 2019 AHMED ALRASHEED. All rights reserved.
//
import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var bToolBar: UIToolbar!
    @IBOutlet weak var tToolBar: UIToolbar!
    @IBOutlet weak var btnCam: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var top: UITextField!
    @IBOutlet weak var bottom: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFields(textInput: top, defaultText: "TOP")
        setTextFields(textInput: bottom, defaultText: "BOTTOM")
        btnCam.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotofications()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    func showImagePicker(with source: UIImagePickerController.SourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func Cam(_ sender: Any) {
         showImagePicker(with: .camera)
    }
    
    @IBAction func toolBar(_ sender: Any) {
         showImagePicker(with: .photoLibrary)
        }
    
    func setTextFields(textInput: UITextField!, defaultText: String) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeWidth: -3.0
        ]
        textInput.text = defaultText
        textInput.defaultTextAttributes = memeTextAttributes
        textInput.delegate = self
        textInput.textAlignment = .center
    }
    
    @IBAction func share(_ sender: Any) {
        guard imageView.image != nil else {
            return
        }
       // ViewController.completionWithItemsHandler = {(activity, completed, items, error) in
        let ac = UIActivityViewController(activityItems: [generateMemedImage()],applicationActivities: nil)
          ac.completionWithItemsHandler = { _, success, _, _ in if success {
               self.save()
            }
       }
        present(ac, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        hideToolbar(true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideToolbar(false)
        return memedImage
    }
    
    func save() {
        let meme = Meme(topText: top.text!, bottomText: bottom.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }
   @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
   }
    
    
    func hideToolbar(_ hide: Bool) {
        navigationController?.navigationBar.isHidden = hide
        bToolBar.isHidden = hide
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification,object: nil)
     NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide(_:)),name: UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    func unSubscribeToKeyboardNotofications() {
NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if bottom.isFirstResponder && view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}



extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        //info[UIImagePickerController.InfoKey.editedImage] as? UIImage ??
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
}


    extension ViewController: UITextFieldDelegate {
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if top.isFirstResponder {
            bottom.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == top && textField.text == "TOP" {
            textField.text = ""
        }
        if textField == bottom && textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if top.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            top.text = "TOP"
        }
        if bottom.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            bottom.text = "BOTTOM"
        }
    }
  
    

}

    



