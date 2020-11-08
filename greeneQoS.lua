#!/bin/env lua

local greeneQoS = { }

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local two_days = greeneUtils.two_days
local seven_days = greeneUtils.seven_days
local unlimited_time = greeneUtils.unlimited_time

local time_limit = 0

local qos_configurations = {
   
   cpu48 = { time_min = 0, time_max = two_days },
   cpu168 = { time_min = two_days, time_max = seven_days },

   gpu48 = { time_min = 0, time_max = two_days },
   gpu168 = { time_min = two_days, time_max = seven_days },
   
   -- special QoS with user access control
   
   cpuplus = { time_min = 0, time_max = seven_days,
	       users = { "sw77", "wang" } 
   },
   
   gpuplus = { time_min = 0, time_max = seven_days,
	       users = { "sw77", "wang" }
   },
   
   cpu365 = { time_min = seven_days, time_max = unlimited_time,
	      users = princeStakeholders.users_with_unlimited_wall_time
   }


}

local function setup_parameters(args)
   time_limit = args.time_limit 
end

-- functions

greeneQoS.setup_parameters = setup_parameters

slurm_log("To load greeneQoS.lua")

return greeneQoS




