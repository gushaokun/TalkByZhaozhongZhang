//
//  VideoListCell.swift
//  TalkByZhaozhongZhang
//
//  Created by Gavin on 16/3/11.
//  Copyright © 2016年 Gavin. All rights reserved.
//

import UIKit

class VideoListCell: UICollectionViewCell {
    @IBOutlet weak var albumView: UIImageView!
    @IBOutlet weak var playView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    override func awakeFromNib() {
//        self.contentView.layer.cornerRadius = 2
//        self.contentView.clipsToBounds = true
        
        self.layer.shadowColor = UIColor(white: 0, alpha: 0.4).CGColor
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3
        
    }
    func configForModel(model:ListModel){
        
        if model.isloaded {
            self.albumView.sd_setImageWithURL(NSURL(string: (model.large_poster)!)!)
            self.titleView.text = model.title
        }else{
            self.albumView.image = nil
            self.titleView.text = nil
            if model.isloading == false {
                (VideoListViewModel()).loadAlbumInfoForModel(model) { (result:Bool,data:ListModel?) -> () in
                    if result {
                        self.albumView.sd_setImageWithURL(NSURL(string: (data?.large_poster)!)!)
                        self.titleView.text = data?.title

                    }
                }
            }
        }
        
    }
    
}
