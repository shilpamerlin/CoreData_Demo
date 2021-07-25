//
//  ViewController.swift
//  CoreData_Demo
//
//  Created by Shilpa Joy on 2021-07-24.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    // //Get a reference to Coredata persistant
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        fetchPeople()
    }
    
    @IBAction func addBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Add Person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        let submitBtn = UIAlertAction(title: "Add", style: .default) { action in
            let textField = alert.textFields?[0]
            
            //Create Person object
            let newPerson = Person(context: self.context)
            newPerson.name = textField?.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            //Save Data to Core Data
            do {
                try self.context.save()
            }
            catch {
                print("Error ocuured while saving")
            }
            self.fetchPeople()
        }
        alert.addAction(submitBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    func relatioshipDemo(){
        //create a family
        let family = Family(context: context)
        family.name = "ABC Fam"
        
        
        //create a person
        let person = Person(context: context)
        person.name = "Maggie"
        person.family = family // family property of the person to the family above -- Method 1
            
        //add person to family
        family.addToPeople(person) // family property of the person to the family above -- Method 2
      
        //save context
        try! context.save()
    }
    func fetchPeople(){
    
    //since the below function throws error, either put try! in the begining of the line or wrap inside do catch
    //fetch data from coredata and display to tableview
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
        
            //set filtering and sorting on the request
            //let pred = NSPredicate(format: "name CONTAINS 'don'")
            //request.predicate = pred
            
            //Sort
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            } catch {
            
        }
    DispatchQueue.main.async {
        self.tableView.reloadData()
        }
   }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = self.items?[indexPath.row]
        cell.textLabel?.text = person?.name
        return cell
        
    }
    
    //MARK: - trailingSwipeActions in the tableView row
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //create new swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //which person to remove
            let personToRemove = self.items?[indexPath.row]
            
            //Remove person
            self.context.delete(personToRemove!)
            
            //save data
            try! self.context.save()
            
            //Re-fetch data
            self.fetchPeople()
            
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = items?[indexPath.row]
        let alert = UIAlertController(title: "Edit Person", message: "Edit name", preferredStyle: .alert)
        alert.addTextField()
        
        let textField = alert.textFields![0]
        textField.text = person?.name
        
        let saveBtn = UIAlertAction(title: "Save", style: .default) { (action) in
            
            //Edit name property of Person object
            
            person?.name = textField.text
            
            //save data
            try! self.context.save()
            self.fetchPeople()
        }
        
        alert.addAction(saveBtn)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

