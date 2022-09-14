//
//  TasksListsTVC.swift
//  RealmApp
//
//  Created by Illya Gurkov on 13.09.22.
//

import UIKit
import RealmSwift

class TasksListsTVC: UITableViewController {
    // Results - отображает данные в реальном времени
    var tasksLists: Results<TasksList>!

    override func viewDidLoad() {
        super.viewDidLoad()
//         Clean Realm DB
//        StorageManager.deleteAll()
        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
        
       let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
       self.navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        } else {
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }
    // сортируем

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tasksList = tasksLists[indexPath.row]
        cell.textLabel?.text = tasksList.name
        cell.detailTextLabel?.text = tasksList.tasks.count.description
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = tasksLists[indexPath.row]

        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        let editeContextItem = UIContextualAction(style: .destructive, title: "Edite") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        editeContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green

        let swipeAtions = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])

        return swipeAtions
    }
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc private func addBarButtonSystemItemSelector() {
       alertForAddAndUpdatesListTasks { [weak self] in
            self?.navigationItem.title = "alertForAddAndUpdatesListTasks"
      print("ListTasks")
        }
}
    private func alertForAddAndUpdatesListTasks(_ tasksList: TasksList? = nil,
                                                complition: @escaping () -> Void)
    {
        // для редактирования 
        let title = tasksList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        let doneButtonName = tasksList == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        var alertTextField: UITextField!
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            guard let newListName = alertTextField.text, !newListName.isEmpty else {
                return
            }

            if let tasksList = tasksList {
                StorageManager.editList(tasksList, newListName: newListName, complition: complition)
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(tasksList: tasksList)
                self.tableView.reloadData()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            alertTextField = textField
            if let listName = tasksList {
                alertTextField.text = listName.name
            }
            alertTextField.placeholder = "List Name"
        }
        present(alert, animated: true)
    }
}
