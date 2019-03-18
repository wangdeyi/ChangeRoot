--[[
config module example

@author kim https://github.com/xqpmjh
--]]

local pairs                 = pairs
local type                  = type
local setmetatable          = setmetatable
local print                 = ngx.print

--[[ init module --]]
module(...)
_VERSION = '1.0.0'

--[[ indexed by current module env. --]]
local mt = {__index = _M}

--[[-------------------------------------------------------------------------]]

local tbConfig = {
    mysql = {
        db_base = {
            host = "localhost",
            port = 3306,
            database = "test",
            user = "www",
            password = "123456",
            charset = "utf8",
            fname = "base"
        }
    },

    redis = {
        host = "localhost", port = 6379, password="123456", connect_timeout = 3000
    }

}

--[[
instantiation
@return table
]]
function new(self, debug)
    if debug and type(debug) == 'table' then
        for k,v in pairs(debug) do
            tbConfig[k] = v
        end
    end
    return setmetatable({}, mt)
end

--[[
get config
@param string key
@return table
]]
function get(self, key)
    if key then
        if tbConfig[key] then
            return tbConfig[key]
        else
            return {}
        end
    end
    return tbConfig
end


