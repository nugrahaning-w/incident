import Foundation
import RxSwift
import RxRelay

class BaseViewModel {
    // Common error stream for all VMs
    let errorRelay = PublishRelay<String>()
    var errorMessage: Observable<String> { errorRelay.asObservable() }

    // Shared dispose bag
    let disposeBag = DisposeBag()

    init() {}
}