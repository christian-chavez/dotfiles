function initUi()
    app.registerUi({
        menu = 'Undo',
        callback = 'doUndo',
        accelerator = 'u'
    })

    app.registerUi({
        menu = 'Redo',
        callback = 'doRedo',
        accelerator = 'r'
    })

    app.registerUi({
        menu = 'Cycle colors',
        callback = 'cycleColors',
        accelerator = 'f'
    })

    app.registerUi({
        menu = 'Pen',
        callback = 'usePen',
        accelerator = 'c'
    })

    app.registerUi({
        menu = 'Laser pointer',
        callback = 'useLaser',
        accelerator = 'x'
    })

    app.registerUi({
        menu = 'Rectangle tool',
        callback = 'useRectangle',
        accelerator = 's'
    })

    app.registerUi({
        menu = 'Arrow drawing',
        callback = 'useArrow',
        accelerator = 'w'
    })

    app.registerUi({
        menu = 'Highlighter',
        callback = 'useHighlighter',
        accelerator = 'd'
    })

    app.registerUi({
        menu = 'Text tool',
        callback = 'useText',
        accelerator = 't'
    })

    app.registerUi({
        menu = 'Zoom fit',
        callback = 'zoomFit',
        accelerator = 'a'
    })
end

local colorList = {
    { 'Scarlet', 0xFC2626 }, -- 252 38 38
    { 'MrBlue',  0x0634F5 }, -- 6 52 245
    { 'Darky',   0x241F31 }, -- 36 31 49
}

local currentColor = 0

function syncCurrentColorFromActiveTool()
    local ok, toolInfo = pcall(function()
        return app.getToolInfo('active')
    end)

    if not ok or toolInfo == nil or toolInfo['color'] == nil then
        return
    end

    local activeColor = toolInfo['color']

    for i = 1, #colorList do
        if colorList[i][2] == activeColor then
            currentColor = i
            return
        end
    end

    -- Active color is not one of your tracked colors.
    -- So the next press of f will start again from the first color.
    currentColor = 0
end

function cycleColors()
    syncCurrentColorFromActiveTool()

    if currentColor < #colorList then
        currentColor = currentColor + 1
    else
        currentColor = 1
    end

    app.changeToolColor({
        color = colorList[currentColor][2],
        selection = true
    })
end

function clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_DRAW_RECT', enabled = false })
    app.uiAction({ action = 'ACTION_TOOL_DRAW_ARROW', enabled = false })
end

function usePen()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_PEN' })
end

function useLaser()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_LASER_POINTER_PEN' })
end

function useRectangle()
    app.uiAction({ action = 'ACTION_TOOL_DRAW_RECT' })
end

function useArrow()
    app.uiAction({ action = 'ACTION_TOOL_DRAW_ARROW' })
end

function useHighlighter()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_HIGHLIGHTER' })
end

function useText()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_TEXT' })
end

function zoomFit()
    app.uiAction({ action = 'ACTION_ZOOM_FIT' })
end
