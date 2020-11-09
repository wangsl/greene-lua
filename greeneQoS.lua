#!/bin/env lua

local greeneQoS = { }

local greeneUtils = require "greeneUtils"
local greeneSpecialUsers = require "greeneSpecialUsers"
local greeneCommon = require "greeneCommon"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local two_days = greeneUtils.two_days
local seven_days = greeneUtils.seven_days
local unlimited_time = greeneUtils.unlimited_time

local interative_time_limit = greeneUtils.hours_to_mins(4)

local time_limit = 0

local qos_interact_name = "interact"

local QoSs = { qos_interact_name,
	       "cpuplus", "cpu48", "cpu168",
	       "gpuplus", "gpu48", "gpu168" }
	       
local qos_configurations = {

   interact = { cpu = true, gpu = true,
		time_min = 0, time_max = interative_time_limit },
   
   cpu48 = { cpu = true, gpu = false,
	     time_min = 0, time_max = two_days },
   cpu168 = { cpu = true, gpu = false,
	      time_min = two_days, time_max = seven_days },
   
   gpu48 = { cpu = false, gpu = true,
	     time_min = 0, time_max = two_days },
   gpu168 = { cpu = false, gpu = true,
	      time_min = two_days, time_max = seven_days },
   
   -- special QoS with user access control
   
   cpuplus = { cpu = true, gpu = false,
	       time_min = 0, time_max = seven_days,
	       users = greeneSpecialUsers.cpuplus_users },
   gpuplus = { cpu = false, gpu = true,
	       time_min = 0, time_max = seven_days,
	       users = greeneSpecialUsers.gpuplus_users },
   
   --[[
      cpu365 = { time_min = seven_days, time_max = unlimited_time,
      users = princeStakeholders.users_with_unlimited_wall_time
   }
   --]]
}

-- this function is to choose QoS

local function fit_into_qos(qos_name)
   
   local qos = qos_configurations[qos_name]
   
   if qos == nil then return false end
   
   local cpu = nil
   local gpu = nil
   
   if(greeneCommon.is_interactive_job() and time_limit <= interative_time_limit) then
      cpu = true
      gpu = true
   elseif(greeneCommon.is_gpu_job()) then
      cpu = false
      gpu = true
   else
      cpu = true
      gpu = false
   end
   
   if (qos.users ~= nil and greeneUtils.in_table(qos.users, greeneCommon.netid())) or qos.users == nil then
      if cpu == qos.cpu and
	 gpu == qos.gpu and
	 time_limit > qos.time_min and
         time_limit <= qos.time_max then
	 return true
      end
   end
	 
   return false
end

-- this function is to validate QoS

local function fit_into_qos_2(qos_name)

   if qos_name == qos_interact_name then
      if fit_into_qos(qos_name) then return true end
   end
   
   local qos = qos_configurations[qos_name]
   local cpu = nil
   local gpu = nil
   
   if(greeneCommon.is_gpu_job()) then
      cpu = false
      gpu = true
   else
      cpu = true
      gpu = false
   end

   if (qos.users ~= nil and greeneUtils.in_table(qos.users, greeneCommon.netid())) or qos.users == nil then
      if cpu == qos.cpu and
	 gpu == qos.gpu and
	 time_limit > qos.time_min and
         time_limit <= qos.time_max then
	 return true
      end
   end
	 
   return false
end  

local function valid_qos()
   for _, qos_name in pairs(QoSs) do
      if fit_into_qos(qos_name) then
	 return qos_name
      end
   end
   return nil
end

local function qos_is_valid()
   local qos = greeneCommon.job_desc.qos
   if qos == nil then
      user_log("*** Error no proper QoS fit this job")
      return false
   end

   if not greeneUtils.in_table(QoSs, qos) then
      user_log("*** Error '%s' is not a valid QoS on Greene", qos)
      return false
   end

   if not fit_into_qos_2(qos) then
      user_log("*** Error QoS '%s' does not fit this job", qos)
      return false
   end
   
   return true
end

local function setup_parameters(args)
   time_limit = args.time_limit 
end

-- functions
greeneQoS.setup_parameters = setup_parameters
greeneQoS.valid_qos = valid_qos
greeneQoS.qos_is_valid = qos_is_valid

slurm_log("To load greeneQoS.lua")

return greeneQoS

--[[
   To reimplement qos_is_valid in a more smart way
--]]


