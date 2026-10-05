-- PerplexWare executor check  (.ppw)
-- This file is returned as plain text; paste into your loadstring target
-- or load it as the very first thing before the real script.
-- It uses identifyexecutor() / getexecutorname() which every real executor
-- exposes.  Unknown / no function  =  not a real executor, exit silently.

local function getExec()
    if identifyexecutor then
        return identifyexecutor()
    elseif getexecutorname then
        return getexecutorname()
    end
    return nil
end

local name = getExec()

if not name or name == "" or name:lower() == "unknown" then
    return  -- not a real executor; stop here, do nothing
end

-- Real executor confirmed. The middleware already let this request through,
-- so just continue (or loadstring the actual script from here if you chain it).
-- e.g.:
-- loadstring(game:HttpGet("https://perplexware.vercel.app/sniperarena.lua"))()
