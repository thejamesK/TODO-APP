//
//  ViewController.swift
//  TODOApp
//
//  Created by Jakub Krawczyk on 05/08/2019.
//  Copyright © 2019 Jakub Krawczyk. All rights reserved.
//

import UIKit
import CoreData

    //MARK: Global Variables

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class ViewController: UIViewController {
    

    //MARK: Outlets, Variables
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var todoTableView: UITableView!
    
    var taskArray = [Todo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callDelegates()

        todoTableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customToDoCell")

        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchyData()
        todoTableView.reloadData()
        
    }
    
    //MARK: Funcions and Actions
    
    func fetchyData() {
        
        fetchData { (done) in
            if done {
                if taskArray.count > 0 {
                    todoTableView.isHidden = false
                    emptyLabel.isHidden = true
                } else {
                    todoTableView.isHidden = true
                    emptyLabel.isHidden = false
                }
            }
        }
        
    }
    
    func callDelegates() {
        
        todoTableView.delegate = self
        todoTableView.dataSource = self
        todoTableView.isHidden = true
        emptyLabel.isHidden = false
    }
    
    func configureTableView() {
        todoTableView.rowHeight = UITableView.automaticDimension
        todoTableView.estimatedRowHeight = 120.0
    }
    
    @IBAction func addTask(_ sender: Any) {
        
        performSegue(withIdentifier: "addTask", sender: self)
    }
    
}

    //MARK: Extension of ViewController for TableView

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customToDoCell", for: indexPath) as! CustomCell
        let task = taskArray[indexPath.row]
        cell.toDoCellName.text = task.title
        cell.toDoCellDate.text = task.data
        
        if taskArray[indexPath.row].category == "Praca" {
            
            cell.toDoCellImage.image = UIImage(named: "work")
            cell.toDoCellBackground.backgroundColor = .black
            cell.toDoCellName.textColor = .green
            cell.toDoCellDate.textColor = .green
            
        } else if taskArray[indexPath.row].category == "Zakupy" {
            
            cell.toDoCellImage.image = UIImage(named: "shopping")
            cell.toDoCellBackground.backgroundColor = .purple
            cell.toDoCellName.textColor = .white
            cell.toDoCellDate.textColor = .white
            
        } else {
            
            cell.toDoCellImage.image = UIImage(named: "other")
            cell.toDoCellBackground.backgroundColor = .orange
            cell.toDoCellName.textColor = .black
            cell.toDoCellDate.textColor = .black
            
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  taskArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            
            
            let alert = UIAlertController(title: "Jesteś pewien?", message: "Czy na pewno chcesz usunąć zadanie z listy?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Usuń", style: .destructive) { (action) in
                self.deleteData(indexPath: indexPath)
                self.fetchyData()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                ProgressHUD.showSuccess("Zadanie usunięte!")
            }
            
            let cancelAction = UIAlertAction(title: "Anuluj", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
}

    //MARK: Extension of ViewController for Data Functions

extension ViewController {
    
    func fetchData(completion : (_ complete : Bool) -> ()) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        
        do {
            
            taskArray = try managedContext.fetch(request) as! [Todo]
            print("data fetched")
            completion(true)
            
        } catch {
            
            print("Unable to fetch data", error.localizedDescription)
            completion(false)
            
        }
        
    }
    
    func deleteData(indexPath: IndexPath) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(taskArray[indexPath.row])
        do {
            
            try managedContext.save()
            print("data deleted")
            
        } catch {
            
            print("failed to delete data", error.localizedDescription)
            
        }

    }
    
}

