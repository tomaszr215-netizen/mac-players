' ============================================
' MAIN SCENE - STALKER IPTV PLAYER
' ============================================

sub Show(args as Object)
    print ""
    print "╔════════════════════════════════════════╗"
    print "║   STALKER IPTV PLAYER - INITIALIZING  ║"
    print "╚════════════════════════════════════════╝"
    print ""
    
    ' ========== CONFIGURATION ==========
    ' ENTER YOUR DATA HERE!
    ' ====================================
    
    STALKER_SERVER = "http://your-stalker-server.com"    ' Server address
    STALKER_MAC = "00:1a:2b:3c:4d:5e"                    ' Your MAC address
    
    ' ====================================
    
    print "Server: " + STALKER_SERVER
    print "MAC: " + STALKER_MAC
    print ""
    
    ' Create GridView (channel grid display)
    m.gridView = CreateObject("roSGNode", "GridView")
    m.top.AppendChild(m.gridView)
    
    ' Configure appearance
    m.gridView.posterShape = "square"
    m.gridView.showOverlay = true
    
    ' Prepare content with handler
    content = CreateObject("roSGNode", "ContentNode")
    content.AddFields({
        HandlerConfigGridView: {
            name: "StalkerContentHandler",
            fields: {
                serverUrl: STALKER_SERVER,
                mac: STALKER_MAC
            }
        }
    })
    
    m.gridView.content = content
    
    ' Handle channel click
    m.gridView.ObserveField("selectedItem", "OnChannelSelected")
    
    ' Show view
    m.top.ComponentController.CallFunc("show", {
        view: m.gridView
    })
    
    print "GridView initialised"
    print ""
    
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
    
    m.top.signalBeacon("AppLaunchComplete")
    
    print "╔════════════════════════════════════════╗"
    print "║       READY - WAITING FOR CHANNELS    ║"
    print "╚════════════════════════════════════════╝"
    print ""
end sub

' When user selects a channel
sub OnChannelSelected(event as Object)
    selectedItem = event.GetData()
    
    if selectedItem <> invalid
        print ""
        print "╔════════════════════════════════════════╗"
        print "║          CHANNEL SELECTED"
        print "╠════════════════════════════════════════╣"
        print "║ Name: " + selectedItem.Title
        print "║ Group: " + selectedItem.Description
        print "║ URL: " + selectedItem.Url
        print "╚════════════════════════════════════════╝"
        print ""
        
        PlayChannel(selectedItem)
    end if
end sub

' Play selected channel
sub PlayChannel(channel as Object)
    print "Playing: " + channel.Title
    print ""
    
    ' Create VideoView
    m.videoView = CreateObject("roSGNode", "VideoView")
    m.top.AppendChild(m.videoView)
    
    ' Prepare playlist
    playlistContent = CreateObject("roSGNode", "ContentNode")
    playlistItem = playlistContent.CreateChild("ContentNode")
    playlistItem.Title = channel.Title
    playlistItem.Url = channel.Url
    playlistItem.StreamFormat = channel.StreamFormat
    
    ' Set content
    m.videoView.content = playlistContent
    m.videoView.isContentList = false
    
    ' Show VideoView
    m.top.ComponentController.CallFunc("show", {
        view: m.videoView
    })
    
    ' Start playback
    m.videoView.control = "play"
end sub

sub Input(args as object)
    if IsDeepLinking(args)
        PerformDeepLinking(args)
    end if
end sub