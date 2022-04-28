//
//  ViewController.swift
//  testRxSwift
//
//  Created by yuki.osu on 2021/02/17.
//

import UIKit
import RxSwift
import RxCocoa

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<Element> {
            return catchError { _ in
                return Observable.empty()
            }
        }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
        
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var text1: UITextField!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    
    let disposeBag = DisposeBag()
    var tapGesture: UITapGestureRecognizer!

    var count1: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        let num: Observable<String> = button1.rx.tap
            .map { [weak self] _ -> Int in
                self!.count1 += 1
                return self!.count1
            }
            .flatMap { [weak self] param in
                self!.apiCall(param: param, interval: 1)
            }
            .debug()

        let num2: Observable<String> = button1.rx.tap
            .map { [weak self] _ in self!.count1 * 1000 }
            .flatMap { [weak self] param in
                self!.apiCall(param: param, interval: 2)
            }
            .debug()

        num
            .withLatestFrom(num2) { "\($0), \($1)" }
            .asDriver(onErrorDriveWith: .empty())
            .drive(label1.rx.text)
            .disposed(by: disposeBag)

//        Observable.combineLatest(
//            num,
//            num2
//        )
//        .map { "\($0), \($1)" }
//        .asDriver(onErrorDriveWith: .empty())
//        .drive(label1.rx.text)
//        .disposed(by: disposeBag)
    }

    func apiCall(param: Int, interval: Int) -> Single<String> {
        return Single.create { (observer) -> Disposable in
            DispatchQueue.init(label: "background").async {
                sleep(UInt32(interval))
                observer(.success(String(param)))
            }

            return Disposables.create()
        }
    }

}
