' Copyright (c) 2018 Roku, Inc. All rights reserved.
' SGDEX Framework - Initialization

sub RunUserInterface(args)
    m.args = args
    if Type(GetSceneName) <> "<uninitialized>" AND GetSceneName <> invalid AND GetInterface(GetSceneName, "ifFunction") <> invalid then
        StartSGDEXChannel(GetSceneName(), args)
    else
        ? "Error: SGDEX requires GetSceneName() function"
    end if
end sub

sub StartSGDEXChannel(componentName, args)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)
    scene = screen.CreateScene(componentName)

    if Type(MainInit) = "Function" OR Type(MainInit) = "roFunction"
        MainInit(screen, args)
    end if

    screen.Show()
    scene.ObserveField("exitChannel", m.port)
    scene.launch_args = args

    input = CreateObject("roInput")
    input.setMessagePort(m.port)
    
    while (true)
        msg = Wait(0, m.port)
        msgType = Type(msg)
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if msgType = "roSGNodeEvent"
            field = msg.getField()
            data = msg.getData()
            if field = "exitChannel" and data = true
                END
            end if
        else if msgType = "roInputEvent"
            scene.input_args = msg.getInfo()
        end if

        if Type(MainHandleEvent) = "Function" OR Type(MainHandleEvent) = "roFunction"
            MainHandleEvent(msg)
        end if
    end while
end sub