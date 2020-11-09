#!/bin/env lua

local greeneReservation = { }

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

-- functions

slurm_log("To load greeneReservation.lua")

return greeneReservation


