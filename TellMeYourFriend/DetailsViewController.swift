//
//  DetailsViewController.swift
//  TellMeYourFriend
//
//  Created by Özgün Can Beydili on 11.07.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var rateField: UITextField!
    @IBOutlet weak var jobField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedName = ""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedName != ""{
            saveB.isHidden = true
            if let uuidString = selectedId?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0{
                        for result in results as! [NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String{
                                nameField.text = name
                            }
                            if let job = result.value(forKey: "job") as? String{
                                jobField.text = job
                            }
                            if let age = result.value(forKey: "age") as? Int{
                                ageField.text = String(age)
                            }
                            if let rate = result.value(forKey: "rate") as? Double{
                                rateField.text = String(rate)
                            }
                            if let imageData = result.value(forKey: "image") as? Data{
                                imageView.image = UIImage(data: imageData)
                            }
                        }
                    }
                }catch{
                    print("Error!")
                }
                
            }
        } else{
            saveB.isHidden = false
            saveB.isEnabled = false
            nameField.text = ""
            jobField.text = ""
            ageField.text = ""
            rateField.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        saveB.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let friend = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context)
        
        friend.setValue(nameField.text!, forKey: "name")
        friend.setValue(jobField.text!, forKey: "job")
        if let age = Int(ageField.text!){
            friend.setValue(age, forKey: "age")
        }
        if let rate = Double(rateField.text!){
            friend.setValue(rate, forKey: "rate")
        }
        friend.setValue(UUID(), forKey: "id")
        friend.setValue(imageView.image!.jpegData(compressionQuality: 0.5), forKey: "image")
        
        do{
            try context.save()
            print("Saved!")
        }catch{
            print("Error!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "back"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
