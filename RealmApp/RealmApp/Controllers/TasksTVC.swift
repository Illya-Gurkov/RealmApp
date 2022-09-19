//
//  TasksTVC.swift
//  RealmApp
//
//  Created by Illya Gurkov on 13.09.22.
//

import UIKit
import RealmSwift

class TasksTVC: UITableViewController {
    var currentTasksList: TasksList!
    
    private var notCompletedTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentTasksList.name
        
        filteringTasks()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? notCompletedTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let isFirstSection = indexPath.section == 0
        let task = isFirstSection ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Not completed tasks" : "Completed tasks"
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteTask(task)
            self.filteringTasks()
        }
        
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdateList(task)
        }
        
        let doneText = task.isComplete ? "Not done" : "Done"
        let doneContextItem = UIContextualAction(style: .destructive, title: doneText) { _, _, _ in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }
        
        editContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .green
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        
        return swipeActions
    }

    // MARK: Private

    private func filteringTasks() {
        notCompletedTasks = currentTasksList.tasks.filter("isComplete = false")
        completedTasks = currentTasksList.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
}

// MARK: - Adding And Updating List

extension TasksTVC {
    
    @objc private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdateList()
    }
    
    private func alertForAddAndUpdateList(_ taskForEditing: Task? = nil) {
        let title = "Task value"
        let message = (taskForEditing == nil) ? "Please insert new task value" : "Please edit your task"
        let doneButton = (taskForEditing == nil) ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var taskTextField: UITextField!
        var noteTextField: UITextField!

        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in

            guard let newNameTask = taskTextField.text, !newNameTask.isEmpty,
                  let newNote = noteTextField.text, !newNote.isEmpty else { return }

            if let taskForEditing = taskForEditing {
                    StorageManager.editTask(taskForEditing,
                                            newNameTask: newNameTask,
                                            newNote: newNote)
            } else {
                let task = Task()
                task.name = newNameTask
                task.note = newNote
                StorageManager.saveTask(self.currentTasksList, task: task)
            }
            self.filteringTasks()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = "New task"

            if let taskName = taskForEditing {
                taskTextField.text = taskName.name
            }
        }

        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = "Note"

            if let taskName = taskForEditing {
                noteTextField.text = taskName.note
            }
        }

        present(alert, animated: true)
    }
}
