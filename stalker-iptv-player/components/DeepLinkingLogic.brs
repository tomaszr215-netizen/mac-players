' ********** Copyright 2024. All Rights Reserved. **********
' Deep Linking Logic

function IsDeepLinking(args as Object)
    return args <> invalid and args.mediaType <> invalid and args.mediaType <> "" and args.contentId <> invalid and args.contentId <> ""
end function

sub PerformDeepLinking(args as Object)
    print "Deep linking: " + args.mediaType + " - " + args.contentId
end sub