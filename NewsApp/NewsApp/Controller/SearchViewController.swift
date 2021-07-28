//
//  SearchViewController.swift
//  NewsApp
//
//  Created by Petr Blinov on 26.06.2021.
//

import UIKit

final class SearchViewController: BaseViewController {
    
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Init
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        UISearchBar.appearance().backgroundColor = UIColor.white
        UISearchBar.appearance().tintColor  = UIColor.systemBlue
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        // добавляем в плейсхолдер обращение по имени если оно сохранено в UserDefaults. Если в UserDefaults ничего нет, то используем старнадртный текст для плейсхолдера
        var message: String = {
            var message = String()
            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                if userName != "" {
                    message = "\(userName), enter a keyword to search for"
                } else {
                    message = "Enter a keyword to search for"
                }
            }
            return message
        }()
        searchController.searchBar.placeholder = message
        return searchController
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var personalizeBarButton: UIBarButtonItem = {
        let personalizeBarButton = UIBarButtonItem(title: "Personalize", style: .plain, target: self, action: #selector(personalizeButtonPressed))
        personalizeBarButton.tintColor = .white
        // Добавляем Accessibility для UITests
        personalizeBarButton.isAccessibilityElement = true
        personalizeBarButton.accessibilityIdentifier = "Personalize"
        return personalizeBarButton
    }()
    
    // MARK: - Internal Properties
    var timer = Timer()
    private var dataSource = [Get2ArticleDataResponse]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.title = "Search"
        tabBarItem.image = UIImage(systemName: "magnifyingglass")
        navigationItem.searchController = searchController
        // Свойство, котрое позволяет отпустить строку поиска при переходе на другой экран
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        view.addSubview(tableView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureUI()
    }
    
    // MARK: - Methods
    private func configureUI() {
        navigationItem.title = "Search"
        view.backgroundColor = .systemTeal
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemTeal
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [personalizeBarButton]
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadData(searchRequest: String) {
        isLoading = true
        self.networkService.getArticles(searchRequest: searchRequest) {
            self.processDataLoading($0) }
    }
    
    private func processDataLoading(_ response: GetAPIResponse) {
        DispatchQueue.main.async {
            switch response {
            case .success(let data):
                self.dataSource = []
                self.dataSource.append(contentsOf: data.articles)
                self.tableView.reloadData()
            case .failure(let error):
                self.showErrorAlert(for: error)
            }
            self.isLoading = false
        }
    }
    
    @objc func personalizeButtonPressed() {
        showPersonalizeAlert()
    }
    
    // Алерт, в котором получаем имя пользователя и сохраняем его в UserDefaults - для дальнейшего обращения по имени в плейсхолдере в строке поиска и в алерте при добавлении статьи в Saved
    func showPersonalizeAlert() {
        let alert = UIAlertController(title: "Personalization", message: "Please enter your first name", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField!) in
            textField.placeholder = ""
        }
        let action = UIAlertAction(title: "Done", style: .default) { (action : UIAlertAction) in
            guard let enteredName = alert.textFields?.first?.text else { return }
            // Сохраняем имя пользователя в UserDefaults
            UserDefaults.standard.setValue(enteredName, forKey: "userName")
            // И добавляем обращение по имени в плейсхолдер строки поиска
            let message: String = {
                var message = String()
                if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                    if userName != "" {
                        message = "\(userName), enter a keyword to search for"
                    } else {
                        message = "Enter a keyword to search for"
                    }
                }
                return message
            }()
            self.searchController.searchBar.placeholder = message
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - Error handling
    private func showErrorAlert(for error: NetworkServiceError) {
        let alert = UIAlertController(title: "Oops, something went wrong",
                                      message: setAlertMessage(for: error),
                                      preferredStyle: .alert)
        present(alert, animated: true)
    }
    
    private func setAlertMessage(for error: NetworkServiceError) -> String {
        switch error {
        case .network:
            return "Network error, please check your network"
        case .decodable:
            return "Parsing error"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - Searching
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let enteredText = searchController.searchBar.text else { return }
        timer.invalidate()
        if enteredText != "" {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { timer in
                self.loadData(searchRequest: enteredText)
            })
        }
    }
}

// MARK: - TableView
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath)
        (cell as? ArticleCell)?.configure(with: dataSource[indexPath.row])
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // не забываем диселектнуть ряд чтобы все было красиво
        tableView.deselectRow(at: indexPath,animated : true)
        isLoading = false
        let articleContentViewController = ArticleContentViewController(networkService: networkService, model: dataSource[indexPath.row])
        navigationController?.pushViewController(articleContentViewController, animated: true)
    }
}


