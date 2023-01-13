#!/bin/env lua

local greenePkgs = { }

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local greene_pkgs_last_modification_time = { }

local function unload_new_updated_packages()
  local prefix = "/share/apps/admins/slurm-lua/"
  local pkgs = {
    "job_submit.lua",
    "greene.lua",
    "greeneUtils.lua",
    "greenePkgs.lua",
    "greeneUsers.lua",
    "greeneSpecialUsers.lua",
    "greeneJob.lua",
    "greeneCPU.lua",
    "greeneGPU.lua",
    "greeneQoS.lua",
    "greeneAccount.lua",
    "greeneReservation.lua",
    "greeneCommon.lua"
  }
   
  local has_new_updated = false
  
  for _, pkg in pairs(pkgs) do
    local lua_file = prefix .. pkg
    local f = io.popen("stat -c %Y " .. lua_file)
    local last_modified = f:read()
    f:close()
    
    if greene_pkgs_last_modification_time[pkg] == nil then
      greene_pkgs_last_modification_time[pkg] = last_modified
    else
      if greene_pkgs_last_modification_time[pkg] < last_modified then
        has_new_updated = true
        greene_pkgs_last_modification_time[pkg] = last_modified
        slurm.log_info("%s has new update", lua_file)
      end
    end
  end

   -- to reload all the LUA packages, dependency issue
   if has_new_updated then
    for _, pkg in pairs(pkgs) do
      local pkg_ = string.gsub(pkg, ".lua$", "")
      package.loaded[pkg_] = nil
    end
   end
end

-- functions

greenePkgs.unload_new_updated_packages = unload_new_updated_packages

slurm_log("To load greenePkgs.lua")

return greenePkgs

