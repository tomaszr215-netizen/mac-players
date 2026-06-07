' ============================================
' PARSER FOR STALKER MAC PORTAL
' ============================================

function FetchStalkerPlaylist(serverUrl as String, mac as String) as String
    print ""
    print "=================================================="
    print "  FETCHING PLAYLIST FROM STALKER"
    print "=================================================="
    print "Server: " + serverUrl
    print "MAC: " + mac
    print "=================================================="
    
    ' Remove slash from end of URL
    if Right(serverUrl, 1) = "/"
        serverUrl = Left(serverUrl, Len(serverUrl) - 1)
    end if
    
    ' Build full URL
    url = serverUrl + "/portal.php?type=m3u&mac=" + mac
    print "URL: " + url
    print ""
    
    ' Fetch file
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    http.SetTimeout(30)
    
    result = http.GetToString()
    
    if result = invalid or result = ""
        print "ERROR: Failed to fetch playlist!"
        return ""
    end if
    
    print "Success! Playlist fetched"
    print "Size: " + result.Len().ToStr() + " bytes"
    print ""
    
    return result
end function

function ParseStalkerM3U(m3uContent as String) as Object
    print "Parsing M3U content..."
    
    lines = m3uContent.Split(chr(10))
    items = []
    currentTitle = ""
    currentAttributes = {}
    
    for each line in lines
        line = line.Trim()
        
        ' Skip empty lines
        if line = ""
            continue for
        end if
        
        ' Skip comments (except EXTINF)
        if line.Left(1) = "#" and line.Left(7) <> "#EXTINF"
            continue for
        end if
        
        ' ===== EXTINF (channel metadata) =====
        if line.Left(7) = "#EXTINF"
            ' Remove "#EXTINF:"
            line = line.Mid(8)
            
            ' Separate time from rest
            commaPos = line.InStr(",")
            
            if commaPos > 0
                restOfLine = line.Mid(commaPos + 1).Trim()
                currentAttributes = ParseExtinfLine(restOfLine)
                currentTitle = currentAttributes.title
            end if
        
        ' ===== URL (line without #) =====
        else if line.Left(1) <> "#"
            if currentTitle <> ""
                item = {
                    Title: currentTitle,
                    Url: line,
                    StreamFormat: "hls",
                    Logo: currentAttributes.logo,
                    Group: currentAttributes.group
                }
                items.Push(item)
            end if
            
            currentTitle = ""
            currentAttributes = {}
        end if
    end for
    
    print ""
    print "Parsed " + items.Count().ToStr() + " channels"
    print ""
    
    return items
end function

function ParseExtinfLine(line as String) as Object
    attrs = {
        title: "",
        logo: "",
        group: ""
    }
    
    ' Search for tvg-logo="..."
    logoStart = line.InStr("tvg-logo=\"")
    if logoStart > 0
        logoStart = logoStart + 11
        logoEnd = line.InStr("\"", logoStart)
        if logoEnd > logoStart
            attrs.logo = line.Mid(logoStart, logoEnd - logoStart)
        end if
    end if
    
    ' Search for group-title="..."
    groupStart = line.InStr("group-title=\"")
    if groupStart > 0
        groupStart = groupStart + 13
        groupEnd = line.InStr("\"", groupStart)
        if groupEnd > groupStart
            attrs.group = line.Mid(groupStart, groupEnd - groupStart)
        end if
    end if
    
    ' Last part after comma is channel name
    lastComma = line.InStr(",")
    if lastComma > 0
        attrs.title = line.Mid(lastComma + 1).Trim()
    else
        attrs.title = line.Trim()
    end if
    
    return attrs
end function