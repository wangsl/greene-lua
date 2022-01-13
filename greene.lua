#!/bin/env lua

local greene = { }

local greeneUtils = require "greeneUtils"
local greeneCommon = require "greeneCommon"
local greeneJob = require "greeneJob"
local time = require "time"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local function job_submission(job_desc, part_list, submit_uid)
   
   if greeneUtils.maintenance_mode then
      if job_desc.user_name ~= "wang" and job_desc.user_name ~= "sw77" and job_desc.user_name ~= "wd35" then
	 user_log("Greene is in maintenance now, job submission is disabled")
	 return slurm.ERROR
      end
   end

   local time_start = time.getMicroseconds()
   
   if greeneCommon.user_is_blocked(job_desc.user_name) then return slurm.ERROR end

   --if job_desc.script ~= nil then slurm_log("script:\n%s", job_desc.script) end

   greeneJob.setup_parameters{job_desc = job_desc}
   
   greeneJob.print_job_desc()
   
   if not greeneJob.setup_is_valid() then return slurm.ERROR end
   
   local time_end = time.getMicroseconds()

   slurm_log("Lua job submission plugin time %.0f usec for %s",
	    (time_end - time_start)*10^6, job_desc.user_name)

   return slurm.SUCCESS
end

-- only root is allowed to modify jobs

local function job_modification(job_desc, job_recd, part_list, modify_uid)
   if modify_uid == 0 then return slurm.SUCCESS end
   return slurm.ERROR
end

-- functions

greene.job_submission = job_submission
greene.job_modification = job_modification

slurm_log("To load greene.lua")

return greene



