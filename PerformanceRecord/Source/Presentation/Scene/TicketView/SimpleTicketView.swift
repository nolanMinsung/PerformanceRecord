//
//  SimpleTicketView.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/21/25.
//

import UIKit

/// 가로 절취선이 있는 모양의 티켓 디자인(절취선 디자인을 포함하지는 않고, 윤곽만 포함함.)
final class SimpleTicketView: UIView {
    
    /// 티켓의 `cornerRadius`
    private(set) var cornerRadius: CGFloat
    
    /// 옆면에 있는 펀치홀의 반경
    private let sidePuchHoleRadius: CGFloat = 14
    private let perforatedLineTopInset: CGFloat
    
    var borderWidth: CGFloat = 0.0 {
        didSet {
            borderGradientMaskLayer.lineWidth = borderWidth
        }
    }
    
    var gradientColorHot: CGColor = UIColor.white.withAlphaComponent(0.7).cgColor {
        didSet {
            updateGradientColors()
        }
    }
    
    var gradientColorMedium: CGColor = UIColor.white.withAlphaComponent(0.3).cgColor {
        didSet {
            updateGradientColors()
        }
    }
    
    var gradientColorCold: CGColor = UIColor.white.withAlphaComponent(0.0).cgColor {
        didSet {
            updateGradientColors()
        }
    }
    
    // 마스크를 그릴 CAShapeLayer
    private let maskLayer = CAShapeLayer()
    
    private let borderGradientLayer = CAGradientLayer()
    private let borderGradientMaskLayer = CAShapeLayer()
    
    init(cornerRadius: CGFloat = 20.0, perforatedLineTopInset: CGFloat = 100) {
        self.cornerRadius = cornerRadius
        self.perforatedLineTopInset = perforatedLineTopInset
        super.init(frame: .zero)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        layer.mask = maskLayer
        
        borderGradientLayer.type = .conic
        borderGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        borderGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        updateGradientColors()
        
        // copy해서 사용하므로 fillColor를 검은색(불투명)으로 설정
        borderGradientMaskLayer.fillColor = UIColor.black.cgColor
        borderGradientMaskLayer.strokeColor = UIColor.clear.cgColor // 마스크는 색상 무관
        borderGradientMaskLayer.lineWidth = 0
        borderGradientMaskLayer.lineJoin = .round
        
        borderGradientLayer.mask = borderGradientMaskLayer
        
        self.layer.addSublayer(borderGradientLayer)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let ticketPath = createTicketPath(in: self.bounds)
        maskLayer.path = ticketPath
        borderGradientLayer.frame = self.bounds
        
        let borderPathCopy = ticketPath.copy(
            strokingWithWidth: self.borderWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 10
        )
        
        borderGradientMaskLayer.path = borderPathCopy
    }
    
    private func updateGradientColors() {
        let colorInfo: [NSNumber: CGColor] = [
            0.0: gradientColorMedium,   // 0시
            0.16: gradientColorCold,    // 2시
            0.417: gradientColorHot,    // 5시
            0.5: gradientColorMedium,   // 6시
            0.66: gradientColorCold,    // 8시
            0.917: gradientColorHot,    // 11시
            1.0: gradientColorMedium,   // 12시
        ]
        
        borderGradientLayer.locations = colorInfo
            .keys
            .sorted(by: { $0.compare($1) == .orderedAscending })
        
        borderGradientLayer.colors = colorInfo
            .keys
            .sorted(by: { $0.compare($1) == .orderedAscending })
            .map({ colorInfo[$0]! })
    }
    
    private func createTicketPath(in rect: CGRect) -> CGPath {
        let path = UIBezierPath()
        let (width, height) = (rect.width, rect.height)
        
        path.move(to: .init(x: cornerRadius, y: 0))
        path.addLine(to: .init(x: width - cornerRadius, y: 0))
        path.addArc(
            withCenter: .init(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: -0.5 * .pi,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: .init(x: width, y: height * perforatedLineTopInset - sidePuchHoleRadius))
        // 우측 펀치홀
        path.addArc(
            withCenter: .init(x: width, y: height * perforatedLineTopInset),
            radius: sidePuchHoleRadius,
            startAngle: -0.5 * .pi,
            endAngle: 0.5 * .pi,
            clockwise: false
        )
        path.addLine(to: .init(x: width, y: height - cornerRadius))
        path.addArc(
            withCenter: .init(x: width - cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: 0,
            endAngle: 0.5 * .pi,
            clockwise: true
        )
        path.addLine(to: .init(x: cornerRadius, y: height))
        path.addArc(
            withCenter: .init(x: cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: 0.5 * .pi,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: .init(x: 0, y: height * perforatedLineTopInset - sidePuchHoleRadius))
        // 좌측 펀치홀
        path.addArc(
            withCenter: .init(x: 0, y: height * perforatedLineTopInset),
            radius: sidePuchHoleRadius,
            startAngle: 0.5 * .pi,
            endAngle: -0.5 * .pi,
            clockwise: false
        )
        path.addLine(to: .init(x: 0, y: cornerRadius))
        path.addArc(
            withCenter:.init(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi,
            endAngle: -0.5 * .pi,
            clockwise: true
        )
        path.close()
        
        return path.cgPath
    }
    
}
