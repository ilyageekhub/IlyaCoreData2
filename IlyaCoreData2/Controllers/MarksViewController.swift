//
//  MarksViewController.swift
//  IlyaCoreData2
//
//  Created by Admin on 09.01.2020.
//  Copyright © 2020 Ilya Ilushenko. All rights reserved.
//

import UIKit

class MarksViewController: UIViewController {
    var student: Student!
    var homeworks = [Homework]()
    var selectedHomework: Homework?
    var textField: UITextField?
    var items = [Mark]()
    @IBOutlet weak private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadMarks()
    }

    func loadMarks() {
        items = CoreDataManager.shared.getMarks(student: student)
        tableView.reloadData()
    }

    @IBAction private func actionAdd(_ sender: Any) {
        selectedHomework = nil
        textField = nil
        loadLections()
        let alertController = UIAlertController(title: "Add mark", message: "Add new", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Mark"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Clarification"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Homework"
            let picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: 300))
            picker.delegate = self
            picker.dataSource = self
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.sizeToFit()
            let doneButton = UIBarButtonItem( title: "Done", style: .done,
                                              target: self, action: #selector(self.doneAction))
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
            let clarification = alertController.textFields?[1].text ?? ""
            let secondName = alertController.textFields?[2].text ?? ""
            if !name.isEmpty && !secondName.isEmpty {
                let mark = Mark(context: context)
                mark.mark = name
                mark.clarification = clarification
                mark.student = self.student
                mark.homework = self.selectedHomework
                CoreDataManager.shared.saveContext()
                self.loadMarks()
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
        if (textField?.text ?? "").isEmpty && !homeworks.isEmpty {
            selectedHomework = homeworks.first
            textField?.text = selectedHomework?.name
        }
    }
}

extension MarksViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = items[indexPath.row].mark
        cell.detailTextLabel?.text = items[indexPath.row].clarification
        return cell
    }
}

extension MarksViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return homeworks.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return homeworks [row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField?.text = homeworks [row].name
        selectedHomework = homeworks[row]
    }

    func loadLections () {
        homeworks = CoreDataManager.shared.getHomework()
    }
}
