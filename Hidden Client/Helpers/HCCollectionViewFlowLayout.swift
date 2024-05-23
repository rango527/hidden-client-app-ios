//
//  HCCollectionViewFlowLayout.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/17.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class HCCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private var lastCollectionViewSize: CGSize = CGSize.zero
    private var lastScrollDirection: UICollectionView.ScrollDirection!
    private var lastItemSize: CGSize = CGSize.zero
    
    var pageWidth: CGFloat {
        return itemSize.width + minimumLineSpacing
    }
    var targetOffset: CGFloat = 0.0
    
    var currentCenteredPage: Int? {
        guard let collectionView = collectionView else { return nil }
        let currentCenteredPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.width/2, y: collectionView.contentOffset.y + collectionView.bounds.height/2)
        
        return collectionView.indexPathForItem(at: currentCenteredPoint)?.row
    }
    
    override init() {
        super.init()
        scrollDirection = .horizontal
        lastScrollDirection = scrollDirection
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .horizontal
        lastScrollDirection = scrollDirection
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        guard let collectionView = collectionView else { return }
        
        // invalidate layout to center first and last
        let currentCollectionViewSize = collectionView.bounds.size
        if !currentCollectionViewSize.equalTo(lastCollectionViewSize) || lastScrollDirection != scrollDirection || lastItemSize != itemSize {
            let inset = (currentCollectionViewSize.width - itemSize.width) / 2
            collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            collectionView.contentOffset = CGPoint(x: -inset, y: 0)
            lastCollectionViewSize = currentCollectionViewSize
            lastScrollDirection = scrollDirection
            lastItemSize = itemSize
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let proposedRect: CGRect = determineProposedRect(collectionView: collectionView, proposedContentOffset: proposedContentOffset)
        
        guard let layoutAttributes = layoutAttributesForElements(in: proposedRect),
            let candidateAttributesForRect = attributesForRect(
                collectionView: collectionView,
                layoutAttributes: layoutAttributes,
                proposedContentOffset: proposedContentOffset
            ) else { return proposedContentOffset }
        
        var newOffset = candidateAttributesForRect.center.x - collectionView.bounds.size.width / 2
        let offset = newOffset - collectionView.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = itemSize.width + minimumLineSpacing
            newOffset += velocity.x > 0 ? pageWidth : -pageWidth
        }
        targetOffset = newOffset
        return CGPoint(x: newOffset, y: proposedContentOffset.y)
    }
    
    func scrollToPage(index: Int, animated: Bool) {
        guard let collectionView = collectionView else { return }
        
        let pageOffset = CGFloat(index) * pageWidth - collectionView.contentInset.left
        let proposedContentOffset = CGPoint(x: pageOffset, y: collectionView.contentOffset.y)
        let shouldAnimate = abs(collectionView.contentOffset.x - pageOffset) > 1 ? animated : false
        
        collectionView.setContentOffset(proposedContentOffset, animated: shouldAnimate)
    }
}

extension HCCollectionViewFlowLayout {
    
    func determineProposedRect(collectionView: UICollectionView, proposedContentOffset: CGPoint) -> CGRect {
        let size = collectionView.bounds.size
        let origin = CGPoint(x: proposedContentOffset.x, y: collectionView.contentOffset.y)
        return CGRect(origin: origin, size: size)
    }
    
    func attributesForRect(collectionView: UICollectionView, layoutAttributes: [UICollectionViewLayoutAttributes], proposedContentOffset: CGPoint) -> UICollectionViewLayoutAttributes? {
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedCenterOffset = proposedContentOffset.x + collectionView.bounds.size.width / 2
        
        for attributes in layoutAttributes {
            guard attributes.representedElementCategory == .cell else { continue }
            guard candidateAttributes != nil else {
                candidateAttributes = attributes
                continue
            }
            
            if abs(attributes.center.x - proposedCenterOffset) < abs(candidateAttributes!.center.x - proposedCenterOffset) {
                candidateAttributes = attributes
            }
        }
        return candidateAttributes
    }
}
