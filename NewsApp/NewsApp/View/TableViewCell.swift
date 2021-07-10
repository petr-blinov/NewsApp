//
//  TableViewCell.swift
//  NewsApp
//
//  Created by Петр Блинов on 04.06.2021.
//

import UIKit

final class ArticleCell: UITableViewCell {
  
    static let identifier = "ArticleCell"
    
    // MARK: - UI
    lazy var articleTitleLabel: UILabel = {
        let articleTitleLabel = UILabel()
        articleTitleLabel.numberOfLines = 0
        articleTitleLabel.font = UIFont.systemFont(ofSize: 17)
        articleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return articleTitleLabel
    }()
    
  // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(articleTitleLabel)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  // MARK: -  Layout
    func setConstraints() {
        NSLayoutConstraint.activate([
            articleTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 10),
            articleTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -10),
            articleTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 20),
            articleTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20)
        ])
    }
    
  // MARK: - Configure
  
    func configure(with model: Get2ArticleDataResponse) {
        articleTitleLabel.text = model.title
    }
    func configureFromCoreData(with title: String) {
        articleTitleLabel.text = title
    }
}
