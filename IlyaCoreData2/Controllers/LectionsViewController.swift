//
//  LectionsViewController.swift
//  IlyaCoreData2
//
//  Created by Admin on 09.01.2020.
//  Copyright © 2020 Ilya Ilushenko. All rights reserved.
//

import UIKit

class LectionsViewController: UIViewController {
    var lectors = [Lector]()
    var selectedLector: Lector?
    var textField: UITextField?
    var items = [Lection]()
    @IBOutlet weak private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadLections()
    }

    func loadLections () {
        items = CoreDataManager.shared.getLections()
        tableView.reloadData()
    }

    @IBAction private func actionAdd(_ sender: Any) {
        selectedLector = nil
        textField = nil
        loadLectors()
        let alertController = UIAlertController(title: "Add new", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Select lector"
            let picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: 300))
            picker.delegate = self
            picker.dataSource = self
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.sizeToFit()
            let doneButton = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: self,
                action: #selector(self.doneAction))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolBar.setItems([spacer, doneButton], animated: false)
            textField.inputView = picker
            textField.inputAccessoryView = toolBar
            self.textField = textField
        }
        let saveAction = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let context = CoreDataManager.shared.viewContext else {
                return
            }
            let name = alertController.textFields?[0].text ?? ""
            let secondName = alertController.textFields?[1].text ?? ""
            if !name.isEmpty && !secondName.isEmpty {
                let lection = Lection(context: context)
                lection.topic = name
                lection.lector = self.selectedLector
                CoreDataManager.shared.saveContext()
                self.loadLections()
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        present(alertController, animated: true) {
        }
    }

    @objc func doneAction() {
        textField?.resignFirstResponder()
    }
}

extension LectionsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row].topic
        cell.detailTextLabel?.text = items[indexPath.row].lector?.fullName
        return cell
    }
}

extension LectionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lectors.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lectors [row].fullName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField?.text = lectors [row].fullName
        selectedLector = lectors[row]
    }

    func loadLectors () {
        lectors = CoreDataManager.shared.getLectors()
    }
}
