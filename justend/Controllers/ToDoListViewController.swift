//
//  ToDoListViewController.swift
//  justend
//
//  Created by Yuşa Sarısoy on 29.04.2021.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    /// This variable holds the to do list items as the type of [**Item**].
    var itemArray = [Item]()
    
    /// This constant holds the data file path where the to do list items save.
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems() // This function provides to load the whole to do list items.
    }
    
    // MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Justend Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            let newItem = Item()
            newItem.title = textField.text ?? "New Justend Item"
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("An error occurred while encoding the item: \(error)")
        }
        self.tableView.reloadData()
    }
    
    /// This function provides to load the whole to do list items.
    private func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("An error occurred while decoding the items: \(error)")
            }
        }
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
