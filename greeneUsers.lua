#!/bin/env lua

local greeneUsers = {}

local greeneUtils = require "greeneUtils"
local greeneSpecialUsers = require "greeneSpecialUsers"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local users = { }
users["0"] = "root"
users["10015"] = "wang"

local netid = nil

local function uid_to_netid(uid)
   local uid = string.format("%d", uid)
   netid = users[uid]
   if netid == nil then
      print("To run: id -nu " .. uid)
      local out = io.popen("id -nu " .. uid)
      netid = out:read()
      out.close()
      users[uid] = netid
   end
end

local function uid_is_valid(uid)
   uid_to_netid(uid)
   if netid == nil then
      user_log("uid %d is not valid to run jobs", uid)
      return false
   end
   return true
end

-- functions

slurm_log("To load greeneUsers.lua")

return greeneUsers

--[[
   to check CGSB users
--]]
