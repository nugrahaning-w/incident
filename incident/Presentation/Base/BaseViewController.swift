import UIKit
import RxSwift
import Onet

class BaseViewController<VM: BaseViewModel>: UIViewController {
    let viewModel: VM
    let disposeBag = DisposeBag()

    var showsLargeTitle: Bool { false }

    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        #if DEBUG
        print("[DEINIT] \(String(describing: type(of: self)))")
        #endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder() // enable shake detection
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Prevent keeping responder chain when leaving screen
        if isFirstResponder {
            resignFirstResponder()
        }
    }

    override var canBecomeFirstResponder: Bool { true }

    func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = showsLargeTitle
    }

    func setupUI() { /* override */ }

    func setupBindings() {
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self else { return }
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }

    // Shake to show Onet logs
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        Onet.showLogs()
    }
}
