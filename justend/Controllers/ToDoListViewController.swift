//
//  ToDoListViewController.swift
//  justend
//
//  Created by Yuşa Sarısoy on 29.04.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    /// This variable holds the to do list items as the type of [**Item**].
    var toDoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems() // This function provides to load the whole to do list items.
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTableView() // Sets height of the UITableView and disappears the seperators.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        beautifyNavigationController() // Sets the title as category name, set the background color of to-do items based on category color as contrast.
    }
    
    // MARK: - Helpers
    
    /// Sets height of the **UITableView** and disappears the seperators.
    private func refreshTableView() {
        tableView.rowHeight = 75 // Set the row height of the table view as 75.
        tableView.separatorStyle = .none
    }
    
    /// Sets the title as category name, set the background color of to-do items based on category color as contrast.
    private func beautifyNavigationController() {
        title = selectedCategory?.name
        if let hexColor = selectedCategory?.color {
            
            if let navigationBarColor = UIColor(hexString: hexColor) {
                navigationController?.navigationBar.backgroundColor = UIColor(hexString: hexColor)
                navigationController?.navigationBar.tintColor = ContrastColorOf(navigationBarColor, returnFlat: true)
                searchBar.barTintColor = navigationBarColor
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navigationBarColor, returnFlat: true)]
            }
        }
    }
    
    // MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Justend Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text ?? ""
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("An error occurred while saving the item: \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manipulation Methods
    
    /// This function provides to load the whole to do list items.
    private func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    /// This function provides to delete the item.
    /// - Parameter indexPath: This parameter holds the **IndexPath** value of the be deleted item.
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("An error occurred while deleting the item: \(error)")
            }
        }
    }
    
    // MARK: - UITableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = UIColor(hexString: (selectedCategory?.color)!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.backgroundColor = color
            }
            cell.accessoryType = item.done == true ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    // MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("An error occurred while updating the item: \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBar Methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
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
