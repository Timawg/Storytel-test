import UIKit

final class SearchResultsViewController: UIViewController {
    
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
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    private func retrieveItems(initialRetrieval: Bool = false) {
        loadingIndicator.startAnimating()
        searchTask = Task(priority: .userInitiated) {
            do {
                try Task.checkCancellation()
                let items = try await viewModel.performSearch()
                var snapshot = initialRetrieval ? NSDiffableDataSourceSnapshot<Section, SearchResultCellViewModel>() : dataSource.snapshot()
                if initialRetrieval {
                    snapshot.appendSections([Section.items])
                    snapshot.appendItems(items, toSection: .items)
                } else {
                    snapshot.appendItems(items, toSection: .items)
                }
                
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
        case is URLError:
            if let error = error as? URLError, error.code == .cancelled {
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
        
        let fullyVisibleIndexPaths = tableView.indexPathsForVisibleRows?.filter { indexPath in
            let cellFrame = tableView.rectForRow(at: indexPath)
            let isCellFullyVisible = tableView.bounds.contains(cellFrame)
            return isCellFullyVisible
        }.count ?? 0
        
        let currentItemCount = dataSource.snapshot().itemIdentifiers.count
        guard let lastIndexPath = indexPaths.last?.row,
              lastIndexPath >= currentItemCount - max(fullyVisibleIndexPaths, 4) else { return
        }
        
        retrieveItems()
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        searchTask?.cancel()
    }
}
