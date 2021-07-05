//
//  SearchViewController.swift
//  NewsApp
//
//  Created by Petr Blinov on 26.06.2021.
//

import UIKit

class SearchViewController: BaseViewController {
    
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
        // в инициализаторе устанавливаем nil чтобы для отображения результатов поиска использовалось то же вью, в котором отображается наш контент
        let searchController = UISearchController(searchResultsController: nil)
        // присваиваем self для делегата - чтобы получателем результата поиска был наш класс
        searchController.searchResultsUpdater = self
        // говорим чтобы не затемнял результаты поиска
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter a keyword to search for"
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
        view.backgroundColor = .white
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
        navigationController?.navigationBar.prefersLargeTitles = true
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


