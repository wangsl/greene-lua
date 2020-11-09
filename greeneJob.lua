#!/bin/env lua

local greeneJob = { }

local greeneUtils = require "greeneUtils"
local greeneCommon = require "greeneCommon"
local greeneCPU = require "greeneCPU"
local greeneGPU = require "greeneGPU"
local greeneQoS = require "greeneQoS"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

-- constants

local uint16_NO_VAL = greeneUtils.uint16_NO_VAL
local uint32_NO_VAL = greeneUtils.uint32_NO_VAL
local uint64_NO_VAL = greeneUtils.uint64_NO_VAL

local bigIntNumber = greeneUtils.bigIntNumber

local job_desc = nil
local n_cpus_per_node = nil

local function memory_is_specified(mem)
   if mem == nil or mem > bigIntNumber then
      return false
   else
      return true
   end
end

local function setup_parameters(args)
   job_desc = args.job_desc 
   setup_default_compute_resources()
   greeneCommon.setup_parameters{job_desc = job_desc}

   -- GPU job
   if greeneCommon.is_gpu_job() then

      greeneGPU.setup_parameters{ gpus = greeneCommon.gpus,
				  cpus = n_cpus_per_node,
				  memory = job_desc.pn_min_memory/1024.0,
				  time_limit = job_desc.time_limit,
				  gpu_type = greeneCommon.gpu_type }
      
      -- if job_desc.bitflags == 0 then job_desc.bitflags = slurm.GRES_ENFORCE_BIND end
      
      if job_desc.partition == nil then
	 local partitions = greeneGPU.valid_partitions()
	 if partitions ~= nil then job_desc.partition = partitions end
      end
      
   else -- CPU only jobs
      greeneCPU.setup_parameters{ cpus = n_cpus_per_node,
				  memory = job_desc.pn_min_memory/1024.0,
				  nodes = job_desc.min_nodes,
				  time_limit = job_desc.time_limit }
      
      if job_desc.partition == nil then
	 local partitions = greeneCPU.valid_partitions()
	 if partitions ~= nil then job_desc.partition = partitions end
      end
   end

   greeneQoS.setup_parameters{ time_limit = job_desc.time_limit }
   if job_desc.qos == nil then
      local qos = greeneQoS.valid_qos()
      if qos ~= nil then job_desc.qos = qos end
   end
end

local function setup_is_valid()
   if greeneCommon.is_gpu_job() then
      if not greeneGPU.setup_is_valid() then return false end
   else
      if not greeneCPU.setup_is_valid() then return false end
   end

   if not greeneQoS.qos_is_valid() then return false end
   
   return true
end

local function print_job_desc()
   
   slurm_log(" === Print job desc ===")

   --greeneUtils.print_NO_VALs()

   slurm_log("time_limit = %d", job_desc.time_limit)
   slurm_log("ntasks_per_node: %d", job_desc.ntasks_per_node)
   slurm_log("ntasks_per_socket: %d", job_desc.ntasks_per_socket)
   slurm_log("num_tasks = %d", job_desc.num_tasks)
   slurm_log("pn_min_cpus: %d", job_desc.pn_min_cpus)
   slurm_log("pn_min_memory: %d", job_desc.pn_min_memory)
   slurm_log("cpus_per_task: %d", job_desc.cpus_per_task)

   slurm_log("min_nodes: %d", job_desc.min_nodes)
   slurm_log("max_nodes: %d", job_desc.max_nodes)

   if memory_is_specified(job_desc.min_mem_per_cpu) then
      slurm_log("min_mem_per_cpu: %d", job_desc.min_mem_per_cpu)
   end
   
   slurm_log("requeue: %d", job_desc.requeue)

   if job_desc.account ~= nil then slurm_log("account: %s", job_desc.account) end
   
   if job_desc.qos ~= nil then slurm_log("qos: %s", job_desc.qos) end
   
   if job_desc.mail_user ~= nil then slurm_log("mail_user: %s", job_desc.mail_user) end
   
   if job_desc.partition ~= nil then slurm_log("partitions: %s", job_desc.partition) end
   
   if job_desc.gres ~= nil then slurm_log("gres: %s", job_desc.gres) end
   if job_desc.gres_bind ~= nil then slurm_log("gres_bind: %s", job_desc.gres_bind) end

   if job_desc.features ~= nil then slurm_log("features: %s", job_desc.features) end

   if job_desc.default_account ~= nil then slurm_log("default_account: %s", job_desc.default_account) end

   if job_desc.script ~= nil then
      slurm_log("script:\n%s", job_desc.script)
   else
      slurm_log("no script, interactive job")
   end
   
   if job_desc.argc > 0 then
      slurm_log("argc: %d", job_desc.argc)
      local argv = job_desc.argv[0]
      for i = 1, (job_desc.argc - 1) do
	 argv = argv .. " " .. job_desc.argv[i]
      end
      slurm_log("sbatch script with arguments: %s", argv)
   end

   if job_desc.work_dir ~= nil then slurm_log("work dir: %s", job_desc.work_dir) end

   return
end

function setup_default_compute_resources()

   if job_desc.mail_type ~= 0 and job_desc.mail_user == nil then
      local netid = job_desc.user_name
      if string.find(netid, "^%a+%d+$") then
	 job_desc.mail_user = netid .. "@nyu.edu"
      end
   end
   
   if job_desc.time_limit == uint32_NO_VAL then job_desc.time_limit = 60 end
   
   if job_desc.cpus_per_task == uint16_NO_VAL then job_desc.cpus_per_task = 1 end
   
   if job_desc.pn_min_cpus == uint16_NO_VAL then job_desc.pn_min_cpus = 1 end
   
   if job_desc.ntasks_per_node == uint16_NO_VAL then job_desc.ntasks_per_node = 1 end
   
   n_cpus_per_node = job_desc.ntasks_per_node * job_desc.cpus_per_task
   
   if job_desc.min_nodes == uint32_NO_VAL then job_desc.min_nodes = 1 end

   if job_desc.requeue ~= 1 then job_desc.requeue = 0 end
   
   if not memory_is_specified(job_desc.pn_min_memory) then
      if memory_is_specified(job_desc.min_mem_per_cpu) then
	 job_desc.pn_min_memory = job_desc.min_mem_per_cpu
      else
	 job_desc.pn_min_memory = 2048
      end
   end
end

-- data

-- functions
greeneJob.setup_parameters = setup_parameters
greeneJob.print_job_desc = print_job_desc
greeneJob.setup_is_valid = setup_is_valid

slurm_log("To load greeneJob.lua")

return greeneJob

