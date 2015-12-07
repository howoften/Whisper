import UIKit

let whistleFactory = WhistleFactory()

public func Whistle(murmur: Murmur, to: UIViewController) {
  whistleFactory.whistler(murmur, controller: to)
}

public class WhistleFactory: UIView {

  public lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .Center

    return label
    }()

  public lazy var statusBarSnapshot: UIImageView = {
    let view = UIImageView()
    return view
    }()

  public var duration: NSTimeInterval = 2
  public var viewController: UIViewController?

  // MARK: - Initializers

  public override init(frame: CGRect) {
    super.init(frame: frame)

    clipsToBounds = true
    [titleLabel, statusBarSnapshot].forEach { addSubview($0) }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func whistler(murmur: Murmur, controller: UIViewController) {
    titleLabel.text = murmur.title
    titleLabel.font = murmur.font
    titleLabel.textColor = murmur.titleColor
    backgroundColor = murmur.backgroundColor
    viewController = controller

    setupFrames()
    present()
  }

  // MARK: - Setup

  public func setupFrames() {
    let barFrame = UIApplication.sharedApplication().statusBarFrame

    titleLabel.sizeToFit()

    var yValue: CGFloat = 0
    if let navigationController = viewController?.navigationController
      where !navigationController.navigationBarHidden { yValue = -barFrame.height }

    frame = CGRect(x: 0, y: yValue, width: barFrame.width, height: barFrame.height)
    titleLabel.frame = bounds
  }

  // MARK: - Movement methods

  public func present() {
    guard let controller = viewController else { return }

    if let navigationController = controller.navigationController
      where !navigationController.navigationBarHidden {
        navigationController.navigationBar.addSubview(self)
    } else {
      controller.view.addSubview(self)
    }

    takeStatusBarSnapshot()

    let initialOrigin = frame.origin.y
    frame.origin.y = initialOrigin - 10
    alpha = 0
    UIView.animateWithDuration(0.2, animations: {
      self.frame.origin.y = initialOrigin
      self.alpha = 1
      self.statusBarSnapshot.alpha = 1
      self.statusBarSnapshot.frame.origin.y = UIApplication.sharedApplication().statusBarFrame.height
    })

    window?.windowLevel = UIWindowLevelStatusBar + 1

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.hide()
    }
  }

  public func hide() {
    window?.windowLevel = UIWindowLevelNormal
    removeFromSuperview()
  }

  // MARK: - Helper methods

  public func takeStatusBarSnapshot() {
    UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, true, 2)

    guard let controller = viewController, context = UIGraphicsGetCurrentContext() else { return }
    controller.view.layer.renderInContext(context)

    let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    statusBarSnapshot.image = snapshotImage
    statusBarSnapshot.frame = CGRect(x: 0, y: 0,
      width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
    statusBarSnapshot.alpha = 0
  }
}
