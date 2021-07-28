//
//  SavedArticleContentViewController.swift
//  NewsApp
//
//  Created by Petr Blinov on 06.07.2021.
//

import UIKit
import SafariServices
import CoreData

final class SavedArticleContentViewController: BaseViewController {
    
    // MARK: - Dependencies
    private var modelObject: MOArticle
    
    // MARK: - Init
    init(modelObject: MOArticle) {
        self.modelObject = modelObject
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Properties
    private var linkForWebView = ""
    
    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.isDirectionalLockEnabled = false;
        return scrollView
    }()
    private lazy var articleTitle: UILabel = {
        let articleTitle = UILabel()
        articleTitle.numberOfLines = 0
        articleTitle.font = UIFont.systemFont(ofSize: 33)
        articleTitle.translatesAutoresizingMaskIntoConstraints = false
        return articleTitle
    }()
    private lazy var articlePublishedAt: UILabel = {
        let articlePublishedAt = UILabel()
        articlePublishedAt.numberOfLines = 0
        articlePublishedAt.font = UIFont.systemFont(ofSize: 15)
        articlePublishedAt.translatesAutoresizingMaskIntoConstraints = false
        return articlePublishedAt
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    private lazy var articleContent: UILabel = {
        let articleDescription = UILabel()
        articleDescription.numberOfLines = 0
        articleDescription.font = UIFont.systemFont(ofSize: 18)
        articleDescription.translatesAutoresizingMaskIntoConstraints = false
        return articleDescription
    }()
    private lazy var readInSource: UILabel = {
        let readOnSource = UILabel()
        readOnSource.numberOfLines = 0
        readOnSource.font = UIFont.systemFont(ofSize: 14)
        readOnSource.translatesAutoresizingMaskIntoConstraints = false
        return readOnSource
    }()
    private lazy var sourceLinkButton: UIButton = {
        let sourceLinkButton = UIButton()
        sourceLinkButton.setTitleColor(.systemBlue, for: .normal)
        sourceLinkButton.translatesAutoresizingMaskIntoConstraints = false
        sourceLinkButton.addTarget(self, action: #selector(openWebView), for: .touchUpInside)
        return sourceLinkButton
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        view.addSubview(scrollView)
        scrollView.addSubview(articleTitle)
        scrollView.addSubview(imageView)
        scrollView.addSubview(articlePublishedAt)
        scrollView.addSubview(articleContent)
        scrollView.addSubview(readInSource)
        scrollView.addSubview(sourceLinkButton)
        setContentFromCoreData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setConstraints()
    }
    
    // MARK: - Methods
    private func setContentFromCoreData() {
        self.articleTitle.text = self.modelObject.articleTitle
        guard let imageData = self.modelObject.imageData else { return }
        self.imageView.image = UIImage(data: imageData)
        self.articlePublishedAt.text = self.modelObject.articlePublishedAt
        self.articleContent.text = self.modelObject.articleContent
        self.readInSource.text = "Read in source:"
        self.sourceLinkButton.setTitle(self.modelObject.sourceLink, for: .normal)
        guard let linkForWebView = self.modelObject.linkForWebView else { return }
        self.linkForWebView = linkForWebView
    }
    @objc func openWebView() {
        guard let sourceLink = self.modelObject.sourceLink else { return }
        guard let url = URL(string: sourceLink) else { return }
        let webViewViewController = SFSafariViewController(url: url)
        present(webViewViewController, animated: true, completion: nil)
    }
    
    // MARK: - Constraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Чтобы scrollView прокручивался только вертикально (без горизонтали) - привязываем все элементы не к scrollView, а к view. Но при этом bottomAnchor последнего элемента - к scrollView.
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            articleTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            articleTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            articleTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            articlePublishedAt.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 20),
            articlePublishedAt.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            articlePublishedAt.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            imageView.topAnchor.constraint(equalTo: articlePublishedAt.bottomAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: imageView.topAnchor,constant: 280),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            articleContent.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            articleContent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            articleContent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            readInSource.topAnchor.constraint(equalTo: articleContent.bottomAnchor, constant: 20),
            readInSource.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            readInSource.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            sourceLinkButton.topAnchor.constraint(equalTo: readInSource.bottomAnchor, constant: 2),
            sourceLinkButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -50),
            sourceLinkButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            sourceLinkButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -100)])
    }
}
