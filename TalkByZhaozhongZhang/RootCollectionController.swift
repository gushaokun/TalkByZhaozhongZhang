//
//  RootCollectionController.swift
//  TalkByZhaozhongZhang
//
//  Created by Gavin on 16/3/10.
//  Copyright © 2016年 Gavin. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

private let reuseIdentifier = "Cell"
private var curPage = 1

class RootCollectionController: UICollectionViewController ,UICollectionViewDelegateFlowLayout{
    var titleView:UIView?
    var models:[ListModel]?
    var headerImageView:UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingTitleView()
        self.settingCollectionView()
        self.loadVideoList(1)
        // Uncomment the following line to preserve selection between presentations
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView?.reloadData()
        self.adjustBgView()
    }
    func settingCollectionView(){
        
        let header = MJRefreshHeader { () -> Void in
            self.loadVideoList(1)
            self.collectionView!.mj_header.endRefreshing()
        }
        self.collectionView!.mj_header = header
        
        let footer = MJRefreshAutoNormalFooter { () -> Void in
            self.loadVideoList(curPage)
        }
        self.collectionView!.mj_footer = footer
        let bgview = UIView(frame: self.collectionView!.bounds)
        
        headerImageView = UIImageView()
        headerImageView?.alpha = 0.4
        header.contentMode = .Center
        bgview.addSubview(headerImageView!)
        self.collectionView?.backgroundView = bgview
        let image = UIImage(named: "refresh_bg")
        headerImageView?.image = image
        self.adjustBgView()
    }
    func adjustBgView(){
        headerImageView?.frame = CGRectMake(0, (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height ,72, 22)
        var ct = headerImageView!.center
        ct.x = (self.collectionView?.frame.size.width)!/2.0
        headerImageView?.center = ct

    }
    func settingTitleView(){
        titleView = UIView(frame: CGRectMake(0,0,98,30))
        let imageView = UIImageView(image: UIImage(named: "title"))
        imageView.frame = (titleView?.bounds)!
        imageView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight,UIViewAutoresizing.FlexibleWidth]
        titleView?.addSubview(imageView)
        self.navigationItem.titleView = titleView
        
        
    }
    
    func loadVideoList(page:Int){
        
        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        let url = "http://news.ifeng.com/o/dynpage/59-/\(page)/plist.shtml"
        manager.GET(url, parameters: nil, progress: nil, success: { (task:NSURLSessionDataTask,object:AnyObject?) -> Void in
            let htmlStr = NSString(data: object as! NSData, encoding: NSUTF8StringEncoding)
            (VideoListViewModel()).parseVideoListFromHTML(htmlStr, complete: { (models:[ListModel]) -> () in
                if page == 1 {
                    self.models = models
                }else{
                    self.models?.appendContentsOf(models)
                }
                if models.count < 16 {
                    self.endLoadRequest(true)
                }else{
                    self.endLoadRequest(false)
                }
                curPage = page + 1
                self.collectionView?.reloadData()
            })
            
            }) { (task:NSURLSessionDataTask?, error:NSError) -> Void in
                self.endLoadRequest(false)
                print(error)
        }
    }
    
    func endLoadRequest(noMoreData:Bool){
        self.collectionView!.mj_header.endRefreshing()
        if noMoreData {
            self.collectionView!.mj_footer.endRefreshingWithNoMoreData()
        }else{
            self.collectionView!.mj_footer.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if models != nil{
            return models!.count
        }
        return 0
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.size.width
        return CGSizeMake(width,width*3/4.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VideoListCell
        let model = models![indexPath.row]
        cell.configForModel(model)
        // Configure the cell
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let model = models![indexPath.row]
        if model.isloaded {
            
            let avplayer = AVPlayerViewController()
            avplayer.player = AVPlayer(URL:NSURL(string: model.videoplayurl!)!)
            avplayer.showsPlaybackControls = true
            avplayer.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(avplayer, animated: true, completion: { () -> Void in
                avplayer.player?.play()
            })
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! VideoListCell
        cell.playView.backgroundColor = UIColor(white: 0, alpha: 0.2)
    }
    
    override func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! VideoListCell
        cell.playView.backgroundColor = UIColor.clearColor()

    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.collectionView?.performBatchUpdates({ () -> Void in
            self.collectionView?.reloadData()
            }, completion: nil)

    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.adjustBgView()
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
