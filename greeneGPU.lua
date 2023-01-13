#!/bin/env lua

local greeneGPU = { }

local greeneUtils = require "greeneUtils"
local greeneCommon = require "greeneCommon"
local greeneSpecialUsers = require "greeneSpecialUsers"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local gpus = 0
local cpus = 0
local memory = 0
local gpu_type = nil
local time_limit = 0

local available_gpu_types = { "v100", "rtx8000", "a100", "mi50" }

-- this is the order to assign partitions
local partitions = { 
  "cds_rtx_d", "cds_rtx_a", "cds_dgx_d",
  "cilvr_a100_1", 
  "cds_a100_2", 
  "chemistry_a100_2", 
  "tandon_a100_2", "tandon_a100_1",
  "stake_a100_2", "stake_a100_1",
  "rtx8000", "v100", "a100_2", "a100_1", "gpu_misc_v100", 
  "mi50" 
}

local account_to_partitions = {
  cds = { "cds_rtx_d", "cds_dgx_d", "cds_rtx_a", "v100" }
}

local qos_to_partitions = {
  cds = { "cds_rtx_d", "cds_dgx_d" }
}

local gpu_configurations = {
   
  v100 = { gpu = "v100",
    { gpus = 1, max_cpus = 20, max_memory = 200 },
    { gpus = 2, max_cpus = 24, max_memory = 300 },
    { gpus = 3, max_cpus = 44, max_memory = 350 },
    { gpus = 4, max_cpus = 48, max_memory = 369 }
  },
  
  rtx8000 = { gpu = "rtx8000",
    { gpus = 1, max_cpus = 20, max_memory = 200 },
    { gpus = 2, max_cpus = 24, max_memory = 300 },
    { gpus = 3, max_cpus = 44, max_memory = 350 },
    { gpus = 4, max_cpus = 48, max_memory = 369 }
  },
   
  mi50 = {
    gpu = "mi50",
    require_gpu_type = true,
    { gpus = 1, max_cpus = 48, max_memory = 200 },
    { gpus = 2, max_cpus = 72, max_memory = 300 },
    { gpus = 3, max_cpus = 76, max_memory = 350 },
    { gpus = 4, max_cpus = 80, max_memory = 370 },
    { gpus = 5, max_cpus = 84, max_memory = 400 },
    { gpus = 6, max_cpus = 88, max_memory = 430 },
    { gpus = 7, max_cpus = 92, max_memory = 460 },
    { gpus = 8, max_cpus = 96, max_memory = 490 }
  },

  gpu_misc_v100 = { gpu = "v100",
    { gpus = 1, max_cpus = 10, max_memory = 200 },
    { gpus = 2, max_cpus = 12, max_memory = 300 },
    { gpus = 3, max_cpus = 15, max_memory = 350 },
    { gpus = 4, max_cpus = 20, max_memory = 369 }
  },

  dgx1 = { gpu = "v100",
    { gpus = 1, max_cpus = 10,  max_memory = 250 },
    { gpus = 2, max_cpus = 15,  max_memory = 300 },
    { gpus = 3, max_cpus = 18,  max_memory = 350 },
    { gpus = 4, max_cpus = 20,  max_memory = 400 },
    { gpus = 5, max_cpus = 30,  max_memory = 425 },
    { gpus = 6, max_cpus = 35,  max_memory = 450 },
    { gpus = 7, max_cpus = 38,  max_memory = 475 },
    { gpus = 8, max_cpus = 40,  max_memory = 500 },
  },

  a100 = { gpu = "a100",
    { gpus = 1, max_cpus = 28, max_memory = 250 },
    { gpus = 2, max_cpus = 32, max_memory = 300 },
    { gpus = 3, max_cpus = 60, max_memory = 400 },
    { gpus = 4, max_cpus = 64, max_memory = 500 }
  },

  a100_1 = { gpu = "a100",
    { gpus = 1, max_cpus = 28, max_memory = 250 },
    { gpus = 2, max_cpus = 32, max_memory = 300 },
    { gpus = 3, max_cpus = 60, max_memory = 400 },
    { gpus = 4, max_cpus = 64, max_memory = 500 }
  },

  a100_2 = { gpu = "a100",
    { gpus = 1, max_cpus = 28, max_memory = 250 },
    { gpus = 2, max_cpus = 32, max_memory = 300 },
    { gpus = 3, max_cpus = 60, max_memory = 400 },
    { gpus = 4, max_cpus = 64, max_memory = 500 }
  },

  --[[
  mig = { 
    require_gpu_type = true,
    gpu = "1g.10gb",
    { gpus = 1, max_cpus = 8, max_memory = 64 }
  }
  ]]
}

local partition_configurations = {
   
  v100 = greeneUtils.shallow_copy(gpu_configurations.v100),
  rtx8000 = greeneUtils.shallow_copy(gpu_configurations.rtx8000),
  --a100 = greeneUtils.shallow_copy(gpu_configurations.a100),
  
  cds_rtx_d = greeneUtils.shallow_copy(gpu_configurations.rtx8000),
  cds_rtx_a = greeneUtils.shallow_copy(gpu_configurations.rtx8000),
  cds_dgx_d = greeneUtils.shallow_copy(gpu_configurations.dgx1),

  -- cilvr_a100 = greeneUtils.shallow_copy(gpu_configurations.a100_1),
  cilvr_a100_1 = greeneUtils.shallow_copy(gpu_configurations.a100_1),
  tandon_a100_1 = greeneUtils.shallow_copy(gpu_configurations.a100_1),
  stake_a100_1 = greeneUtils.shallow_copy(gpu_configurations.a100_1),
  a100_1 = greeneUtils.shallow_copy(gpu_configurations.a100_1),
  
  cds_a100_2 = greeneUtils.shallow_copy(gpu_configurations.a100_2),
  tandon_a100_2 = greeneUtils.shallow_copy(gpu_configurations.a100_2),
  chemistry_a100_2 = greeneUtils.shallow_copy(gpu_configurations.a100_2),
  stake_a100_2 = greeneUtils.shallow_copy(gpu_configurations.a100_2),  
  a100_2 = greeneUtils.shallow_copy(gpu_configurations.a100_2),

  mi50 = greeneUtils.shallow_copy(gpu_configurations.mi50),
  gpu_misc_v100 = greeneUtils.shallow_copy(gpu_configurations.gpu_misc_v100),
   -- mig = greeneUtils.shallow_copy(gpu_configurations.mig)
}

-- partition_configurations.cds_rtx_d.account = "cds"
-- partition_configurations.cds_rtx_a.account = "cds"
-- partition_configurations.cds_dgx_d.account = "cds"

-- partition_configurations.a100.users = greeneSpecialUsers.a100_alpha_test_users
partition_configurations.cds_rtx_d.users = greeneSpecialUsers.cds_users;
partition_configurations.cds_rtx_a.users = greeneSpecialUsers.cds_users;
partition_configurations.cds_dgx_d.users = greeneSpecialUsers.cds_users;

-- partition_configurations.cilvr_a100.users = greeneSpecialUsers.cilvr_a100_users;
partition_configurations.cilvr_a100_1.users = greeneSpecialUsers.cilvr_a100_users;
partition_configurations.tandon_a100_1.users = greeneSpecialUsers.tandon_a100_2_users;
partition_configurations.stake_a100_1.users = greeneSpecialUsers.stakeholders_a100_users;

partition_configurations.cds_a100_2.users = greeneSpecialUsers.cds_users;
partition_configurations.tandon_a100_2.users = greeneSpecialUsers.tandon_a100_2_users;
partition_configurations.chemistry_a100_2.users = greeneSpecialUsers.chemistry_a100_2_users;
partition_configurations.stake_a100_2.users = greeneSpecialUsers.stakeholders_a100_users;

local function candidate_partitions()
   
  local partitions_ = nil

  local account_partitions = nil
  if greeneCommon.account() ~= nil and account_to_partitions[greeneCommon.account()] ~= nil then
    account_partitions = account_to_partitions[greeneCommon.account()]
  end
   
  local qos_partitions = nil
  if greeneCommon.qos() ~= nil and qos_to_partitions[greeneCommon.qos()] ~= nil then
    qos_partitions = qos_to_partitions[greeneCommon.qos()]
  end

  if qos_partitions ~= nil then
    partitions_ = qos_partitions
  elseif account_partitions ~= nil then
    partitions_ = account_partitions
  else
    partitions_ = partitions
  end

  return partitions_
end

local function fit_into_partition_based_on_account_and_qos(part_name)

  if greeneCommon.account() ~= nil and account_to_partitions[greeneCommon.account()] ~= nil then
    local account_partitions = account_to_partitions[greeneCommon.account()]
    if not greeneUtils.in_table(account_partitions, part_name) then return false end
  end

  if greeneCommon.qos() ~= nil and qos_to_partitions[greeneCommon.qos()] ~= nil then
    local qos_partitions = qos_to_partitions[greeneCommon.qos()]
    if not greeneUtils.in_table(qos_partitions, part_name) then return false end
  end

  return true
end

local function gpu_type_is_valid()
  if gpu_type == nil then return true end
  
  if greeneUtils.in_table(available_gpu_types, gpu_type) then
    return true
  else
    user_log("*** Error: GPU type '%s' is invalid", gpu_type)
    return false
  end
end

local function number_of_cpus_is_ge_than_number_of_gpus()
  if cpus >= gpus then
    return true
  else
    user_log("*** Error: GPU number %d is bigger than CPU number %d", gpus, cpus)
    return false
  end
end

local function fit_into_partition(part_name)

  if not fit_into_partition_based_on_account_and_qos(part_name) then return false end
  
  local partition_conf = partition_configurations[part_name]

  if partition_conf == nil then return false end

  if partition_conf.require_gpu_type and gpu_type ~= partition_conf.gpu then return false end
  
  if gpu_type ~= nil and gpu_type ~= partition_conf.gpu then return false end

  if partition_conf.users ~= nil and not greeneUtils.in_table(partition_conf.users, greeneCommon.netid()) then
  return false
  end
   
  if partition_conf.time_limit ~= nil and time_limit > partition_conf.time_limit then return false end

  if partition_conf.account ~= nil and partition_conf.account ~= greeneCommon.account() then return false end

  local conf = partition_conf[gpus]
  if conf ~= nil and cpus <= conf.max_cpus and memory <= conf.max_memory then return true end

  return false
end

local function valid_partitions()
  local partitions_ = nil
  --for _, part_name in pairs(partitions) do
  for _, part_name in pairs(candidate_partitions()) do
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

  if greeneCommon.job_desc.partition == nil then return false end
  
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
   if not gpu_type_is_valid() then return false end
   if not number_of_cpus_is_ge_than_number_of_gpus() then return false end
   if not partitions_are_valid() then return false end

   --[[
   if greeneCommon.job_desc.bitflags ~= slurm.GRES_ENFORCE_BIND then
      user_log("*** Error bitflags %d is not %d", greeneCommon.job_desc.bitflags, slurm.GRES_ENFORCE_BIND)
   end
   --]]
   
   return true
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
greeneGPU.valid_partitions = valid_partitions
greeneGPU.setup_is_valid = setup_is_valid

slurm_log("To load greeneGPU.lua")

return greeneGPU

--[[
To do list

job_desc.bitflags to bind CPUs and GPUs

--]]
