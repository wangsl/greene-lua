#!/bin/env lua

local greeneSpecialUsers = {}

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log

local blocked_netids = { }

-- data

greeneSpecialUsers.blocked_netids = blocked_netids

slurm_log("To load greeneSpeicalUsers.lua")

return greeneSpecialUsers
