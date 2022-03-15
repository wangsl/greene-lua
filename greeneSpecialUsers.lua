#!/bin/env lua

local greeneSpecialUsers = {}

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log

-- data

greeneSpecialUsers.blocked_users = { }

greeneSpecialUsers.cpuplus_users = { } --"wang", "sw77", "zp2137"
 
greeneSpecialUsers.gpuplus_users = { }

greeneSpecialUsers.cns_wang_users = { "vg44", "yl4317", "kb3856", "ab9710", "xd432" }

slurm_log("To load greeneSpeicalUsers.lua")

return greeneSpecialUsers
