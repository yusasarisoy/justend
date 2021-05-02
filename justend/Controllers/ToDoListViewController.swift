//
//  ToDoListViewController.swift
//  justend
//
//  Created by Yuşa Sarısoy on 29.04.2021.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    /// This variable holds the to do list items as the type of [**Item**].
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet {
            loadItems() // This function provides to load the whole to do list items.
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Justend Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            let newItem = Item(context: self.context)
            newItem.title = textField.text ?? "New Justend Item"
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems() // This function provides to save a to do list item.
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manipulation Methods
    
    /// This function provides to save a to do list item.
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("An error occurred while saving the item: \(error)")
        }
        tableView.reloadData()
    }
    
    /// This function provides to load the whole to do list items.
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryName = selectedCategory?.name ?? "Items"
        navigationItem.title = categoryName
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("An error occurred while getting the items: \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.toDoItemCellIdentifier, for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done == true ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems() // This function provides to save a to do list item.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBar Methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text ?? "")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
