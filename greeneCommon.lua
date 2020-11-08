#!/bin/env lua

local greeneCommon = { }

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log

local job_desc = nil

local gpu_type = nil
local gpus = 0

local function gres_for_gpu(gres)
   gpu_type = nil
   gpus = 0
   
   local tmp = greeneUtils.split(gres, ":")
   
   if tmp[1] == "gpu" then
      if #tmp > 3 then
	 gpus = 0
	 gpu_type = nil
      elseif #tmp == 3 then
	 gpu_type = tmp[2]
	 gpus = tmp[3]
      elseif #tmp == 2 then
	 if tmp[2]:match("^%d+$") then
	    gpus = tmp[2]
	    gpu_type = nil
	 else
	   gpus = 1
	   gpu_type = tmp[2]
	 end
      elseif #tmp == 1 then
	 gpus = 1
	 gpu_type = nil
      end
   else
      gpu_type = nil
      gpus = nil
      user_log("GPU gres '%s' error", gres)
   end

   if gpus ~= nil then gpus = tonumber(gpus) end
end

local function is_interactive_job()
   if job_desc.script == nil then
      return true
   else
      return false
   end
end

local function is_gpu_job()
   if gpus > 0 then
      return true
   else
      return false
   end
end

local function setup_parameters(args)
   job_desc = args.job_desc 
   if job_desc.gres ~= nil then
      gres_for_gpu(job_desc.gres)
      slurm_log('** gpu type: %s %d', gpu_type, gpus)
   end
end

-- data
greeneCommon.gpu_type = gpu_type
greeneCommon.gpus = gpus

-- functions

greeneCommon.setup_parameters = setup_parameters
greeneCommon.is_interactive_job = is_interactive_job
greeneCommon.is_gpu_job = is_gpu_job

slurm_log("To load greeneCommon.lua")

return greeneCommon


