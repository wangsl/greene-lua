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

local interactive_time_limit = greeneUtils.hours_to_mins(4)

local time_limit = 0

local QoSs = { "interact",
	       "cpuplus", "cpu48", "cpu168",
	       "gpuplus", "gpu48", "gpu168" }

local qos_configurations = {

   interact = { interactive = true, time_min = 0, time_max = interactive_time_limit,
		max_cpus = 48, max_gpus = 4 },
   
   cpu48 = { gpu = false, time_min = 0, time_max = two_days },
   cpu168 = { gpu = false, time_min = two_days, time_max = seven_days },
   
   gpu48 = { gpu = true, time_min = 0, time_max = two_days },
   gpu168 = { gpu = true, time_min = two_days, time_max = seven_days },
   
   -- special QoS with user access control
   
   cpuplus = { gpu = false, time_min = 0, time_max = seven_days,
	       users = greeneSpecialUsers.cpuplus_users },

   gpuplus = { gpu = true,
	       time_min = 0, time_max = seven_days,
	       users = greeneSpecialUsers.gpuplus_users },
   --[[
      cpu365 = { time_min = seven_days, time_max = unlimited_time,
      users = princeStakeholders.users_with_unlimited_wall_time
   }
   --]]
}

local function fit_into_qos(qos_name)
   
   local qos = qos_configurations[qos_name]

   if qos == nil then return false end

   if qos.interactive ~= nil and qos.interactive ~= greeneCommon.is_interactive_job() then return false end

   if qos.max_cpus ~= nil then
      local n_cpus, n_gpus = greeneCommon.total_cpus_and_gpus()
      if n_cpus > qos.max_cpus then return false end
      if n_gpus > qos.max_gpus then return false end
   end
   
   if qos.gpu ~= nil and qos.gpu ~= greeneCommon.is_gpu_job() then return false end

   if (qos.users ~= nil and greeneUtils.in_table(qos.users, greeneCommon.netid())) or qos.users == nil then
      if time_limit > qos.time_min and time_limit <= qos.time_max then return true end
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

   if not fit_into_qos(qos) then
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


