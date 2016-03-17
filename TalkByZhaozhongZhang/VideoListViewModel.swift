//
//  VideoListViewModel.swift
//  TalkByZhaozhongZhang
//
//  Created by Gavin on 16/3/11.
//  Copyright © 2016年 Gavin. All rights reserved.
//

import UIKit
private let video_info_api = "http://dyn.v.ifeng.com/cmpp/video_msg_ipad.js"
class ListModel: NSObject {
    
    var title:String?
    var url:String?
    var large_poster:String?
    var videoplayurl:String?
    var video_id:String?
    var isloaded = false
    var isloading = false
    init(title:String?,url:String?) {
        self.title = title
        self.url = url
    }
    
}

class VideoListViewModel: UICollectionViewCell {
    
    func parseVideoListFromHTML(htmlStr:NSString?, complete:(models:[ListModel])->()){
        
        print((htmlStr?.length)!)
        let pattern = "<div class=\"comListBox\">[\\s\\S]*?</div>"
        
        let sub_url_pattern = "\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?"
        
        let sub_title_pattern = "\">(.*?)</a>"

        let regex = try? NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        let str = htmlStr as! String
        
        //div 列表
        let result = regex?.matchesInString(str, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, (htmlStr?.length)!))
        var videoList:[ListModel] = []
        for textResult in result! {
            
            let range = textResult.range
            let searchStr = htmlStr!.substringWithRange(range)
            
            //url
            let url_regex = try? NSRegularExpression(pattern: sub_url_pattern, options: .CaseInsensitive)
            let str = searchStr as NSString
            let sub_url_result = url_regex?.matchesInString(searchStr, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, (str.length)))
            let sub_url_range = (sub_url_result![0] as NSTextCheckingResult).range
            let url = str.substringWithRange(sub_url_range)
            
            
            //title
            let title_regex = try? NSRegularExpression(pattern: sub_title_pattern, options: .CaseInsensitive)
            let sub_title_result = title_regex?.matchesInString(searchStr, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, (str.length)))
            let sub_title_range = (sub_title_result![0] as NSTextCheckingResult).range
            let title = (str.substringWithRange(sub_title_range) as NSString).substringWithRange(NSMakeRange(2, (sub_title_range.length)-6))
            let model = ListModel(title: title, url: url)
            videoList.append(model)
            debugPrint("title=\(title), url=\(url)")
        }
        complete(models: videoList)
    }
    
    func loadAlbumInfoForModel(model:ListModel, complete:(result:Bool,data:ListModel?)->()){
//        <li name="0104eb21-598e-4303-90c6-1d7eba7a11d8" class=""></li>
        let pattern = "<li name=[\\s\\S]*?</li>"
        let sub_pattern = "([a-zA-Z0-9]*)\\-(.*)\\-(.*)\\-([a-zA-Z0-9]*)"
        let regex = try? NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        let sub_regex = try? NSRegularExpression(pattern: sub_pattern, options: .CaseInsensitive)

        let manager = AFHTTPSessionManager()
        manager.responseSerializer = AFHTTPResponseSerializer()
        model.isloading = true
        manager.GET(model.url!, parameters: nil, progress: nil, success: { (task:NSURLSessionDataTask,object:AnyObject?) -> Void in
            let htmlStr = NSString(data: object as! NSData, encoding: NSUTF8StringEncoding)!
            let str = htmlStr as String
            let result = regex?.matchesInString(str, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, (htmlStr.length)))
            let range = (result![0] as NSTextCheckingResult).range
            let liText = htmlStr.substringWithRange(range)
            let sub_result = sub_regex?.matchesInString(liText, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, ((liText as NSString).length)))
            let sub_range = (sub_result![0] as NSTextCheckingResult).range
            let video_id = (liText as NSString).substringWithRange(sub_range)
            model.video_id = video_id
            manager.GET(video_info_api, parameters: ["msg":video_id], progress: nil, success: { (task:NSURLSessionDataTask, data) -> Void in
                var resultStr = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding)!
                resultStr = resultStr.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " \r\n")) as NSString
                let json = resultStr.substringWithRange(NSMakeRange(1, resultStr.length-5))
                let dict = try? NSJSONSerialization.JSONObjectWithData(json.dataUsingEncoding(NSUTF8StringEncoding)!, options:.MutableContainers)
                model.large_poster = dict!["largePoster"] as? String
                model.videoplayurl = dict!["videoplayurl"] as? String
                model.isloaded = true
                model.isloading = false
                complete(result: true,data: model)

            }, failure: { (task:NSURLSessionDataTask?, error:NSError) -> Void in
                model.isloading = false
                complete(result: false,data: nil)
            })
        }, failure: { (task:NSURLSessionDataTask?, error:NSError) -> Void in
            print(error)
            model.isloading = false
            complete(result:false,data: nil)

        })
    }
    
    
    
    
}
