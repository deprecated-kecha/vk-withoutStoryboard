//
//  NewsTableViewController.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 18.04.2022.
//

import UIKit

/// Экран с новостями.
final class NewsTableViewController: UIViewController {
    // MARK: - Private Properties
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Провайдер.
    private let provider = NewsScreenProvider()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchApi()
        tableView.register(NewsProfileTableViewCell.self, forCellReuseIdentifier: NewsProfileTableViewCell.identifier)
        tableView.register(
            NewsGroupProfileTableViewCell.self,
            forCellReuseIdentifier: NewsGroupProfileTableViewCell.identifier)
        tableView.register(NewsPhotosTableViewCell.self, forCellReuseIdentifier: NewsPhotosTableViewCell.identifier)
        tableView.register(NewsTextTableViewCell.self, forCellReuseIdentifier: NewsTextTableViewCell.identifier)
        tableView.register(NewsFooterTableViewCell.self, forCellReuseIdentifier: NewsFooterTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Setting UI Method
    /// Настройка с UI.
    private func setupUI() {
        title = "News"
        tableView.separatorStyle = .none

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])

        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }

    // MARK: - Private Methods
    /// /// Запрос новостей из api с анимацией загрузки.
    private func fetchApi() {
        loadingView.animation(.on)
        provider.fetchApiAsync {
            self.loadingView.animation(.off)
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension NewsTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        provider.data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        provider.data[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Выбор ячейки изходя из данных новости
        switch provider.data[indexPath.section][indexPath.row] {
        case .group(let group, let date):
            let cell: NewsGroupProfileTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: NewsGroupProfileTableViewCell.identifier
            ) as! NewsGroupProfileTableViewCell
            cell.configure(group, date)
            return cell
        case .profile(let profile, let date):
            let cell: NewsProfileTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: NewsProfileTableViewCell.identifier
            ) as! NewsProfileTableViewCell
            cell.configure(profile, date)
            return cell
        case .photo(let attachments):
            let cell: NewsPhotosTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: NewsPhotosTableViewCell.identifier
            ) as! NewsPhotosTableViewCell
            cell.configure(attachments)
            return cell
        case .text(let text):
            let cell: NewsTextTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: NewsTextTableViewCell.identifier
            ) as! NewsTextTableViewCell
            cell.configure(text)
            return cell
        case .likeAndView(let likes, let views, let commments):
            let cell: NewsFooterTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: NewsFooterTableViewCell.identifier
            ) as! NewsFooterTableViewCell
            cell.configure(likes, views, commments)
            return cell
        default:
            let cell: NewsTextTableViewCell = tableView.dequeueReusableCell(
                withIdentifier: NewsTextTableViewCell.identifier
            ) as! NewsTextTableViewCell
            // Приложение на данный момент не поддерживает AUDIO/VIDEO/OTHER FILES в новости.
            cell.configure("###  NOT WORK AUDIO/VIDEO/OTHER FILES ###")
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension NewsTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // Разделитель новостей
        let view = UIView()
        view.backgroundColor = .lightGray
        view.alpha = 0.5
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        1
    }
}
