#!/bin/env lua

local greeneAccount = { }

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

-- functions

slurm_log("To load greeneAccount.lua")

return greeneAccount


