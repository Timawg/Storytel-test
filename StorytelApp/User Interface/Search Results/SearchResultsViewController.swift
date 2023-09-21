import UIKit

final class SearchResultsViewController: UIViewController, UISearchBarDelegate {
    
    private enum Section {
        case items
    }
        
    private let viewModel: SearchResultsViewModel
    private var searchTask: Task<Void, Error>?
    
    private lazy var dataSource = createDataSource()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private func createDataSource() -> UITableViewDiffableDataSource<Section, SearchResultCellViewModel> {
        UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, viewModel in
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.reuseIdentifier(), for: indexPath) as? SearchResultCell
            cell?.viewModel = viewModel
            return cell
        }
    }
    
    init(_ viewModel: SearchResultsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        activateConstraints()
        retrieveItems(initialRetrieval: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.reuseIdentifier())
        tableView.dataSource = dataSource
        tableView.prefetchDataSource = self
        tableView.rowHeight = 200
        tableView.tableFooterView = loadingIndicator
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else { return }
        retrieveItems(query: searchText, initialRetrieval: true)
    }
    
    private func retrieveItems(query: String? = nil, initialRetrieval: Bool = false) {
        loadingIndicator.startAnimating()
        searchTask = Task(priority: .high) {
            do {                
                try Task.checkCancellation()
                var snapshot = initialRetrieval ? NSDiffableDataSourceSnapshot<Section, SearchResultCellViewModel>() : dataSource.snapshot()
                
                let items = try await {
                    if let query {
                       return try await viewModel.performSearch(query: query)
                    } else {
                        return try await viewModel.performSearch()
                    }
                }()
                
                if !snapshot.sectionIdentifiers.contains(.items) {
                    snapshot.appendSections([.items])
                }
                snapshot.appendItems(items, toSection: .items)
                
                    dataSource.apply(snapshot, animatingDifferences: !initialRetrieval) { [weak self] in
                        self?.loadingIndicator.stopAnimating()
                    }
                

            } catch {
                loadingIndicator.stopAnimating()
                handle(error: error)
            }
        }
    }
    
    private func handle(error: Error) {
        switch error {
        case is CancellationError:
            print(error.localizedDescription)
        case let error as URLError:
            if error.code == .cancelled {
                print(error.localizedDescription)
            } else {
                presentAlert(error: error)
            }
        default:
            presentAlert(error: error)
        }
    }

    private func presentAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchResultsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        let visibleIndexPaths = CGFloat(tableView.indexPathsForVisibleRows?.count ?? 0)

        if tableView.bounds.height / tableView.rowHeight > visibleIndexPaths {
            retrieveItems()
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        searchTask?.cancel()
    }
}
