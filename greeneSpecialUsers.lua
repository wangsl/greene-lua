#!/bin/env lua

local greeneSpecialUsers = {}

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log

-- data

greeneSpecialUsers.blocked_users = { }

greeneSpecialUsers.cpuplus_users = { } --"wang", "sw77", "zp2137"
 
greeneSpecialUsers.gpuplus_users = { }

slurm_log("To load greeneSpeicalUsers.lua")

return greeneSpecialUsers
