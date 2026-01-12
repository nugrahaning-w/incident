import UIKit

protocol ImageLoading {
    @discardableResult
    func load(url: URL, targetSize: CGSize?, completion: @escaping (UIImage?) -> Void) -> UUID
    func cancel(url: URL, token: UUID)
}