#!/bin/env lua

local greeneUsers = {}

local greeneUtils = require "greeneUtils"
local greeneSpecialUsers = require "greeneSpecialUsers"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local users = { }
users["0"] = "root"
users["10015"] = "wang"

local blocked_netids = greeneSpecialUsers.blocked_netids

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

local function netid_is_blocked(uid)
   if not uid_is_valid(uid) then return true end
   if #blocked_netids > 0 and greeneUtils.in_table(blocked_netids, netid) then
      slurm_log("user %s is blocked to submit jobs", netid)
      user_log("Sorry, you are not allowed to submit jobs now, please contact hpc@nyu.edu for help")
      return true
   end
   return false
end

local function nyu_netid()
   return netid
end

-- functions

greeneUsers.nyu_netid = nyu_netid
greeneUsers.netid_is_blocked = netid_is_blocked

slurm_log("To load greeneUsers.lua")

return greeneUsers

