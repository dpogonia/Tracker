import Foundation

final class CategoriesViewModel {
    var onCategoriesChange: (() -> Void)?

    private(set) var categories: [TrackerCategory] = [] {
        didSet { onCategoriesChange?() }
    }

    private(set) var selectedCategoryTitle: String?

    private let categoryStore: TrackerCategoryStore

    var isEmpty: Bool {
        categories.isEmpty
    }

    init(categoryStore: TrackerCategoryStore, selectedCategoryTitle: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
        reloadCategories()
    }

    func reloadCategories() {
        categories = categoryStore.fetchCategories()
    }

    func categoryTitle(at index: Int) -> String {
        categories[index].title
    }

    func isSelected(at index: Int) -> Bool {
        categories[index].title == selectedCategoryTitle
    }

    func selectCategory(at index: Int) -> String {
        let title = categories[index].title
        selectedCategoryTitle = title
        onCategoriesChange?()
        return title
    }

    func addCategory(title: String) throws {
        try categoryStore.add(title: title)
        reloadCategories()
    }
}
