local config            = require "config"
local g                 = require "lib.g"
local redis             = require "lib.redis"
local mysql             = require "lib.mysql"

local header = ngx.req.get_headers()
local device_no = header.deviceno

if(device_no == nil)
then
	g.log("empty device_no")
	return
end

local redis = redis:new(config:get("redis"))
local key = "lua|device_no|api_path"
local path = redis:hget(key, device_no)

if(path == 'default')
then
	return
end

if not g.empty(path)
then
	ngx.var.branch = path
	return path
end

redis:hset(key, device_no, 'default')

local db_config = config:get("mysql")
local db_base_config = db_config.db_base
local db_base = mysql:new(db_base_config)

--通过设备号获取门店ID
local sql = "select store_id from wt_device where device_no=:device_no"
local bind = {
	device_no = device_no
}
local device_info = db_base:findOne(sql, bind)

if g.empty(device_info)
then
	g.log("empty device_info")
	return
end

if g.empty(device_info.store_id)
then
	g.log("empty device_info.store_id")
	return
end

--通过门店ID获取路径配置
local sql = "select path_name from wt_store_config where store_id=:store_id"
local bind = {
	store_id = device_info.store_id
}
local store_config = db_base:findOne(sql, bind)

if g.empty(store_config)
then
	g.log("empty store_config")
	return
end

if g.empty(store_config.path_name)
then
	g.log("empty store_config.path_name")
	return
end

local result = redis:hset(key, device_no, store_config.path_name)

ngx.var.branch = store_config.path_name
return