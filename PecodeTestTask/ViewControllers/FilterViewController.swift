//
//  FilterViewController.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit


protocol FilterViewControllerDelegate {
    func filterParametersChanged(filter: Filter)
}


class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var isCountryListOpen: Bool = false
    
    var isCategoryListOpen: Bool = false
    
    var isSourceListOpen: Bool = false
    
//    var countrySelected: Country = .ua
    
//    var categorySelected: Category = .allCategories

    let headersOfSections: [Int: String] = [
        0: "Select the country for which you want to receive news",
        1: "Select a news category",
        2: "Select the information source \nCan`t mix with category and country"
    ]
    
    let placeholdersOfSections: [Int: String] = [
        0: "Country",
        1: "Category",
        2: "Source",
    ]
    
    var selectedRowInPickers: [Int: Int] = [ :
//        0 : 2,
//        1 : 3
    ]
    
    var delegate: FilterViewControllerDelegate?

    var settings = Settings()
    
    var filter = Filter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        filter = settings.selectedFilter
        
        selectedRowInPickers[0] = Int(Country.allCases.firstIndex { $0 == filter.country } ?? 0)
        selectedRowInPickers[1] = Int(Category.allCases.firstIndex { $0 == filter.category } ?? 0)
//        selectedRowInPickers[2] = Int(Category.allCases.firstIndex { $0 == filter.category } ?? 0)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TextFieldAndButtonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TextFieldAndButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: DropDownPickerTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: DropDownPickerTableViewCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = UIColor.systemGroupedBackground
        tableView.backgroundColor = UIColor.systemGroupedBackground
    }
    
    @IBAction func didPressSave(_ sender: UIBarButtonItem) {
        
//        filter.category = categorySelected
//        filter.country = countrySelected
        
        delegate?.filterParametersChanged(filter: filter)
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isCountryListOpen ? 2 : 1
        } else if section == 1 {
            return isCategoryListOpen ? 2 : 1
        } else if section == 2 {
            return isSourceListOpen ? 2 : 1
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 150 : 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 40 : 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headersOfSections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row == 0 {
            guard let newLessonCell = tableView.dequeueReusableCell(withIdentifier: TextFieldAndButtonTableViewCell.identifier, for: indexPath) as? TextFieldAndButtonTableViewCell else {
                assertionFailure("Cell not created")
                return UITableViewCell()
            }
            var text: String?
            if indexPath.section == 0 {
                text = filter.country?.getFullName()
            } else if indexPath.section == 1 {
                text = filter.category?.rawValue
            }
            
            newLessonCell.configureCell(text: text, placeholder: placeholdersOfSections[indexPath.section])

            newLessonCell.indexPath = IndexPath(row: 0, section: indexPath.section)
            newLessonCell.delegate = self
            newLessonCell.selectionStyle = .none
            newLessonCell.mainTextField.isEnabled = false
            
            return newLessonCell

        } else {
            guard let cellWithOnePicker = tableView.dequeueReusableCell(withIdentifier: DropDownPickerTableViewCell.identifier, for: indexPath) as? DropDownPickerTableViewCell else {
                assertionFailure("Cell not created")
                return UITableViewCell()
            }
            cellWithOnePicker.fatherIndexPath = IndexPath(row: 0, section: indexPath.section)
            
            //
            var dataArray: [String] = []
            if indexPath.section == 0 {
                dataArray = Country.allCases.map({ $0.getFullName() })
            } else if indexPath.section == 1 {
                dataArray = Category.allCases.map({ $0.rawValue })
            } else if indexPath.section == 2 {
                dataArray = ["BBC", "Ria", "Google"]
            }            
            cellWithOnePicker.dataArray = dataArray
            cellWithOnePicker.delegate = self
            cellWithOnePicker.previousSelectedIndex = selectedRowInPickers[indexPath.section] ?? 0
            cellWithOnePicker.selectionStyle = .none
            
            return cellWithOnePicker
        }
        
    }
    
    
}


extension FilterViewController: TextFieldAndButtonTableViewCellDelegate {
    
    func userDidPressShowDetails(at indexPath: IndexPath) {
        var switcherValue = false
        
        if indexPath.section == 0 {
            isCountryListOpen.toggle()
            switcherValue = isCountryListOpen
        } else if indexPath.section == 1 {
            isCategoryListOpen.toggle()
            switcherValue = isCategoryListOpen
        } else if indexPath.section == 2 {
            isSourceListOpen.toggle()
            switcherValue = isSourceListOpen
        } else {
            return
        }
        
        if switcherValue {
            tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        }
    }
    
    func userChangeTextInTextField(at indexPath: IndexPath, text: String) {
        print("")
    }
    
    
}

extension FilterViewController: DropDownPickerTableViewCellDelegate {
    func userChangedDropDownCellAt(fatherIndexPath: IndexPath, text: String, inPickerRow: Int) {
        guard let cell = tableView.cellForRow(at: fatherIndexPath) as? TextFieldAndButtonTableViewCell else {
            assertionFailure("Invalid indexPath")
            return
        }
        userChangeTextInTextField(at: fatherIndexPath, text: text)
        selectedRowInPickers[fatherIndexPath.section] = inPickerRow
        
        
        if fatherIndexPath.section == 0 {
            filter.country = Country.allCases[inPickerRow]
        } else if fatherIndexPath.section == 1 {
            filter.category = Category.allCases[inPickerRow]
        } else {
            print("Source selected")
//            filter.source =
        }
        
        cell.configureCell(text: text, placeholder: nil)
    }
}
