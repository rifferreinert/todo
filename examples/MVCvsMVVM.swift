// This file demonstrates the differences between MVC and MVVM patterns
// in the context of SwiftUI and UIKit

import SwiftUI
import Combine

// ==========================================
// MVC EXAMPLE (Traditional UIKit approach)
// ==========================================

// In MVC, the Controller manages everything
class MVCTaskController {
    var tasks: [Task] = []
    weak var tableView: UITableView?

    func loadTasks() {
        // Fetch data from model
        tasks = TaskRepository.fetchTasks()

        // Manually update view
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    func addTask(title: String) {
        let task = Task(title: title)
        tasks.append(task)

        // Controller must know about UI implementation details
        DispatchQueue.main.async {
            self.tableView?.insertRows(
                at: [IndexPath(row: self.tasks.count - 1, section: 0)],
                with: .automatic
            )
        }
    }

    // Controller handles UI logic
    func numberOfRows() -> Int {
        return tasks.count
    }

    func taskAtIndex(_ index: Int) -> Task {
        return tasks[index]
    }
}

// ==========================================
// MVVM EXAMPLE (Modern SwiftUI approach)
// ==========================================

// In MVVM, the ViewModel focuses on presentation logic
class MVVMTaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadTasks() {
        isLoading = true

        // Fetch data from model
        tasks = TaskRepository.fetchTasks()

        // No manual UI updates needed!
        // @Published automatically notifies the view
        isLoading = false
    }

    func addTask(title: String) {
        let task = Task(title: title)
        tasks.append(task)

        // That's it! View updates automatically
        // No need to know about UI implementation
    }

    // ViewModel provides computed properties for presentation
    var taskCount: String {
        return "\(tasks.count) tasks"
    }

    var hasNoTasks: Bool {
        return tasks.isEmpty
    }
}

// ==========================================
// VIEW COMPARISON
// ==========================================

// MVC View (UIKit) - Lots of manual wiring
class MVCTaskListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var controller: MVCTaskController!

    override func viewDidLoad() {
        super.viewDidLoad()
        controller = MVCTaskController()
        controller.tableView = tableView
        controller.loadTasks()
    }

    // View must implement delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = controller.taskAtIndex(indexPath.row)
        // Manual cell configuration...
        return cell
    }
}

// MVVM View (SwiftUI) - Declarative and automatic
struct MVVMTaskListView: View {
    @StateObject private var viewModel = MVVMTaskListViewModel()

    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if viewModel.hasNoTasks {
                Text("No tasks yet")
            } else {
                List(viewModel.tasks) { task in
                    Text(task.title)
                }
            }
        }
        .onAppear {
            viewModel.loadTasks()
        }
    }
    // That's it! No manual wiring, no delegates, no manual updates
}
