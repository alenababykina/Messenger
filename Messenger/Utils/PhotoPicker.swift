//
//  PhotoPicker.swift
//  Messenger
//
//  Created by Alena on 5/15/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit

typealias PhotoPickerResultCallback = (_ image: UIImage?) -> Void


class PhotoPicker: NSObject, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate{

    private var _picker: UIImagePickerController! = UIImagePickerController()
    private var _viewController: UIViewController!
    private var _completion: PhotoPickerResultCallback?
    
    private override init() {
        super.init()
    }
    
    convenience init(with viewController: UIViewController!) {
        self.init()
        _viewController = viewController
    }
    
    func openGallery(completion: PhotoPickerResultCallback?) {
        _completion = completion
        _picker.allowsEditing = true
        _picker.delegate = self
        _picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        _viewController.present(_picker, animated: true, completion: nil)
    }
    
    func openCamera(completion: PhotoPickerResultCallback?) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            _completion = completion
            _picker.allowsEditing = true
            _picker.delegate = self
            _picker.sourceType = UIImagePickerControllerSourceType.camera
            _picker.cameraCaptureMode = .photo
            _viewController.present(_picker, animated: true, completion: nil)
        } else {
            _viewController.showErrorAlert(message: "Camera Not Found")
            completion?(nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        _completion?(chosenImage)
        _viewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        _viewController.dismiss(animated: true, completion: nil)
        _completion?(nil)
    }
}
