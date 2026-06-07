' ============================================
' CONTENT HANDLER FOR STALKER
' ============================================

sub Init()
    m.top.ObserveField("requestParams", "OnRequest")
end sub

sub OnRequest(event as Object)
    params = event.GetData()
    
    ' Validate parameters
    if params = invalid
        print "ERROR: Parameters are invalid"
        m.top.content = invalid
        return
    end if
    
    if params.serverUrl = invalid or params.mac = invalid
        print "ERROR: Missing serverUrl or mac"
        m.top.content = invalid
        return
    end if
    
    print ""
    print "=========================================="
    print "  STALKER CONTENT HANDLER - START"
    print "=========================================="
    print "Server: " + params.serverUrl
    print "MAC: " + params.mac
    print "=========================================="
    print ""
    
    ' 1. Fetch M3U from server
    m3uContent = FetchStalkerPlaylist(params.serverUrl, params.mac)
    
    if m3uContent = ""
        print "ERROR: Failed to fetch M3U"
        m.top.content = invalid
        return
    end if
    
    ' 2. Parse M3U
    items = ParseStalkerM3U(m3uContent)
    
    if items.Count() = 0
        print "ERROR: No channels found"
        m.top.content = invalid
        return
    end if
    
    ' 3. Create ContentNode for each channel
    print "Creating ContentNode for channels..."
    content = CreateObject("roSGNode", "ContentNode")
    
    for each item in items
        child = content.CreateChild("ContentNode")
        child.Title = item.Title
        child.StreamFormat = item.StreamFormat
        child.Url = item.Url
        
        if item.Logo <> ""
            child.HDPosterUrl = item.Logo
        end if
        
        if item.Group <> ""
            child.Description = item.Group
        end if
    end for
    
    print "ContentNode created: " + content.GetChildCount().ToStr() + " channels"
    print ""
    
    m.top.content = content
end sub