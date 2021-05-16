//
//  CategoryViewController.swift
//  justend
//
//  Created by Yuşa Sarısoy on 2.05.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    private let realm = try! Realm()
    
    /// This variable holds the to do list categories as the type of [**Category**].
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories() // This function provides to load the whole to do list categories.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: "FF846C")
    }
    
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Justend Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            let newCategory = Category()
            newCategory.name = textField.text ?? "New Justend Category"
            newCategory.color = UIColor.randomFlat().hexValue()
            self.saveCategory(category: newCategory) // This function provides to save a to do list category.
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data Manipulation Methods
    
    /// This function provides to save a to do list category.
    /// - Parameter category: This parameter holds the category as the **Category** type.
    private func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("An error occurred while saving the category: \(error)")
        }
        tableView.reloadData()
    }
    
    /// This function provides to load the whole to do list categories.
    private func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
        tableView.rowHeight = 75 // Set the row height of the table view as 75.
    }
    
    /// This function provides to delete the category.
    /// - Parameter indexPath: This parameter holds the **IndexPath** value of the be deleted category.
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("An error occurred while deleting the category: \(error)")
            }
        }
    }
    
    // MARK: - UITableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.backgroundColor = UIColor(hexString: category.color ?? "#fd8469")
            cell.textLabel?.text = category.name ?? "No Categories Added Yet"
            if let categoryColor = UIColor(hexString: category.color ?? "FF846C") {
                cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            }
        }
        return cell
    }
    
    // MARK: - UITableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.categoryToItems, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}
