//
//  LectorsViewController.swift
//  IlyaCoreData2
//
//  Created by Admin on 09.01.2020.
//  Copyright © 2020 Ilya Ilushenko. All rights reserved.
//

import UIKit
import CoreData

class LectorsViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Lector> = {
        let fetchRequest: NSFetchRequest<Lector> = Lector.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.viewContext!,
            sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadLectors()
    }

    func loadLectors() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }

    @IBAction private func actionAdd(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Add lector",
            message: "Enter Name of lector",
            preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Second name"
        }
        let saveAction = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let context = CoreDataManager.shared.viewContext else {
                return
            }
            let name = alertController.textFields?[0].text ?? ""
            let secondName = alertController.textFields?[1].text ?? ""
            if !name.isEmpty && !secondName.isEmpty {
                let lector = Lector(context: context)
                lector.firstName = name
                lector.secondName = secondName
                CoreDataManager.shared.saveContext()
                self.loadLectors()
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        present(alertController, animated: true) {
        }
    }
}

extension LectorsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = fetchedResultsController.fetchedObjects else {
            return 0
        }
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let lector = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = lector.fullName
        return cell
    }
}

extension Lector {
    var fullName: String {
        return (firstName ?? "") + " " + (secondName ?? "")
    }
}

extension LectorsViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        switch type {

        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at:  [newIndexPath], with: .fade)
            }
        case .delete:
            break
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
}
