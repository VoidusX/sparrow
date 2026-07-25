local M = {}

local badSyntax = {
    "os%.execute", "os%.remove", "os%.rename", "os%.tmpname", "os%.setlocale", "os%.setenv", "io%.open", "io%.popen", "io%.input", "io%.output", "io%.close", "debug%.", "package%.loadlib", "package%.loaded", "package%.path", "package%.cpath", "dofile", "loadfile", "loadstring", "load", "require", "pcall", "xpcall", "setfenv", "getfenv", "_ENV"
}

local function stripCommentsAndStrings(content)
    -- Remove multi-line comments: --[[ ... ]]
    content = content:gsub("--%[%[.-%]%]", "")
    -- Remove single-line comments: -- ...
    content = content:gsub("--[^\n]*", "")
    -- Remove double-quoted strings: "..." (handles basic escapes)
    content = content:gsub('"[^"\\]*(\\.[^"\\]*)*"', '""')
    -- Remove single-quoted strings: '...' (handles basic escapes)
    content = content:gsub("'[^'\\]*(\\.[^'\\]*)*'", "''")
    return content
end

local function read(filepath)
    local f, err = io.open(filepath, "r")
    if not f then
        print(err)
        return false, "read failure." end
    local content = f:read("*a")
    f:close()

    -- Create a sanitized version for security checking
    local code = stripCommentsAndStrings(content)

    for _, pattern in ipairs(badSyntax) do
        if code:match(pattern) then
            return false, "config contains bad syntax."
        end
    end
    if #content > 10240 then return false, "config too large." end
    return true, content
end

local function verify(val, visited)
    local t = type(val)
    if t == "number" or t == "string" or t == "boolean" then return true end
    if t ~= "table" then return false, "type error. allowed: string, boolean, number, table." end
    if visited[val] then return true end
    visited[val] = true
    for k, v in pairs(val) do
        if type(k) ~= "string" and type(k) ~= "number" then return false end
        local ok, _ = verify(v, visited)
        if not ok then return false end
    end
    return true
end

local function loadSparrowENV()
    local dotenv = io.open("/etc/sparrow/vars.env", "r")      -- standard distro file
    if not dotenv then return false end

    for l in dotenv:lines() do
        if not l:match("^%s*#") and not l:match("^%s*$") then -- exclude comments
            local k, v = l:match("^%s*([%w_]+)%s*=%s*(.*)$")  -- format: KEY=VALUE
            if k and v then
                v = v:gsub("^['\"](.-)['\"]$", "%1")          -- quote remover
                v = v:match("^(.-)%s*(#.*)?$") or v           -- whitespace trimming
                hl.env(k, v)
            end
        end
    end
    dotenv:close()
    return true
end

function M.loadSystemVariables()
    return loadSparrowENV()
end

function M.getSystemConfig()
    local path = "/etc/sparrow/config.lua"
    local safe, err = read(path)
    if not safe then
        print("{setup/sparrow}: Security check failed. " .. err)
        return nil
    end

    local func, err = loadfile(path)
    if not func then
        print("{setup/sparrow}: Config error. " .. err)
        return nil
    end

    local ok, result = pcall(func)
    if not ok or type(result) ~= "table" then
        return nil
    end

    if not verify(result, {}) then
        return nil
    end

    return result
end

return M
