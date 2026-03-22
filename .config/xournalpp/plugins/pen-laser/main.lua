local pensize = require('pen-size')
local colorcycle = require('color-cycle')

function initUi()
    registerShortcut('Undo', 'doUndo', 'g')
    registerShortcut('Redo', 'doRedo', 'r')
    registerShortcut('Cycle colors', 'cycleColors', 'f')
    registerShortcut('Pen', 'usePen', 'c')
    registerShortcut('Cycle pen size', 'cyclePenSize', '<Shift>c')
    registerShortcut('Laser pointer', 'useLaser', 'x')
    registerShortcut('Rectangle tool', 'useRectangle', 's')
    registerShortcut('Arrow drawing', 'useArrow', 'w')
    registerShortcut('Highlighter', 'useHighlighter', 'd')
    registerShortcut('Text tool', 'useText', 't')
    registerShortcut('Zoom fit', 'zoomFit', 'a')
end

function registerShortcut(menu, callback, accelerator)
    app.registerUi({
        menu = menu,
        callback = callback,
        accelerator = accelerator
    })
end

function doUndo()
    app.uiAction({ action = 'ACTION_UNDO' })
end

function doRedo()
    app.uiAction({ action = 'ACTION_REDO' })
end

function cycleColors()
    colorcycle.cycleColors()
end

function cyclePenSize()
    pensize.cyclePenSize()
end

function clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_DRAW_RECT', enabled = false })
    app.uiAction({ action = 'ACTION_TOOL_DRAW_ARROW', enabled = false })
end

function usePen()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_PEN' })
    app.uiAction({ action = 'ACTION_SHAPE_RECOGNIZER', enabled = true })
end

function useLaser()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_LASER_POINTER_PEN' })
end

function useRectangle()
    app.uiAction({ action = 'ACTION_TOOL_PEN' })
    app.uiAction({ action = 'ACTION_TOOL_DRAW_ARROW', enabled = false })
    app.uiAction({ action = 'ACTION_TOOL_DRAW_RECT', enabled = true })
    app.uiAction({ action = 'ACTION_SHAPE_RECOGNIZER', enabled = true })
end

function useArrow()
    app.uiAction({ action = 'ACTION_TOOL_PEN' })
    app.uiAction({ action = 'ACTION_TOOL_DRAW_RECT', enabled = false })
    app.uiAction({ action = 'ACTION_TOOL_DRAW_ARROW', enabled = true })
    app.uiAction({ action = 'ACTION_SHAPE_RECOGNIZER', enabled = true })
end

function useHighlighter()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_HIGHLIGHTER' })
    app.uiAction({ action = 'ACTION_SHAPE_RECOGNIZER', enabled = true })
end

function useText()
    clearShapeModes()
    app.uiAction({ action = 'ACTION_TOOL_TEXT' })
end

function zoomFit()
    app.uiAction({ action = 'ACTION_ZOOM_FIT' })
end
