//
//  VideoCollectionViewCell.swift
//  ARApp
//
//  Created by yash-mac on 20/10/23.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "VideoCollectionViewCell"
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        tagLabel.text = ""
        durationLabel.text = ""
        imageView.image = nil
        imageView.animationImages = nil
    }
    
    func setupCell(url: String, duration: String, tag: String) {
        tagLabel.text = tag
        durationLabel.text = duration
        if let url = url.getURLForFile() {
            var thumbs = [UIImage]()
            url.getVideoThumbnail(cellSize: contentView.frame.size, completion: {[weak self] image, completed in
                DispatchQueue.main.async {
                    thumbs.append(image)
                    if thumbs.count == 1 {
                        self?.imageView.image = image
                    }
                    if (completed) {
                        self?.imageView.animationImages = thumbs
                        self?.imageView.startAnimating()
                    }
                    
                }
            })
        }
    }
    
    func playThumbs() {
        if imageView.animationImages?.count ?? 0 > 0 {
            imageView.startAnimating()
        }
    }
    
    func stopPlayingThumbs() {
        if imageView.isAnimating {
            imageView.stopAnimating()
        }
    }
}
