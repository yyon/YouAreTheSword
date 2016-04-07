lineify = {}

local function mysplit(inputstr, sep)
    return string.gmatch(inputstr, "([^"..sep.."]+)")
end
lineify.mysplit = mysplit

lineify.tolines = function(text, colwidth)
    lines = ""
    function addline(line)
        lines = lines .. line .. "\n"
    end
    
    for line in mysplit(text, "\n") do
        local curlen = 0
        local currentline = ""
        local firstword = true
        for word in mysplit(line, " ") do
            local strlen = string.len(word)
            if firstword then
                firstword = false
                currentline = word
                curlen = strlen
            else
                if curlen + strlen + 1 > colwidth then
                    addline(currentline)
                    currentline = word
                    curlen = strlen
                else
                    currentline = currentline .. " " .. word
                    curlen = curlen + 1 + strlen
                end
            end
        end
        addline(currentline)
    end
    
    return lines
end

lineify.toscreens = function(lines, numlines)
    screens = {}
    local linenum = 0
    local currentstring = ""
    for line in mysplit(lines, "\n") do
        if linenum >= 7 or line == "NEWSCREEN" then
            linenum = 0
            screens[#self.screens+1] = currentstring
            currentstring = ""
        end
        if line ~= "NEWSCREEN" then
            currentstring = currentstring .. line .. "\n"
            linenum = linenum + 1
        end
    end
    screens[#screens+1] = currentstring
    
    return screens
end

lineify.rendertext = function(surface, lines, font, font_size, color, rendering_mode, x, y)
        if rendering_mode then rendering_mode = "antialiasing" else rendering_mode = "solid" end
        for line in mysplit(lines, "\n") do
            local text = sol.text_surface.create({horizontal_alignement="left", vertical_alignement="bottom", rendering_mode = rendering_mode, text=line, font=font, font_size=font_size, color=color})
            local w, h = text:get_size()
            y = y + h/2
            text:draw_region(0, 0, w, h, surface, x, y)
            y = y + h/2
        end
end

return lineify