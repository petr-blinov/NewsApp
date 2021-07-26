//
//  ViewController.swift
//  NewsApp
//
//  Created by Петр Блинов on 03.06.2021.
//

import UIKit

final class ViewController: BaseViewController {
    
// MARK: - Dependencies
    let networkService: NetworkServiceProtocol
    
// MARK: - Init
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        return tableView
    }()
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
// MARK: - Internal Properties
    private var dataSource = [Get2ArticleDataResponse]()
    
// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Устанавливаем константу с номером страницы на 1 - чтобы при загрузке приложения выдача была с первой страницы
        Constants.page = 1
        loadData()
        tabBarItem.title = "News"
        tabBarItem.image = UIImage(systemName: "globe")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Сбрасываем константу с поисковым запросом на случай если возвращаемся на страницу с новостями после того как были на странице с поиском - чтобы убрать из url запроса поисковое слово (чтобы на экране news ничего не фильтровалось)
        Constants.searchRequest = ""
    }
    
// MARK: - Methods
    private func configureUI() {
        view.backgroundColor = .systemTeal
        navigationItem.title = "News"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemTeal
        // Задаем цвет заголовку
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        // Задаем цвет кнопке возврата на этот экран
        navigationController?.navigationBar.tintColor = UIColor.white
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    @objc private func pullToRefresh(sender: UIRefreshControl) {
        Constants.page = 1
        loadData()
        sender.endRefreshing()
    }
    private func loadData() {
        isLoading = true
        self.networkService.getArticles(searchRequest: "") {
            self.processDataLoading($0) }
    }
    private func processDataLoading(_ response: GetAPIResponse) {
        DispatchQueue.main.async {
            switch response {
            case .success(let data):
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

// MARK: - TableView
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath)
        // Используем DTO - чтобы ячейка конфигурировалась на стороне. Data Transfer Object (DTO) — шаблон проектирования, используется для передачи данных между подсистемами приложения. DTO в отличие от business object или data access object не должен содержать какого-либо поведения.
        (cell as? ArticleCell)?.configure(with: dataSource[indexPath.row])
        return cell
    }
}
extension ViewController: UITableViewDelegate {
    
    // Используем willDisplay cell для того чтобы таблица загружала новый кусок данных когда мы пролистываем до последней ячейки (у нас в выдаче не больше двух страниц по 20 статей, поэтому ограничиваемся двумя страницами)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource.count - 1, !isLoading, Constants.page == 1 {
            Constants.page += 1
            isLoading = true
            networkService.getArticles(searchRequest: "") { self.processDataLoading($0) }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // не забываем диселектнуть ряд чтобы все было красиво
        tableView.deselectRow(at: indexPath,animated : true)
        isLoading = false
        let articleContentViewController = ArticleContentViewController(networkService: networkService, model: dataSource[indexPath.row])
        navigationController?.pushViewController(articleContentViewController, animated: true)
    }
}
