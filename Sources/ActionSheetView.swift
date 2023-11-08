//
//  ActionSheetView.swift
//  CWActionSheet
//
//  Created by chenwei on 2017/8/31.
//  Copyright © 2017年 cwwise. All rights reserved.
//

import UIKit

let bottom: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
let kBottomHeight: CGFloat = bottom > 0 ? bottom - 10 : 10

/// 点击回调
public typealias ActionSheetClickedHandler = (ActionSheetView, Int) -> Void

public class ActionSheetView: UIView {
    // MARK: 属性

    /// 标题
    public var title: String?
    public var cancelButtonFont: UIFont
    public var cancelButtonBackColor: UIColor
    public var sheetMargin: CGFloat
    public var tableBackColor: UIColor
    public var cancelButtonCorner: CGFloat
    public var tableCorner: CGFloat
    public var backgroundViewAlpha: Double
    /// 取消按钮title
    public var cancelButtonTitle: String?
    
    public var backgroundViewColor: UIColor
    
    public var bigBgColor: UIColor

    /// 标题颜色 默认UIColor.black
    public var titleColor: UIColor
    /// 按钮文字颜色
    public var buttonColor: UIColor
    /// 标题字体 默认
    public var titleFont: UIFont
    /// 按钮字体
    public var buttonFont: UIFont
    /// 标题行数 默认为0，即不限制
    public var titleLinesNumber: Int
    /// 标题Insets
    public var titleEdgeInsets: UIEdgeInsets
    /// 按钮高度
    public var buttonHeight: CGFloat
    /// 动画时间
    public var animationDuration: TimeInterval
    /// 分割线颜色
    public var separatorColor: UIColor
    /// 按钮高亮颜色
    public var buttonHighlightdColor: UIColor
    /// 是否可以滚动
    public var isScrollEnabled: Bool
    /// 显示按钮数量 （不能为负数）
    public var visibleButtonCount: Float = 0
    /// destructive按钮颜色
    public var destructiveButtonColor: UIColor
    /// destructive按钮位置
    public var destructiveButtonIndex: Int?
    /// 其他按钮标题
    private var otherButtonTitles: [String] = []
    /// 点击事件回调
    public var clickedHandler: ActionSheetClickedHandler?
    /// 是否可以点击其他区域
    public var canTouchToDismiss: Bool
    /// 内容View
    private var containerView: UIView!
    /// 标题
    private var titleLabel: UILabel!
    /// 其他按钮tableView
    private var tableView: UITableView!
    /// 背景
    private var backgroundView: UIView!
    /// 分割线
    private var divisionView: UIView!
    /// 取消按钮
    private var cancelButton: UIButton!
    /// 默认配置
    private var config: ActionSheetConfig = .default
    
//    private var bottomView: UIView!
    
    private var showCellline: Bool = true
    
    private var divisionHeight: CGFloat = 5.0
    
    private var divisionColor: UIColor
    
    private var divisionMargin: CGFloat
    
    private var popviewCorner: CGFloat
    
    private var cancelButtonTitleColor: UIColor
    
    /// 当前选中的index
    public var currIndex: Int
    public var currColor: UIColor
    
    private convenience init() {
        let frame = UIScreen.main.bounds
        self.init(frame: frame)
    }
    
    override private init(frame: CGRect) {
        cancelButtonTitle = config.cancelButtonTitle
        titleColor = config.titleColor
        buttonColor = config.buttonColor
        titleFont = config.titleFont
        buttonFont = config.buttonFont
        cancelButtonFont = config.cancelButtonFont
        
        separatorColor = config.separatorColor
        destructiveButtonColor = config.destructiveButtonColor
        buttonHeight = config.buttonHeight
        animationDuration = config.animationDuration
        titleLinesNumber = config.titleLinesNumber
        titleEdgeInsets = config.titleEdgeInsets
        
        buttonHighlightdColor = config.buttonHighlightdColor
        canTouchToDismiss = config.canTouchToDismiss
        
        isScrollEnabled = config.isScrollEnabled
        
        backgroundViewColor = config.backgroundViewColor
        
        bigBgColor = config.bigBgColor

        showCellline = config.showCellline
        
        divisionHeight = config.divisionHeight
        
        divisionColor = config.divisionColor
        
        divisionMargin = config.divisionMargin

        popviewCorner = config.popviewCorner
        
        cancelButtonTitleColor = config.cancelButtonTitleColor
        
        cancelButtonBackColor = config.cancelButtonBackColor
        sheetMargin = config.sheetMargin
        tableBackColor = config.tableBackColor
        cancelButtonCorner = config.cancelButtonCorner
        tableCorner = config.tableCorner
        backgroundViewAlpha = config.backgroundViewAlpha
        
        currIndex = config.currIndex
        currColor = config.currColor

        super.init(frame: frame)
        setupUI()
        
        setCorner(CGSize(width: popviewCorner, height: popviewCorner), UIRectCorner(rawValue: UIRectCorner.topRight.rawValue | UIRectCorner.topLeft.rawValue))
    }
    
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - cancelButtonTitle: 取消按钮标题
    ///   - otherButtonTitles: 其他按钮数组
    ///   - clickedHandler: 点击事件回调
    public convenience init(title: String? = nil,
                            cancelButtonTitle: String? = nil,
                            otherButtonTitles: [String] = [],
                            clickedHandler: ActionSheetClickedHandler? = nil)
    {
        self.init()
        self.title = title
        self.otherButtonTitles = otherButtonTitles
        self.cancelButtonTitle = cancelButtonTitle
        self.clickedHandler = clickedHandler
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = bigBgColor
        backgroundView.alpha = 0
        addSubview(backgroundView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewClicked))
        backgroundView.addGestureRecognizer(tapGesture)
        
        containerView = UIView()
        containerView.backgroundColor = backgroundViewColor
        addSubview(containerView)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        containerView.addSubview(titleLabel)

        //
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.backgroundColor = tableBackColor
        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: "ActionSheetCell")
        containerView.addSubview(tableView)
        
        // 分割线
        divisionView = UIView()
        divisionView.backgroundColor = divisionColor
        containerView.addSubview(divisionView)
        
        // 取消按钮
        cancelButton = UIButton(type: .custom)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        cancelButton.titleLabel?.font = cancelButtonFont
        cancelButton.setTitleColor(cancelButtonTitleColor, for: .normal)
        cancelButton.backgroundColor = cancelButtonBackColor
        containerView.addSubview(cancelButton)
    }
    
    public func setCorner(_ cornerRadii: CGSize, _ roundingCorners: UIRectCorner) {
        let fieldPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadii)
        let fieldLayer = CAShapeLayer()
        fieldLayer.frame = bounds
        fieldLayer.path = fieldPath.cgPath
        containerView.layer.mask = fieldLayer
    }
    
    /// 计算
    func setupSubViews() {
        if isScrollEnabled == true {
            assert(visibleButtonCount > 0, "visibleButtonCount 不能小于0")
        }
        
        titleLabel.font = titleFont
        titleLabel.textColor = titleColor
        titleLabel.numberOfLines = titleLinesNumber
        titleLabel.text = title
        
        tableView.rowHeight = buttonHeight
    
        let contentWidth = frame.width - sheetMargin * 2
 
        var titleEdgeInsetsBottom = titleEdgeInsets.bottom
        if title != nil {
            let titleWidth = contentWidth - titleEdgeInsets.left - titleEdgeInsets.right
            let size = CGSize(width: titleWidth,
                              height: CGFloat.greatestFiniteMagnitude)
            var titleSize = titleLabel.sizeThatFits(size)
            titleSize = CGSize(width: titleWidth, height: ceil(titleSize.height)+1)
            
            titleLabel.frame = CGRect(x: titleEdgeInsets.left, y: titleEdgeInsets.top,
                                      width: titleSize.width, height: titleSize.height)
        } else {
            titleLabel.frame = CGRect.zero
            titleEdgeInsetsBottom = 0
        }
        
        // layout tableView
        var tableViewHeight: CGFloat
        if isScrollEnabled && visibleButtonCount != 0 {
            tableViewHeight = ceil(CGFloat(visibleButtonCount) * buttonHeight)
        } else {
            tableViewHeight = CGFloat(otherButtonTitles.count) * buttonHeight
        }
        
//        tableView.isScrollEnabled = isScrollEnabled
//        tableView.frame = CGRect(x: 0, y: titleLabel.frame.maxY+titleEdgeInsetsBottom,
//                                 width: contentWidth, height: tableViewHeight)
        tableView.isScrollEnabled = tableViewHeight > (UIScreen.main.bounds.height - 196)
        tableView.frame = CGRect(x: 0, y: titleLabel.frame.maxY+titleEdgeInsetsBottom,
                                 width: contentWidth, height: min(tableViewHeight, UIScreen.main.bounds.height - 196))
        tableView.layer.cornerRadius = tableCorner
        tableView.layer.masksToBounds = true
        
        let divisionViewHeight: CGFloat = (cancelButtonTitle != nil) ? divisionHeight : 0.0

        divisionView.frame = CGRect(x: divisionMargin, y: tableView.frame.maxY,
                                    width: contentWidth - 2 * divisionMargin, height: divisionViewHeight)
        
        cancelButton.titleLabel?.font = buttonFont
        cancelButton.setTitleColor(cancelButtonTitleColor, for: .normal)
        cancelButton.setBackgroundImage(UIImage(color: UIColor.clear), for: .normal)
        cancelButton.setBackgroundImage(UIImage(color: buttonHighlightdColor), for: .highlighted)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.layer.cornerRadius = cancelButtonCorner
        cancelButton.layer.masksToBounds = true
        
        if cancelButtonTitle != nil {
            cancelButton.frame = CGRect(x: 0, y: divisionView.frame.maxY,
                                        width: contentWidth, height: buttonHeight)
        } else {
            cancelButton.frame = CGRect(x: 0, y: divisionView.frame.maxY,
                                        width: contentWidth, height: 0)
        }
        
        // 添加背景
        containerView.frame = CGRect(x: sheetMargin, y: frame.height - cancelButton.frame.maxY - kBottomHeight,
                                     width: UIScreen.main.bounds.width - sheetMargin * 2, height: cancelButton.frame.maxY+kBottomHeight)
    }
    
    /// 添加按钮
    ///
    /// - Parameters:
    ///   - buttonTitles: 标题数组
    public func append(buttonTitles: [String]) {
        otherButtonTitles.append(contentsOf: buttonTitles)
        tableView.reloadData()
        setupSubViews()
    }
    
    /// 在指定位置插入按钮
    ///
    /// - Parameters:
    ///   - buttonTitles: 标题数组
    ///   - index: 位置
    public func insert(buttonTitles: [String], at index: Int) {
        otherButtonTitles.insert(contentsOf: buttonTitles, at: index)
        tableView.reloadData()
        setupSubViews()
    }
    
    @objc func backgroundViewClicked() {
        cancelButtonClicked()
    }
    
    /// 适配keyWindow
    var ltKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }.map { $0 as? UIWindowScene }.compactMap { $0 }.first?.windows.filter { $0.isKeyWindow }.first
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    /// 显示ActionSheetView
    public func show() {
        guard let keyWindow = ltKeyWindow else { return }
        keyWindow.addSubview(self)
        
        setupSubViews()
        containerView.frame = containerView.frame.offsetBy(dx: 0, dy: containerView.frame.height)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let self = self else { return }
            let frame = self.containerView.frame
            self.containerView.frame = frame.offsetBy(dx: 0, dy: -frame.height)
            self.backgroundView.alpha = self.backgroundViewAlpha
            
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.backgroundView.isUserInteractionEnabled = self.canTouchToDismiss
        })
    }
    
    /// 隐藏ActionSheetView
    public func dismiss() {
        cancelButtonClicked()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ActionSheetView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherButtonTitles.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return buttonHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionSheetCell", for: indexPath) as! ActionSheetCell
        cell.titleLabel.font = buttonFont
        cell.lineLayer.backgroundColor = separatorColor.cgColor
        cell.titleLabel.text = otherButtonTitles[indexPath.row]
        cell.backgroundColor = .clear
        cell.lineLayer.isHidden = !showCellline
        if indexPath.row == currIndex {
            cell.titleLabel.textColor = currColor
        } else if indexPath.row == destructiveButtonIndex {
            cell.titleLabel.textColor = destructiveButtonColor
        } else {
            cell.titleLabel.textColor = buttonColor
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        clickedHandler?(self, indexPath.row+1)
        hideWithButtonIndex(indexPath.row+1)
    }
}

extension ActionSheetView {
    @objc func cancelButtonClicked() {
        clickedHandler?(self, 0)
        hideWithButtonIndex(0)
    }
    
    func hideWithButtonIndex(_ index: Int) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let self = self else { return }
            let frame = self.containerView.frame
            self.containerView.frame = frame.offsetBy(dx: 0, dy: frame.height)
            self.backgroundView.alpha = self.backgroundViewAlpha
            
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
        })
    }
}

extension UIColor {
    convenience init(hex6: UInt32, alpha: Float = 1) {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
        let blue = CGFloat((hex6 & 0x0000FF) >> 0) / divisor
        self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 10, height: 10)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        self.init(cgImage: (UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
    }
}
