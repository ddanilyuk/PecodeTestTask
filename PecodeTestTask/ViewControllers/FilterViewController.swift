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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    /// True if dropdown list for country opened
    var isCountryListOpen: Bool = false
    
    /// True if dropdown list for category opened
    var isCategoryListOpen: Bool = false
    
    var selectedRowInPickers: [Int: Int] = [ : ]
    
    var delegate: FilterViewControllerDelegate?

    var settings = Settings()
    
    
    var filterType: FilterType = .countryAndCategory
    
    var selectedSources: [Source] = []
    var selectedCountry: Country?
    var selectedCategory: Category?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSegmentControl()

        selectedCountry = settings.selectedFilter.country
        selectedCategory = settings.selectedFilter.category
        selectedSources = settings.selectedFilter.sources ?? []
        
        selectedRowInPickers[0] = Int(Country.allCases.firstIndex { $0 == selectedCountry } ?? 0)
        selectedRowInPickers[1] = Int(Category.allCases.firstIndex { $0 == selectedCategory } ?? 0)
        
        if selectedCategory == nil && selectedCountry == nil {
            segmentControl.selectedSegmentIndex = 1
            segmentControlDidChange(segmentControl)
            
            selectedCountry = .ua
            selectedCategory = .allCategories
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TextFieldAndButtonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TextFieldAndButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: DropDownPickerTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: DropDownPickerTableViewCell.identifier)
        tableView.register(UINib(nibName: SourceTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: SourceTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = UIColor.systemGroupedBackground
        tableView.backgroundColor = UIColor.systemGroupedBackground
    }
    
    @IBAction func didPressSave(_ sender: UIBarButtonItem) {
        var newFilter = Filter(category: nil, country: nil, sources: nil)

        if filterType == .source {
            if selectedSources.isEmpty {
                let alert = UIAlertController(title: nil, message: "Plese, select at least one source!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                return
            } else {
                newFilter.sources = selectedSources
            }
        } else if filterType == .countryAndCategory {
            newFilter.category = selectedCategory
            newFilter.country = selectedCountry
        }
        
        delegate?.filterParametersChanged(filter: newFilter)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentControlDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filterType = .countryAndCategory
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            tableView.reloadData()
        case 1:
            filterType = .source
            tableView.reloadData()
        default:
            break
        }
    }
    
    private func setupSegmentControl() {
        let titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.systemRed]
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentControl.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        segmentControl.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
    }
    
}


extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterType == .countryAndCategory {
            if section == 0 {
                return isCountryListOpen ? 2 : 1
            } else {
                return isCategoryListOpen ? 2 : 1
            }
        } else {
            return settings.allSources.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterType == .countryAndCategory ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if filterType == .countryAndCategory {
            return indexPath.row == 1 ? 150 : 45
        } else {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 40 : 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filterType == .countryAndCategory {
            return ["Select the country for which you want to receive news", "Select a news category"][section]
        } else {
            return "Select the information sources"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if filterType == .source {
            guard let sourceViewCell = tableView.dequeueReusableCell(withIdentifier: SourceTableViewCell.identifier, for: indexPath) as? SourceTableViewCell else { return UITableViewCell() }
            sourceViewCell.source = settings.allSources[indexPath.row]
            
            sourceViewCell.isSourceSelected = selectedSources.contains(where: { $0.id == sourceViewCell.source?.id && $0.name == sourceViewCell.source?.name })

            return sourceViewCell
        }
       
        if indexPath.row == 0 {
            guard let mainCell = tableView.dequeueReusableCell(withIdentifier: TextFieldAndButtonTableViewCell.identifier, for: indexPath) as? TextFieldAndButtonTableViewCell else {
                assertionFailure("Cell not created")
                return UITableViewCell()
            }
            var text: String?
  
            
            var placeholder = ""
            text = [selectedCountry?.getFullName(), selectedCategory?.rawValue][indexPath.section]
            placeholder = ["Country", "Category"][indexPath.section]
            
            mainCell.configureCell(text: text, placeholder: placeholder)
            mainCell.indexPath = IndexPath(row: 0, section: indexPath.section)
            mainCell.delegate = self
            mainCell.selectionStyle = .none
            mainCell.mainTextField.isEnabled = false
            
            return mainCell

        } else {
            guard let dropDownCell = tableView.dequeueReusableCell(withIdentifier: DropDownPickerTableViewCell.identifier, for: indexPath) as? DropDownPickerTableViewCell else {
                assertionFailure("Cell not created")
                return UITableViewCell()
            }
            
            dropDownCell.fatherIndexPath = IndexPath(row: 0, section: indexPath.section)

            var dataArray: [String] = []
            
            if indexPath.section == 0 {
                dataArray = Country.allCases.map({ $0.getFullName() })
            } else if indexPath.section == 1 {
                dataArray = Category.allCases.map({ $0.rawValue })
            }
         
            dropDownCell.dataArray = dataArray
            dropDownCell.delegate = self
            dropDownCell.previousSelectedIndex = selectedRowInPickers[indexPath.section] ?? 0

            dropDownCell.selectionStyle = .none
            
            return dropDownCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SourceTableViewCell else { return }
        
        if let source = cell.source {
            let isInSelectedSources = selectedSources.contains(where: { $0.id == source.id && $0.name == source.name })
            
            if isInSelectedSources {
                selectedSources.removeAll(where: { $0.id == source.id && $0.name == source.name })
            } else {
                selectedSources.append(source)
            }
            
            cell.isSourceSelected = !isInSelectedSources
            tableView.deselectRow(at: indexPath, animated: true)
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
        }
        
        // Deleting or adding dropdown cell to table view
        if switcherValue {
            tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        }
    }
}


extension FilterViewController: DropDownPickerTableViewCellDelegate {
    
    // User changed value in dropdown menu
    func userChangedDropDownCellAt(fatherIndexPath: IndexPath, text: String, inPickerRow: Int) {
        guard let cell = tableView.cellForRow(at: fatherIndexPath) as? TextFieldAndButtonTableViewCell else {
            assertionFailure("Invalid indexPath")
            return
        }
        
        selectedRowInPickers[fatherIndexPath.section] = inPickerRow
        
        if fatherIndexPath.section == 0 {
            selectedCountry = Country.allCases[inPickerRow]
        } else if fatherIndexPath.section == 1 {
            selectedCategory = Category.allCases[inPickerRow]
        }
        
        cell.configureCell(text: text, placeholder: nil)
    }
    
}
