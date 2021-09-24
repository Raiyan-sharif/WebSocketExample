//
//  CustomOverlappingView.swift
//  PockeTalk
//
//  Created by BJIT LTD on 15/9/21.
//


import UIKit

protocol CropOverlappingViewDelegates {
    func didMoveOverlappingView(newFrame: CGRect)
}

class CustomOverlappingView: UIView {

    private let rectangleCornerButtons = [UIButton(),
                           UIButton(),
                           UIButton(),
                           UIButton()]
    private let horizontalVerticalcrossOverView = UIView()

    private var cornerButtonWidth: CGFloat = 50

    private let cornerLineWidth: CGFloat = 3
    private var cornerLineLength: CGFloat {
        return cornerButtonWidth / 2
    }

    private let lineDepth = 1

    private let _outterGap = 1/3
    private var outterGap: CGFloat {
        return cornerButtonWidth * CGFloat(self._outterGap)
    }

    var isResizable = false
    var isdragable = false
    var minCropArea = CGSize.zero
    var delegate: CropOverlappingViewDelegates?

    var croppedRect: CGRect {
        return CGRect(x: frame.origin.x + outterGap,
                      y: frame.origin.y + outterGap,
                      width: frame.size.width - 2 * outterGap,
                      height: frame.size.height - 2 * outterGap)
    }

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if !isdragable && isResizable {
            let isButton = rectangleCornerButtons.reduce(false) { $1.hitTest(convert(point, to: $1), with: event) != nil || $0 }
            if !isButton {
                return nil
            }
        }

        return view
    }
    private func loadButtons() {
        rectangleCornerButtons.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)

            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragWith(dragableGesture:)))
            $0.addGestureRecognizer(panGesture)
        }

        rectangleCornerButtons[0].topAnchor.constraint(equalTo: topAnchor).isActive = true
        rectangleCornerButtons[0].leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        rectangleCornerButtons[0].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        rectangleCornerButtons[0].heightAnchor.constraint(equalTo: rectangleCornerButtons[0].widthAnchor).isActive = true

        rectangleCornerButtons[1].topAnchor.constraint(equalTo: topAnchor).isActive = true
        rectangleCornerButtons[1].rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rectangleCornerButtons[1].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        rectangleCornerButtons[1].heightAnchor.constraint(equalTo: rectangleCornerButtons[1].widthAnchor).isActive = true

        rectangleCornerButtons[2].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rectangleCornerButtons[2].leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        rectangleCornerButtons[2].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        rectangleCornerButtons[2].heightAnchor.constraint(equalTo: rectangleCornerButtons[2].widthAnchor).isActive = true

        rectangleCornerButtons[3].bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rectangleCornerButtons[3].rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        rectangleCornerButtons[3].widthAnchor.constraint(equalToConstant: cornerButtonWidth).isActive = true
        rectangleCornerButtons[3].heightAnchor.constraint(equalTo: rectangleCornerButtons[3].widthAnchor).isActive = true
    }

    private func loadPrecisionView() {
        horizontalVerticalcrossOverView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalVerticalcrossOverView)

        horizontalVerticalcrossOverView.isUserInteractionEnabled = false
        horizontalVerticalcrossOverView.layer.borderWidth = 1
        horizontalVerticalcrossOverView.layer.borderColor = UIColor.white.cgColor

        horizontalVerticalcrossOverView.topAnchor.constraint(equalTo: topAnchor, constant: outterGap).isActive = true
        horizontalVerticalcrossOverView.leftAnchor.constraint(equalTo: leftAnchor, constant: outterGap).isActive = true
        horizontalVerticalcrossOverView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -outterGap).isActive = true
        horizontalVerticalcrossOverView.rightAnchor.constraint(equalTo: rightAnchor, constant: -outterGap).isActive = true

        drawCornerLines()
        loadPrecisionLines()
    }

    private func drawCornerLines() {
        let lines = [UIView(), UIView(),  // top left
            UIView(), UIView(),  // top right
            UIView(), UIView(),  // bottom left
            UIView(), UIView()]  // bottom right

        lines.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            horizontalVerticalcrossOverView.addSubview($0)

            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .white

            let index = lines.firstIndex(of: $0)!

            if index % 2 == 0 {
                $0.widthAnchor.constraint(equalToConstant: cornerLineWidth).isActive = true
                $0.heightAnchor.constraint(equalToConstant: cornerLineLength).isActive = true

                if index <= 3 {
                    $0.topAnchor.constraint(equalTo: horizontalVerticalcrossOverView.topAnchor, constant: -cornerLineWidth).isActive = true
                } else {
                    $0.bottomAnchor.constraint(equalTo: horizontalVerticalcrossOverView.bottomAnchor, constant: cornerLineWidth).isActive = true
                }

                if index % 4 == 0 {
                    $0.rightAnchor.constraint(equalTo: horizontalVerticalcrossOverView.leftAnchor).isActive = true
                } else {
                    $0.leftAnchor.constraint(equalTo: horizontalVerticalcrossOverView.rightAnchor).isActive = true
                }
            } else {
                $0.widthAnchor.constraint(equalToConstant: cornerLineLength).isActive = true
                $0.heightAnchor.constraint(equalToConstant: cornerLineWidth).isActive = true

                if index <= 3 {
                    $0.leftAnchor.constraint(equalTo: horizontalVerticalcrossOverView.leftAnchor, constant: -cornerLineWidth).isActive = true
                } else {
                    $0.rightAnchor.constraint(equalTo: horizontalVerticalcrossOverView.rightAnchor, constant: cornerLineWidth).isActive = true
                }

                if index % 4 == 1 {
                    $0.bottomAnchor.constraint(equalTo: horizontalVerticalcrossOverView.topAnchor).isActive = true
                } else {
                    $0.topAnchor.constraint(equalTo: horizontalVerticalcrossOverView.bottomAnchor).isActive = true
                }
            }
        }
    }
    
    private func setup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragWith(dragableGesture:)))
        addGestureRecognizer(panGesture)

        loadButtons()
        loadPrecisionView()
    }

    @objc func dragWith(dragableGesture: UIPanGestureRecognizer) {
        if isResizable, let button = dragableGesture.view as? UIButton {
            if dragableGesture.state == .began || dragableGesture.state == .changed {
                let gestureTranslation = dragableGesture.translation(in: self)
                let minSize = CGSize(width: minCropArea.width + 2 * outterGap,
                                             height: minCropArea.height + 2 * outterGap)

                var newFrame: CGRect

                switch button {
                case rectangleCornerButtons[0]:    // Top Left
                    let hasEnoughWidth = frame.size.width - gestureTranslation.x >= minSize.width
                    let hasEnoughHeight = frame.size.height - gestureTranslation.y >= minSize.height

                    let xPossibleTranslation = hasEnoughWidth ? gestureTranslation.x : 0
                    let yPossibleTranslation = hasEnoughHeight ? gestureTranslation.y : 0

                    newFrame = CGRect(x: frame.origin.x + xPossibleTranslation,
                                      y: frame.origin.y + yPossibleTranslation,
                                      width: frame.size.width - xPossibleTranslation,
                                      height: frame.size.height - yPossibleTranslation)
                case rectangleCornerButtons[1]:    // Top Right
                    let hasEnoughWidth = frame.size.width + gestureTranslation.x >= minSize.width
                    let hasEnoughHeight = frame.size.height - gestureTranslation.y >= minSize.height

                    let xPossibleTranslation = hasEnoughWidth ? gestureTranslation.x : 0
                    let yPossibleTranslation = hasEnoughHeight ? gestureTranslation.y : 0

                    newFrame = CGRect(x: frame.origin.x,
                                      y: frame.origin.y + yPossibleTranslation,
                                      width: frame.size.width + xPossibleTranslation,
                                      height: frame.size.height - yPossibleTranslation)
                case rectangleCornerButtons[2]:    // Bottom Left
                    let hasEnoughWidth = frame.size.width - gestureTranslation.x >= minSize.width
                    let hasEnoughHeight = frame.size.height + gestureTranslation.y >= minSize.height

                    let xPossibleTranslation = hasEnoughWidth ? gestureTranslation.x : 0
                    let yPossibleTranslation = hasEnoughHeight ? gestureTranslation.y : 0

                    newFrame = CGRect(x: frame.origin.x + xPossibleTranslation,
                                      y: frame.origin.y,
                                      width: frame.size.width - xPossibleTranslation,
                                      height: frame.size.height + yPossibleTranslation)
                case rectangleCornerButtons[3]:
                    let hasResizeableWidth = frame.size.width + gestureTranslation.x >= minSize.width
                    let hasResizeableHeight = frame.size.height + gestureTranslation.y >= minSize.height

                    let xPossibleTranslation = hasResizeableWidth ? gestureTranslation.x : 0
                    let yPossibleTranslation = hasResizeableHeight ? gestureTranslation.y : 0

                    newFrame = CGRect(x: frame.origin.x,
                                      y: frame.origin.y,
                                      width: frame.size.width + xPossibleTranslation,
                                      height: frame.size.height + yPossibleTranslation)
                default:
                    newFrame = CGRect.zero
                }

                let minimumFrame = CGRect(x: newFrame.origin.x,
                                          y: newFrame.origin.y,
                                          width: max(newFrame.size.width,
                                                     minCropArea.width + 2 * outterGap),
                                          height: max(newFrame.size.height,
                                                      minCropArea.height + 2 * outterGap))

                dragableGesture.setTranslation(CGPoint.zero, in: self)
                
                delegate?.didMoveOverlappingView(newFrame: minimumFrame)
            }
        } else if isdragable {
            if dragableGesture.state == .began || dragableGesture.state == .changed {
                let translation = dragableGesture.translation(in: self)

                let resizedFrame = CGRect(x: frame.origin.x + translation.x,
                                      y: frame.origin.y + translation.y,
                                      width: frame.size.width,
                                      height: frame.size.height)

                dragableGesture.setTranslation(CGPoint.zero, in: self)

                delegate?.didMoveOverlappingView(newFrame: resizedFrame)
            }
        }
    }
    
    private func loadPrecisionLines() {
        let centerViewList = [UIView(), UIView()]

        centerViewList.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            horizontalVerticalcrossOverView.addSubview($0)

            $0.isUserInteractionEnabled = false

            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.cgColor
        }

        // Horizontal centered view
        centerViewList[0].leftAnchor.constraint(equalTo: horizontalVerticalcrossOverView.leftAnchor).isActive = true
        centerViewList[0].rightAnchor.constraint(equalTo: horizontalVerticalcrossOverView.rightAnchor).isActive = true
        centerViewList[0].heightAnchor.constraint(equalTo: horizontalVerticalcrossOverView.heightAnchor, multiplier: 1/3).isActive = true
        centerViewList[0].centerYAnchor.constraint(equalTo: horizontalVerticalcrossOverView.centerYAnchor).isActive = true

        // Vertical centered view
        centerViewList[1].topAnchor.constraint(equalTo: horizontalVerticalcrossOverView.topAnchor).isActive = true
        centerViewList[1].bottomAnchor.constraint(equalTo: horizontalVerticalcrossOverView.bottomAnchor).isActive = true
        centerViewList[1].widthAnchor.constraint(equalTo: horizontalVerticalcrossOverView.widthAnchor, multiplier: 1/3).isActive = true
        centerViewList[1].centerXAnchor.constraint(equalTo: horizontalVerticalcrossOverView.centerXAnchor).isActive = true
    }

}
