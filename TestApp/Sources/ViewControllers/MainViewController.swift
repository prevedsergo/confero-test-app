//
//  MainViewController.swift
//  TestApp
//
//  Created by Sergey Kononov on 05/04/2022.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    
    private var itemsPerPage: Int {
        get {
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                return 1
            case 1:
                return 7
            case 2:
                return 20
            default:
                return 1
            }
        }
    }
    private var items: [Item] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "FDA list"
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .black
        tableView.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        reloadData()
    }
    
    // MARK: - Private
    
    @objc private func reloadData() {
        tableView.refreshControl?.beginRefreshing()
        
        NetworkManager.shared.loadTestItems(itemsPerPage: itemsPerPage) { [weak self] result in
            self?.tableView.refreshControl?.endRefreshing()
            
            switch result {
            case .failure(let error):
                NSLog("Error: %@", error.localizedDescription)
            case .success(let items):
                self?.items = items
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func itemsPerPage(_ sender: UISegmentedControl) {
        reloadData()
    }
}

// MARK: - TableView delegate and datasource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCellIdentifier", for: indexPath)
        let item = items[indexPath.row]
        
        cell.textLabel?.numberOfLines = 10
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .light)
        cell.textLabel?.text = item.text

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
