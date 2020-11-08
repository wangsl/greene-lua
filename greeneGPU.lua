#!/bin/env lua

local greeneGPU = { }

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log


local gpus = 0
local cpus = 0
local memory = 0
local gpu_type = nil
local time_limit = 0

local available_gpu_types = { "v100", "rtx8000" }

local partition_configures = {
   
   v100 = { gpu = "v100",
	    { gpus = 1, max_cpus = 20, max_memory = 100 },
	    { gpus = 2, max_cpus = 24, max_memory = 200 },
	    { gpus = 3, max_cpus = 44, max_memory = 300 },
	    { gpus = 4, max_cpus = 48, max_memory = 369 }
   },
   
   rtx8000 = { gpu = "rtx8000",
	       { gpus = 1, max_cpus = 20, max_memory = 100 },
	       { gpus = 2, max_cpus = 24, max_memory = 200 },
	       { gpus = 3, max_cpus = 44, max_memory = 300 },
	       { gpus = 4, max_cpus = 48, max_memory = 369 }
   }
}

local partitions = { "rtx8000", "v100" }

local function gpu_type_is_valid()
   if gpu_type == nil then return true end
   
   if greeneUtils.in_table(available_gpu_types, gpu_type) then
      return true
   else
      user_log("GPU type '%s' is invalid", gpu_type)
      return false
   end
end

local function number_of_cpus_is_ge_than_number_of_gpus()
   if cpus >= gpus then
      return true
   else
      user_log("GPU number %d is bigger than CPU number %d", gpus, cpus)
      return false
   end
end

local function fit_into_partition(part_name)
   local partition_conf = partition_configures[part_name]
   if partition_conf ~= nil then
      if gpu_type ~= nil and gpu_type ~= partition_conf.gpu then return false end

      if partition_conf.users ~= nil and not greeneUtils.in_table(partition_conf.users, greeneCommon.netid()) then
	 return false
      end
      
      if partition_conf.time_limit ~= nil and time_limit > partition_conf.time_limit then
	 return false
      end
      
      local conf = partition_conf[gpus]
      if conf ~= nil and cpus <= conf.max_cpus and memory <= conf.max_memory then
	 return true
      end
   end
   
   return false
end

local function valid_partitions()
   local partitions_ = nil
   for _, part_name in pairs(partitions) do
      if fit_into_partition(part_name) then
	 if partitions_ == nil then
	    partitions_ = part_name
	 else
	    partitions_ = partitions_ .. "," .. part_name
	 end
      end
   end
   return partitions_
end

local function setup_parameters(args)
   gpus = args.gpus 
   cpus = args.cpus 
   memory = args.memory
   gpu_type = args.gpu_type 
   time_limit = args.time_limit
end

-- functions
greeneGPU.setup_parameters = setup_parameters
greeneGPU.gpu_type_is_valid = gpu_type_is_valid
greeneGPU.valid_partitions = valid_partitions

slurm_log("To load greeneGPU.lua")

return greeneGPU


