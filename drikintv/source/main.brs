sub Main()
    print "Main"
    ShowHomeScreen(CreateListScreen())
end sub

Function CreateListScreen() As Object
    print "CreateListScreen"
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.setMessagePort(port)
    screen.setListStyle("flat-episodic")
    return screen
End Function

Function ShowHomeScreen(screen) As Integer
    print "ShowHomeScreen"
    list = GetEpisodeList()
    screen.setContentList(list)
    screen.setFocusedListItem(list.Count() - 1)
    screen.show()

    while true
        msg = wait(0, screen.getMessagePort())
        if type(msg) = "roPosterScreenEvent"
            print "Event: "; msg.GetType(); " msg: "; msg.GetMessage(); " idx: "; msg.GetIndex(); " " msg.GetData()
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isListItemSelected()
                print "Item selected"
                ShowVideo(list[msg.GetIndex()])
            else
                print "Unknown event"
            endif
        else
            print "wrong type.... type="; msg.GetType(); " msg: "; msg.GetMessage()
        endif
    end while
    screen.Close()
End Function

Function GetEpisodeList() As Object
    print "GetEpisodeList"
    rss = GetRSS("http://feeds.feedburner.com/drikintv_v")
    list = []
    for each item in rss.channel.item
        thumb_src = "http://a.images.blip.tv/" + item.GetNamedElements("blip:thumbnail_src").GetText()

        list.Unshift({
            ContentType: "episode",
            Title: item.title.GetText(),
            Description: item.description.GetText() + " / " + item.pubDate.GetText(),
            Live: false,
            SDPosterUrl: thumb_src,
            HDPosterUrl: thumb_src,
            StreamFormat: "mp4",
            StreamUrls: [ item.enclosure@url ],
            StreamBitrates: [ 1500 ],
            StreamContentIDs: [ item.GetNamedElements("blip:item_id").GetText() ],
            StreamStickyHttpRedirects: [ true ],
            StreamQualities: [ "HD" ],
            IsHD: true,
            Length: strtoi(item.runtime.GetText())
        })
    next
    return list
End Function

Function GetRSS(url) As Object
    print "GetRSS"
    rss = CreateObject("roUrlTransfer")
    rss.SetUrl(url)
    xml = CreateObject("roXMLElement")
    xml.Parse(rss.GetToString())
    return xml
End Function

Function ShowVideo(video)
    'video.StreamUrls[0] = "http://stanimoto.typepad.com/test/sample_iPod.m4v"
    print "ShowVideo "; video.StreamUrls[0]
    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    screen.setMessagePort(port)

    screen.SetContent(video)
    screen.show()

    while true
        msg = wait(0, screen.getMessagePort())
        if type(msg) = "roVideoScreenEvent"
            print "Event: "; msg.GetType(); " msg: "; msg.GetMessage(); " idx: "; msg.GetIndex(); " "; msg.GetData()

            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isRequestFailed()
                print "Request failed: "; msg.GetMessage()
            else
                print "Unknown event"
            endif
        else
            print "wrong type.... type="; msg.GetType(); " msg: "; msg.GetMessage()
        endif
    end while
End Function
