//
//  TicketView.swift
//  PerformanceRecord
//
//  Created by 김민성 on 10/20/25.
//

import UIKit

/// 이미지 뷰의 내용을 티켓 모양으로 마스킹하는 커스텀 UIImageView
final class TicketView: UIView {

    // MARK: - Configuration Properties
    
    /// 코너의 오목하게 들어간 부분의 radius
    private(set) var cornerRadius: CGFloat
    /// 뾰족한 부분을 부드럽게 깎는 정도
    private var miniCornerRadius: CGFloat = 2.0
    
    // 위, 아래 각 변의 펀치홀 수
    private(set) var punchHoleCount: Int
    
    var borderWidth: CGFloat {
        get { return _borderWidth / 2 }
        set { _borderWidth = newValue * 2 }
    }
    
    private var _borderWidth: CGFloat = 0.0 {
        didSet {
            borderGradientMaskLayer.lineWidth = _borderWidth
        }
    }
    
    
    var gradientColorHot: CGColor = UIColor.white.withAlphaComponent(0.5).cgColor {
        didSet {
            updateGradientColors()
        }
    }
    
    var gradientColorMedium: CGColor = UIColor.white.withAlphaComponent(0.2).cgColor {
        didSet {
            updateGradientColors()
        }
    }
    
    var gradientColorCold: CGColor = UIColor.white.withAlphaComponent(0.0).cgColor {
        didSet {
            updateGradientColors()
        }
    }
    
    // MARK: - Layers
    
    private let maskLayer = CAShapeLayer()
    private let borderGradientLayer = CAGradientLayer()
    private let borderGradientMaskLayer = CAShapeLayer()
    
    init(cornerRadius: CGFloat = 20.0, punchHoleCount: Int = 9) {
        self.cornerRadius = cornerRadius
        self.punchHoleCount = punchHoleCount
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
            strokingWithWidth: self._borderWidth,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 10
        )
        
        borderGradientMaskLayer.path = borderPathCopy
    }
    
    private func updateGradientColors() {
        let colorInfo: [NSNumber: CGColor] = [
            0.0: gradientColorMedium,    // 0시
            0.16: gradientColorCold,     // 2시
            0.417: gradientColorHot,     // 5시
            0.5: gradientColorMedium,    // 6시
            0.66: gradientColorCold,     // 8시
            0.917: gradientColorHot,     // 11시
            1.0: gradientColorMedium,    // 12시
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
        
        let punchHoleDiameter = (width - 2 * cornerRadius) / CGFloat((punchHoleCount * 2 + 1))
        let sidePadding = punchHoleDiameter
        let punchHoleRadius = punchHoleDiameter / 2
        
        let punchHoleTangentAngleBig = acos(miniCornerRadius/(punchHoleRadius + miniCornerRadius))
        let punchHoleTangentAngleSmall = asin(miniCornerRadius/(punchHoleRadius + miniCornerRadius))
        /// 펀치홀의 뾰족한 부분을 다듬기 위한 arc를 그릴 때, arc의 중심이 되는 부분이 뾰족한 부분으로부터 이동한 거리 (수식으로부터 계산된 값. 직관적으로 이해 안 될 수 있음.)
        let sideDiffByPunchHoleRadius: CGFloat = ((miniCornerRadius / tan(punchHoleTangentAngleSmall)) - punchHoleRadius)
        
        let cornerTangentAngleBig = acos(miniCornerRadius/(cornerRadius + miniCornerRadius))
        let cornerTangentAngleSmall = asin(miniCornerRadius/(cornerRadius + miniCornerRadius))
        /// 코너 부분의 뾰족한 부분을 다듬기 위한 arc를 그릴 때, arc의 중심이 되는 부분이 뾰족한 부분으로부터 이동한 거리 (수식으로부터 계산된 값. 직관적으로 이해 안 될 수 있음.)
        let sideDiffByCornerRadius: CGFloat = ((miniCornerRadius / tan(cornerTangentAngleSmall)) - cornerRadius)
        
        // --- 상단 그리기 ---
        // 좌상단 (오목한) 코너 다음 지점에서 시작
        path.move(to: CGPoint(x: cornerRadius + sideDiffByCornerRadius, y: 0))
        
        var currentX = cornerRadius + sidePadding
        path.addLine(to: CGPoint(x: currentX - sideDiffByPunchHoleRadius, y: 0))
        
        // 상단 펀칭 그리기
        for _ in 0..<punchHoleCount {
            // 상단 펀칭 직전 뾰족한 부분 깎기
            path.addArc(
                withCenter: .init(x: currentX - sideDiffByPunchHoleRadius, y: miniCornerRadius),
                radius: miniCornerRadius,
                startAngle: -0.5 * .pi,
                endAngle: -punchHoleTangentAngleSmall,
                clockwise: true
            )
            
            path.addArc(
                withCenter: CGPoint(x: currentX + punchHoleRadius, y: 0),
                radius: punchHoleRadius,
                startAngle: .pi - punchHoleTangentAngleSmall,
                endAngle: punchHoleTangentAngleSmall,
                clockwise: false
            )
            
            // currentX를 반원의 끝 지점으로 이동
            currentX += (punchHoleRadius * 2)
            
            // 상단 펀칭 직후 뾰족한 부분 깎기
            path.addArc(
                withCenter: .init(x: currentX + sideDiffByPunchHoleRadius, y: miniCornerRadius),
                radius: miniCornerRadius,
                startAngle: -0.5 * .pi - punchHoleTangentAngleBig,
                endAngle: -0.5 * .pi,
                clockwise: true
            )
            
            currentX += sidePadding
            path.addLine(to: CGPoint(x: currentX, y: 0))
        }
        
        // 우상단 코너 시작 지점까지 라인 추가
        path.addLine(to: CGPoint(x: width - cornerRadius - sideDiffByCornerRadius, y: 0))
        
        // --- 우상단 코너 ---
        
        // 우상단 코너 직전 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: width - cornerRadius - sideDiffByCornerRadius, y: miniCornerRadius),
            radius: miniCornerRadius,
            startAngle: -0.5 * .pi,
            endAngle: -cornerTangentAngleSmall,
            clockwise: true
        )
        
        // 우상단 오목한 코너 그리기
        path.addArc(
            withCenter: CGPoint(x: width, y: 0),
            radius: cornerRadius,
            startAngle: .pi - cornerTangentAngleSmall,
            endAngle: 0.5 * .pi + cornerTangentAngleSmall,
            clockwise: false
        )
        
        // 우상단 코너 직후 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: width - miniCornerRadius, y: cornerRadius + sideDiffByCornerRadius),
            radius: miniCornerRadius,
            startAngle: -0.5 * .pi + cornerTangentAngleSmall,
            endAngle: -cornerTangentAngleSmall,
            clockwise: true
        )

        // --- 우측면 ---
        // 우측 수직선
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius - sideDiffByCornerRadius))
        
        // --- 우하단 코너 ---
        
        // 우하단 코너 직전 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: width - miniCornerRadius, y: height - cornerRadius - sideDiffByCornerRadius),
            radius: miniCornerRadius,
            startAngle: 0,
            endAngle: cornerTangentAngleBig,
            clockwise: true
        )

        // 우하단 오목한 코너
        path.addArc(
            withCenter: CGPoint(x: width , y: height),
            radius: cornerRadius,
            startAngle: -0.5 * .pi - cornerTangentAngleSmall,
            endAngle: .pi + cornerTangentAngleSmall,
            clockwise: false
        )
        
        // 우하단 코너 직후 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: width - cornerRadius - sideDiffByCornerRadius, y: height - miniCornerRadius),
            radius: miniCornerRadius,
            startAngle: cornerTangentAngleSmall,
            endAngle: 0.5 * .pi,
            clockwise: true
        )
        
        // 하단 펀칭
        currentX = width - cornerRadius - sidePadding
        path.addLine(to: CGPoint(x: currentX + sideDiffByPunchHoleRadius, y: height))
        
        for _ in 0..<punchHoleCount {
            // 하단 펀칭 직전 뾰족한 부분 깎기
            path.addArc(
                withCenter: .init(x: currentX + sideDiffByPunchHoleRadius, y: height - miniCornerRadius),
                radius: miniCornerRadius,
                startAngle: 0.5 * .pi,
                endAngle: 0.5 * .pi + cornerTangentAngleBig,
                clockwise: true
            )
            
            path.addArc(
                withCenter: CGPoint(x: currentX - punchHoleRadius, y: height),
                radius: punchHoleRadius,
                startAngle: -punchHoleTangentAngleSmall,
                endAngle: .pi + punchHoleTangentAngleSmall,
                clockwise: false
            )
            // currentX를 반원의 끝 지점으로 이동
            currentX -= (punchHoleRadius * 2)
            
            // 하단 펀칭 직후 뾰족한 부분 깎기
            path.addArc(
                withCenter: .init(x: currentX - sideDiffByPunchHoleRadius, y: height - miniCornerRadius),
                radius: miniCornerRadius,
                startAngle: punchHoleTangentAngleSmall,
                endAngle: 0.5 * .pi,
                clockwise: true
            )
            
            currentX -= sidePadding
            path.addLine(to: CGPoint(x: currentX + sideDiffByPunchHoleRadius, y: height))
        }
        
        path.addLine(to: CGPoint(x: cornerRadius + sideDiffByCornerRadius, y: height))
        
        // --- 좌하단 코너 ---
        
        // 좌하단 코너 직전 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: cornerRadius + sideDiffByCornerRadius, y: height - miniCornerRadius),
            radius: miniCornerRadius,
            startAngle: 0.5 * .pi,
            endAngle: 0.5 * .pi + cornerTangentAngleBig,
            clockwise: true
        )
        
        // 좌하단 오목한 코너 그리기
        path.addArc(
            withCenter: CGPoint(x: 0, y: height),
            radius: cornerRadius,
            startAngle: -punchHoleTangentAngleSmall,
            endAngle: -0.5 * .pi + punchHoleTangentAngleSmall,
            clockwise: false
        )
        
        // 좌하단 코너 직후 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: miniCornerRadius, y: height - cornerRadius - sideDiffByCornerRadius),
            radius: miniCornerRadius,
            startAngle: 0.5 * .pi + cornerTangentAngleSmall,
            endAngle: .pi,
            clockwise: true
        )
        
        // --- 좌측면 ---
        // 좌측 수직선
        path.addLine(to: CGPoint(x: 0, y: cornerRadius + sideDiffByCornerRadius))
        
        // --- 좌상단 코너 ---
        
        // 좌하단 코너 직전 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: miniCornerRadius, y: cornerRadius + sideDiffByCornerRadius),
            radius: miniCornerRadius,
            startAngle: .pi,
            endAngle: .pi + cornerTangentAngleBig,
            clockwise: true
        )
        
        // 좌상단 오목한 코너 (시작점으로 돌아가는 코너)
        path.addArc(
            withCenter: CGPoint(x: 0, y: 0),
            radius: cornerRadius,
            startAngle: 0.5 * .pi - cornerTangentAngleSmall,
            endAngle: cornerTangentAngleSmall,
            clockwise: false
        )
        
        // 좌하단 코너 직후 뾰족한 부분 깎기
        path.addArc(
            withCenter: .init(x: cornerRadius + sideDiffByCornerRadius, y: miniCornerRadius),
            radius: miniCornerRadius,
            startAngle: .pi + cornerTangentAngleSmall,
            endAngle: -0.5 * .pi - cornerTangentAngleSmall,
            clockwise: true
        )
        
        path.close()
        
        return path.cgPath
    }
    
}
