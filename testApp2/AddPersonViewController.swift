//
//  AddPersonViewController.swift
//  testApp2
//
//  Created by Кирилл Иванников on 18.09.2020.
//  Copyright © 2020 Кирилл Иванников. All rights reserved.
//

import UIKit

class AddPersonViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var deleteImageBut: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var worryingLabel: UILabel!
    
    var prevVC: infoFromPopUp?
    var personID:Int!
    var personName:String = ""
    var personPhoneNum:String = ""
    var personEmail:String = ""
    var imagePath: String = "default"
    var change: Bool!
    var constraintForContentView:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        nameTextField.text = personName
        phoneNumTextField.text = personPhoneNum
        emailTextField.text = personEmail
        deleteImageBut.alpha = 0
        if imagePath != "default"{
            personImageView.image = getSavedImage(named: imagePath)
            deleteImageBut.alpha = 1
        }
        personImageView.layer.cornerRadius = personImageView.frame.size.height/2
        worryingLabel.alpha = 0
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        constraintForContentView = contentView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        NSLayoutConstraint.activate([constraintForContentView])
    }
    @IBAction func addPersonButton(_ sender: UIButton) {
        if !(nameTextField.text!.isEmpty || phoneNumTextField.text!.isEmpty) {
            if change == true {
                prevVC?.refreshData(id: personID, name: nameTextField.text!, phoneNumber: phoneNumTextField.text!, eMail: emailTextField.text!, imagePath: imagePath)
            } else {
            prevVC?.addPerson(id: personID, name: nameTextField.text!, phoneNumber: phoneNumTextField.text!, eMail: emailTextField.text!, imagePath: imagePath)
            }
        self.dismiss(animated: true)
        } else {
            worryingLabel.text = (nameTextField.text!.isEmpty == true) ? ("Input name") : ("Input phone num")
            worryingLabel.alpha = 1
        }
    }
    @IBAction func chooseImageTapGuest(_ sender: UITapGestureRecognizer) {
        let imageVC = UIImagePickerController()
        imageVC.sourceType = .photoLibrary
        imageVC.delegate = self
        imageVC.allowsEditing = true
        present(imageVC,animated: true)
    }
    @IBAction func tapToCloseKeyBoard(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        phoneNumTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func deleteImageButton(_ sender: UIButton) {
        imagePath = "default"
        personImageView.image = UIImage(systemName: "person.crop.circle")
        deleteImageBut.alpha = 0
    }
    func saveImage(image: UIImage, path: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(path+".png")!)
            print("save in \(String(describing: directory.path))")
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named+".png").path)
        }
        return nil
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if constraintForContentView.constant >= 0 {
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            UIView.animate(withDuration: 2.0, animations: { [self]() in
                constraintForContentView.constant -= keyboardSize!.height/1.8
                worryingLabel.alpha = 0
                view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.5, animations: { [self]() in
            constraintForContentView.constant = 0
            worryingLabel.alpha = 0
            view.layoutIfNeeded()
        })

    }
    
}
extension AddPersonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            personImageView.image = image
            if saveImage(image: image, path: String(personID)+"image") {
                imagePath = String(personID)+"image"
                deleteImageBut.alpha = 1
            }
        }
        picker.dismiss(animated: true, completion: nil)

    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
