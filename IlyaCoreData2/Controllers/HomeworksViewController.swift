//
//  HomeworksViewController.swift
//  IlyaCoreData2
//
//  Created by Admin on 09.01.2020.
//  Copyright © 2020 Ilya Ilushenko. All rights reserved.
//

import UIKit

class HomeworksViewController: UIViewController {
    var lections = [Lection]()
    var selectedLection: Lection?
    var textField: UITextField?
    var items = [Homework]()
    @IBOutlet weak private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadHomework()
    }

    func loadHomework () {
        items = CoreDataManager.shared.getHomework()
        tableView.reloadData()
    }

    @IBAction private func actionAdd(_ sender: Any) {
        selectedLection = nil
        textField = nil
        loadLections()
        let alertController = UIAlertController(title: "Add new", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Task"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Lecture"
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
                let homework = Homework(context: context)
                homework.name = name
                homework.lection = self.selectedLection
                CoreDataManager.shared.saveContext()
                self.loadHomework()
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        present(alertController, animated: true) {
        }
    }

    @objc func doneAction () {
        textField?.resignFirstResponder()
    }
}

extension HomeworksViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row].name
        cell.detailTextLabel?.text = items[indexPath.row].lection?.topic
        return cell
    }
}

extension HomeworksViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lections.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lections [row].topic
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField?.text = lections [row].topic
        selectedLection = lections[row]
    }

    func loadLections () {
        lections = CoreDataManager.shared.getLections()
    }
}
