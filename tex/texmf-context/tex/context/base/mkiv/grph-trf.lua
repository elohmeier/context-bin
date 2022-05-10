if not modules then modules = { } end modules ['grph-trf'] = {
    version   = 1.001,
    comment   = "companion to grph-trf.mkiv",
    author    = "Hans Hagen, PRAGMA-ADE, Hasselt NL",
    copyright = "PRAGMA ADE / ConTeXt Development Team",
    license   = "see context related readme files"
}

-- see grph-trf-todo.lua for older preliminary code for the rest

local sind, cosd, tand, abs = math.sind, math.cosd, math.tand, math.abs

local texsetdimen = tex.setdimen

local function analyzerotate(rotation,width,height,depth,total,notfit,obeydepth)
    --
 -- print(rotation,width,height,depth,notfit,obeydepth)
    --
    local sin       = sind(rotation)
    local cos       = cosd(rotation)
    local abssin    = abs(sin)
    local abscos    = abs(cos)
    local xsize     = 0
    local ysize     = 0
    local xposition = 0
    local yposition = 0
    local xoffset   = 0
    local yoffset   = 0
    local newwidth  = width
    local newheight = height
    local newdepth  = depth
 -- print(sin,cos)
    if sin > 0 then
        if cos > 0 then
            xsize     = cos * width + sin * total
            ysize     = sin * width + cos * total
            yposition =               cos * total
            if notfit then
                xoffset  = - sin * height
                newwidth = sin * depth + cos * width
            else
                newwidth = xsize + xposition - xoffset
            end
            if obeydepth then
                yoffset = cos * depth
            end
            newheight = ysize - yoffset
            newdepth  = yoffset
         -- print("case 1, done")
        else
            xsize     = abscos * width +    sin * total
            ysize     =    sin * width + abscos * total
            xposition = abscos * width
            if notfit then
                xoffset = - xsize + sin * depth
            end
            if obeydepth then
                yoffset  = abscos * height
                newwidth = abssin * total + abscos * width + xoffset
            else
                newwidth = xsize
            end
            newheight = ysize - yoffset
            newdepth  = yoffset
         -- print("case 2, done")
        end
    else
        if cos < 0 then
            xsize     = abscos * width + abssin * total
            ysize     = abssin * width + abscos * total
            xposition = xsize
            yposition = abssin * width
            if notfit then
                xoffset = - xsize + abssin * height
            end
            if obeydepth then
                yoffset = ysize + cos * depth
            end
            newwidth  = notfit and (abssin * height) or xsize
            newheight = ysize - yoffset
            newdepth  = yoffset
         -- print("case 3, done")
        else
            xsize     =    cos * width + abssin * total
            ysize     = abssin * width +    cos * total
            xposition =                  abssin * total
            yposition =                     cos * total
            if notfit then
                xoffset = - abssin * depth
                newwidth = xsize + xoffset
            else
                newwidth = xsize
            end
            if obeydepth then
                yoffset = cos * depth
            end
            newheight = ysize - yoffset + sin * width
            newdepth  =         yoffset - sin * width
         -- print("case 4, done")
        end
    end
    texsetdimen("d_grph_rotate_x_size",     xsize)
    texsetdimen("d_grph_rotate_y_size",     ysize)
    texsetdimen("d_grph_rotate_x_position", xposition)
    texsetdimen("d_grph_rotate_y_position", yposition)
    texsetdimen("d_grph_rotate_x_offset",   xoffset)
    texsetdimen("d_grph_rotate_y_offset",   yoffset)
    texsetdimen("d_grph_rotate_new_width",  newwidth)
    texsetdimen("d_grph_rotate_new_height", newheight)
    texsetdimen("d_grph_rotate_new_depth",  newdepth)
end

interfaces.implement {
    name      = "analyzerotate",
    actions   = analyzerotate,
    arguments = {
--         "integer",
        "number",
        "dimension",
        "dimension",
        "dimension",
        "dimension",
        "conditional",
        "conditional",
    },
}
