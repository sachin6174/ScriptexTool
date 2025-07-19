import SwiftUI
import Foundation

// MARK: - Base VIPER Protocols

protocol ViewProtocol: AnyObject {
    associatedtype PresenterType: PresenterProtocol
    var presenter: PresenterType? { get set }
}

protocol PresenterProtocol: AnyObject {
    associatedtype ViewType: ViewProtocol
    associatedtype InteractorType: InteractorProtocol
    associatedtype RouterType: RouterProtocol
    
    var view: ViewType? { get set }
    var interactor: InteractorType? { get set }
    var router: RouterType? { get set }
    
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
}

protocol InteractorProtocol: AnyObject {
    associatedtype PresenterType: PresenterProtocol
    var presenter: PresenterType? { get set }
}

protocol RouterProtocol: AnyObject {
    associatedtype PresenterType: PresenterProtocol
    var presenter: PresenterType? { get set }
    
    static func createModule() -> AnyView
}

protocol EntityProtocol {
    
}

// MARK: - Module Builder Protocol

protocol ModuleBuilderProtocol {
    static func build() -> AnyView
}