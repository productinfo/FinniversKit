//
// Copyright (c) 2019 FINN AS. All rights reserved.
//

import UIKit

protocol GalleryPreviewViewDataSource {
    func loadImage(withIndex index: Int, dataCallback: @escaping (Int, UIImage?) -> Void)
}

protocol GalleryPreviewViewDelegate {
    func galleryPreviewView(_ previewView: GalleryPreviewView, selectedImageAtIndex index: Int)
}

class GalleryPreviewView: UIView {

    // MARK: - Public properties

    var dataSource: GalleryPreviewViewDataSource?
    var delegate: GalleryPreviewViewDelegate?

    var viewModel: FullscreenGalleryViewModel? {
        didSet {
            reloadData()
        }
    }

    // MARK: - Private properties

    private lazy var cellSize: CGSize = {
        switch (UIDevice.current.userInterfaceIdiom) {
        case .phone:
            return CGSize(width: 100, height: 100)
        default:
            return CGSize(width: 150, height: 150)
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = cellSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(GalleryPreviewCell.self)
        return collectionView
    }()

    private var images = [UIImage?]()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self

        addSubview(collectionView)
        collectionView.fillInSuperview()

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: cellSize.height)
        ])
    }

    // MARK: - Public methods

    public func scrollToItem(atIndex index: Int) {
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }

    // MARK: - Private methods

    private func reloadData() {
        let imageCount = viewModel?.imageUrls.count ?? 0
        images = Array<UIImage?>(repeating: nil, count: imageCount)

        collectionView.reloadData()

        for counter in 0 ..< imageCount {
            dataSource?.loadImage(withIndex: counter, dataCallback: { [weak self] (index, image) in
                guard let self = self else { return }

                if index >= 0 && index < self.images.count {
                    self.images[index] = image
                }

                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            })
        }
    }
}

extension GalleryPreviewView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(GalleryPreviewCell.self, for: indexPath)

        let index = indexPath.row

        var image: UIImage? = nil
        if index >= 0 && index < images.count {
            image = images[index]
        }

        cell.configure(withImage: image)
        return cell
    }
}

extension GalleryPreviewView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.galleryPreviewView(self, selectedImageAtIndex: indexPath.row)
    }
}
