//
//  AddNewTask.swift
//  TODOApp
//
//  Created by Jakub Krawczyk on 07/08/2019.
//  Copyright © 2019 Jakub Krawczyk. All rights reserved.
//

import UIKit
import CoreData

class AddNewTask : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: Outlets and Variables
    
    @IBOutlet var todoName: UILabel!
    @IBOutlet var todoNameTextField: UITextField!
    @IBOutlet var todoDate: UILabel!
    @IBOutlet var todoDatePicker: UIDatePicker!
    @IBOutlet var todoCategory: UILabel!
    @IBOutlet var todoPicker: UIPickerView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    let categoryArray = ["Wybierz Kategorie: ","Praca", "Zakupy", "Inne" ]
    var managedContext : NSManagedObjectContext!
    var categorySelected = ""
    var taskDate = ""
    
    override func viewDidLoad() {
        
        todoPicker.delegate = self
        todoPicker.dataSource = self
        todoNameTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(String(categoryArray[row]))
        categorySelected = String(categoryArray[row])
    }
    
    
    //MARK: DatePicker
    
    @IBAction func datePickerChanged(_ sender: Any) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        
        let strDate = dateFormatter.string(from: todoDatePicker.date)
        print(strDate)
        taskDate = String(strDate)
    }
    
    //MARK: Actions
    
    @IBAction func addNewTask(_ sender: Any) {

        saveTask { (done) in
            if done {
                print("We need to return now")
                ProgressHUD.showSuccess("Zadanie dodane!")
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Try again")
            }
        }
        
    }
    
    @IBAction func cancelTask(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)

    }
    
    func saveTask(completion : (_ finished : Bool) -> ()){
        
        if todoNameTextField.text != "" {
            
            guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
            
            let todo = Todo(context: managedContext)
            
            do {
                
                todo.title = todoNameTextField.text
                todo.category = categorySelected
                todo.data = taskDate
                try managedContext.save()
                print("data saved")
                completion(true)
                
            } catch {
                
                print("failed to save data", error.localizedDescription)
                completion(false)
            }
        } else {
            
            let alert = UIAlertController(title: "Brak odpowiednich danych!", message: "Chcesz spróbować ponownie?", preferredStyle: .alert)
            
            let retryAction = UIAlertAction(title: "Spróbuj ponownie", style: .default) { (action) in
                
            }
            
            let cancelAction = UIAlertAction(title: "Anuluj", style: .default) { (action) in
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(retryAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}
