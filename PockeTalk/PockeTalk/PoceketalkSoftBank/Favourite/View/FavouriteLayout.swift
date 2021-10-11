
import UIKit
protocol FavouriteLayoutDelegate {

    func getHeightFrom(collectionView: UICollectionView, heightForRowIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

class FavouriteLayout: UICollectionViewLayout {

    var attributes  = Array<UICollectionViewLayoutAttributes>()
    var initialAttributes = Array<UICollectionViewLayoutAttributes>()
    var contentSize: CGSize = .zero
    var delegate: FavouriteLayoutDelegate!

    override func prepare() {
        super.prepare()
        attributes.removeAll(keepingCapacity: false)
        if collectionView?.numberOfSections != 1 {
            return
        }
        var top = CGFloat(0.0)
        let left = CGFloat(0.0)
        let width = collectionView?.frame.size.width
        self.contentSize = CGSize(width: width!, height: 0)
        guard let limit = collectionView?.numberOfItems(inSection: 0) else {
            return
        }

        for item in 0..<limit {
            let indexPath = IndexPath(item: item, section: 0)
            let height = delegate.getHeightFrom(collectionView:collectionView!, heightForRowIndexPath: indexPath, withWidth: SIZE_HEIGHT-60)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(x: left, y: top, width: width!, height: height)
            
            attribute.frame = frame
            attribute.zIndex = item
            // let gap = self.itemGap
            self.attributes.append(attribute)
            top += height-25
        }
        if self.attributes.count > 0 {
            let lastItemAttributes = self.attributes.last
            let newHeight = (lastItemAttributes?.frame.origin.y)! + (lastItemAttributes?.frame.size.height)!
            let newWidth = (self.collectionView?.frame.size.width)!
            self.contentSize = CGSize(width: newWidth, height: newHeight)
        }

    }

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        for attributes in self.attributes {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        return self.attributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


