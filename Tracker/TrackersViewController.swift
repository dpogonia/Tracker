import UIKit

final class TrackersViewController: UIViewController {
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()

    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackerIDs: Set<UUID> = []
    private var searchText = ""
    private var selectedFilter: TrackerFilter = .all
    private var hasTrackersForSelectedDate = false

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        datePicker.tintColor = .ypBlue
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.searchPlaceholder
        searchController.searchBar.searchBarStyle = .minimal
        return searchController
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .ypWhiteDay
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .imageTrackerStub))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyTrackers
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackDay
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.filtersTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return button
    }()

    init(
        trackerStore: TrackerStore,
        categoryStore: TrackerCategoryStore,
        recordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        setupNavigationBar()
        setupCollectionView()
        setupStub()
        reloadFromStores()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: .open)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: .close)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .ypWhiteDay
        navigationItem.title = L10n.trackersTitle
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTrackerTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .ypBlackDay
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        collectionView.contentInset.bottom = 82
        collectionView.verticalScrollIndicatorInsets.bottom = 82
        collectionView.alwaysBounceVertical = true
    }

    private func setupStub() {
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)

        NSLayoutConstraint.activate([
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),

            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func reloadFromStores() {
        categories = categoryStore.fetchCategories()
        completedTrackers = recordStore.fetchRecords()
        reloadVisibleCategories()
    }

    private func reloadVisibleCategories() {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let selectedDay = WeekDay(rawValue: weekday)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let scheduledCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                guard let selectedDay else { return false }
                return schedule.contains(selectedDay)
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        hasTrackersForSelectedDate = !scheduledCategories.isEmpty

        let startOfCurrentDate = Calendar.current.startOfDay(for: currentDate)
        completedTrackerIDs = Set(
            completedTrackers
                .filter { Calendar.current.isDate($0.date, inSameDayAs: startOfCurrentDate) }
                .map(\.trackerId)
        )

        visibleCategories = scheduledCategories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                if !query.isEmpty && !tracker.name.lowercased().contains(query) {
                    return false
                }
                return switch selectedFilter {
                case .all, .today:
                    true
                case .completed:
                    completedTrackerIDs.contains(tracker.id)
                case .incomplete:
                    !completedTrackerIDs.contains(tracker.id)
                }
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }

        collectionView.reloadData()
        updateStubVisibility()
    }

    private func updateStubVisibility() {
        let isEmpty = visibleCategories.isEmpty
        stubImageView.isHidden = !isEmpty
        stubLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        filterButton.isHidden = !hasTrackersForSelectedDate
        let isFiltered = !searchText.isEmpty || selectedFilter == .completed || selectedFilter == .incomplete
        stubLabel.text = isFiltered
            ? L10n.nothingFound
            : L10n.emptyTrackers
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }

    private func completedDaysCount(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    private func tracker(at indexPath: IndexPath) -> Tracker {
        visibleCategories[indexPath.section].trackers[indexPath.item]
    }

    @objc
    private func addTrackerTapped() {
        AnalyticsService.shared.report(event: .click, item: .addTrack)
        let typeViewController = TrackerTypeViewController(categoryStore: categoryStore)
        typeViewController.delegate = self
        typeViewController.modalPresentationStyle = .pageSheet
        present(typeViewController, animated: true)
    }

    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadVisibleCategories()
    }

    @objc
    private func filterTapped() {
        AnalyticsService.shared.report(event: .click, item: .filter)
        let viewController = FiltersViewController(selectedFilter: selectedFilter)
        viewController.delegate = self
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }

    private func editTracker(_ tracker: Tracker) {
        AnalyticsService.shared.report(event: .click, item: .edit)
        let categoryTitle = try? trackerStore.categoryTitle(for: tracker.id)
        let viewController = NewTrackerViewController(
            isHabit: tracker.schedule != nil,
            categoryStore: categoryStore,
            tracker: tracker,
            categoryTitle: categoryTitle ?? nil
        )
        viewController.delegate = self
        viewController.modalPresentationStyle = .pageSheet
        present(viewController, animated: true)
    }

    private func confirmDeletion(of tracker: Tracker) {
        AnalyticsService.shared.report(event: .click, item: .delete)
        let alert = UIAlertController(
            title: L10n.deleteTrackerTitle,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: L10n.deleteAction,
            style: .destructive
        ) { [weak self] _ in
            try? self?.trackerStore.delete(id: tracker.id)
        })
        alert.addAction(UIAlertAction(
            title: L10n.cancelAction,
            style: .cancel
        ))
        present(alert, animated: true)
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        selectedFilter = filter
        if filter == .today {
            currentDate = Date()
            datePicker.setDate(currentDate, animated: true)
            selectedFilter = .all
        }
        reloadVisibleCategories()
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        reloadVisibleCategories()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = tracker(at: indexPath)
        cell.configure(
            with: tracker,
            completedDays: completedDaysCount(for: tracker.id),
            isCompletedToday: completedTrackerIDs.contains(tracker.id),
            isFutureDate: isFutureDate(currentDate)
        )
        cell.delegate = self
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier,
                for: indexPath
              ) as? TrackerCategoryHeader else {
            return UICollectionReusableView()
        }

        header.configure(title: visibleCategories[indexPath.section].title)
        return header
    }
}

extension TrackersViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let tracker = tracker(at: indexPath)
        return UIContextMenuConfiguration(identifier: tracker.id as NSUUID, previewProvider: nil) { [weak self] _ in
            let edit = UIAction(
                title: L10n.editAction,
                image: UIImage(systemName: "pencil")
            ) { _ in
                self?.editTracker(tracker)
            }
            let delete = UIAction(
                title: L10n.deleteAction,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.confirmDeletion(of: tracker)
            }
            return UIMenu(children: [edit, delete])
        }
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        params.cellSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard !isFutureDate(currentDate) else { return }

        let tracker = tracker(at: indexPath)
        AnalyticsService.shared.report(event: .click, item: .track)

        if completedTrackerIDs.contains(tracker.id) {
            try? recordStore.delete(trackerId: tracker.id, on: currentDate)
        } else if let trackerObject = try? trackerStore.tracker(with: tracker.id) {
            try? recordStore.add(
                TrackerRecord(trackerId: tracker.id, date: currentDate),
                tracker: trackerObject
            )
        }
    }
}

extension TrackersViewController: TrackerCreationDelegate {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        if (try? trackerStore.tracker(with: tracker.id)) != nil {
            try? trackerStore.update(tracker, categoryTitle: categoryTitle)
        } else {
            try? trackerStore.add(tracker, to: categoryTitle)
        }
    }
}

extension TrackersViewController: StoreDelegate {
    func storeDidUpdate() {
        reloadFromStores()
    }
}
