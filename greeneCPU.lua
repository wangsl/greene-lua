#!/bin/env lua

local greeneCPU = { }

local greeneUtils = require "greeneUtils"
local greeneCommon = require "greeneCommon"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local cpus = 0
local memory = 0
local nodes = 0
local time_limit = greeneUtils.unlimited_time

local ave_memory = 0

-- this is the order to assign partitions
local partitions = { "cs", "cm", "cpu_gpu", "cl" }

local partition_configurations = {

   cs =  { min_cpus = 1, max_cpus = 48,
	   max_nodes = 524,
	   min_memory = 0, max_memory = 180,
	   min_ave_memory = 0, max_ave_memory = 15 
   },
   
   cm =  { min_cpus = 1, max_cpus = 48,
	   max_nodes = 40,
	   min_memory = 0, max_memory = 369,
	   min_ave_memory = 0, max_ave_memory = 100
   },
   
   cl =  { min_cpus = 1, max_cpus = 96,
	   max_nodes = 4,
	   min_memory = 50, max_memory = 3014,
	   min_ave_memory = 0, max_ave_memory = 3014
   },

   cpu_gpu =  { min_cpus = 1, max_cpus = 20,
		max_nodes = 2,
		min_memory = 0, max_memory = 180,
		min_ave_memory = 0, max_ave_memory = 180,
		time_limit = greeneUtils.hours_to_mins(5)
   }
}

local single_partition_configurations = {
   
   cs =  { min_cpus = 48, max_cpus = 48,
	   max_nodes = 524,
	   min_memory = 0, max_memory = 180
   }
}

local function fit_into_single_partition(part_name)
   local partition_conf = single_partition_configurations[part_name]

   if partition_conf == nil then return false end

   if nodes <= partition_conf.max_nodes and
      cpus == partition_conf.min_cpus and
      cpus == partition_conf.max_cpus and
      memory >= partition_conf.min_memory and
      memory <= partition_conf.max_memory then
	 return true
   end
   
   return false
end

local function fit_into_partition(part_name)
   local partition_conf = partition_configurations[part_name]
   if partition_conf == nil then return false end

   if partition_conf.time_limit ~= nil and time_limit > partition_conf.time_limit then
	 return false
   end
   
   if nodes <= partition_conf.max_nodes and
      cpus >= partition_conf.min_cpus and
      cpus <= partition_conf.max_cpus and
      memory >= partition_conf.min_memory and
      memory <= partition_conf.max_memory and
      ave_memory >= partition_conf.min_ave_memory and 
      ave_memory <= partition_conf.max_ave_memory then
	 return true
   end
   return false
end

local function valid_partitions()
   local partitions_ = nil
   for _, part_name in pairs(partitions) do

      if fit_into_single_partition(part_name) then
	 return part_name
      end
      
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

local function partitions_are_valid()
   local partitions = greeneUtils.split(greeneCommon.job_desc.partition, ",")
   local part_name = nil
   for _, part_name in pairs(partitions) do
      if not fit_into_partition(part_name) then
	 user_log("*** Error partition '%s' is not valid for this job", part_name)
	 return false
      end
   end
   return true
end

local function setup_is_valid()
   if not partitions_are_valid() then return false end
   return true
end

local function setup_parameters(args)
   cpus = args.cpus
   memory = args.memory
   nodes = args.nodes
   time_limit = args.time_limit
   
   ave_memory = memory/cpus
end

-- functions
greeneCPU.setup_parameters = setup_parameters
greeneCPU.valid_partitions = valid_partitions
greeneCPU.setup_is_valid = setup_is_valid

slurm_log("To load greeneCPU.lua")

return greeneCPU

--[[
To do list

job_desc.shared == 0
For exclusive access, when max_memory < 180GB, cs partition only

... to append partitions

--]]
