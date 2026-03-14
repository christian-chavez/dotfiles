function initUi()
    -- Bare keys are allowed by Xournal++ plugins, though they may interfere
    -- with the text tool. If that bothers you, change "c" -> "<Alt>c", etc.
    app.registerUi({
        menu = 'Tool: Pen',
        callback = 'usePen',
        accelerator = 'c'
    })

    app.registerUi({
        menu = 'Tool: Laser Pointer Pen',
        callback = 'useLaser',
        accelerator = 'x'
    })
end

function usePen()
    app.uiAction({ action = 'ACTION_TOOL_PEN' })
end

function useLaser()
    app.uiAction({ action = 'ACTION_TOOL_LASER_POINTER_PEN' })
end
