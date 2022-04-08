#!/bin/env lua

local greeneReservation = { }

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log
local user_log = greeneUtils.user_log

local bigIntNumber = greeneUtils.bigIntNumber

local function memory_is_specified(mem)
   if mem == nil or mem > bigIntNumber then
      return false
   else
      return true
   end
end

local job_desc = nil

local function check_reservation_chung_is_OK()
   local res_name = "chung"
   slurm_log("Reservation: %s", res_name)
   
   if job_desc.reservation ~= res_name then return false end
   
   if job_desc.min_nodes ~= uint32_NO_VAL then
      if job_desc.min_nodes ~= 1 then
	 user_log("Reservation chung: please specify: --nodes=1")
	 return false
      end
   end
   
   if job_desc.time_limit > 240 then
      user_log("Reservation chung: time limit 240 mins")
      return false
   end

   --[[
   if job_desc.shared ~= 0 then
      user_log("Reservation: please specify: --exclusive")
      return false
   end
   --]]
   
   if job_desc.gres == nil then return false end
   
   if job_desc.gres ~= "gpu:rtx8000:4" then
      user_log("Reservation chung: --gres=gpu:rtx8000:4 only")
      return false
   end
   
   if memory_is_specified(job_desc.pn_min_memory) and job_desc.pn_min_memory > 360*1024 then
      user_log("Reservation chung: maximum memory for GPU only job is 360GB")
      return false
   end
   
   if job_desc.cpus_per_task ~= uint16_NO_VAL then
      if job_desc.cpus_per_task ~= 48 then
	 user_log("Reservation chung: --cpus-per-task=48")
	 return false
      end
   end
   
   return true
end

local function check_reservation_ece_gy_9431_is_OK()
  local res_name = "ece-gy-9431"
  slurm_log("Reservation: %s", res_name)
  
  if job_desc.reservation ~= res_name then return false end
  
  if job_desc.min_nodes ~= uint32_NO_VAL then
    if job_desc.min_nodes ~= 1 then
      user_log("Reservation %s: please specify: --nodes=1", res_name)
      return false
     end
  end
  
  if job_desc.time_limit > 20 then
    user_log("Reservation chung: time limit 20 mins")
    return false
  end

  if job_desc.gres == nil then return false end
  
  --[[
  if job_desc.gres ~= "gres:gpu:rtx8000:4" then
    user_log("Reservation %s: --gres=gpu:rtx8000:4 only", res_name)
    return false
  end
  --]]
  
  if memory_is_specified(job_desc.pn_min_memory) and job_desc.pn_min_memory > 360*1024 then
    user_log("Reservation %s: maximum memory for GPU only job is 360GB", res_name)
    return false
  end
  
  --[[
  if job_desc.cpus_per_task ~= uint16_NO_VAL then
    if job_desc.cpus_per_task ~= 48 then
      user_log("Reservation %s: --cpus-per-task=48", res_name)
      return false
     end
  end
  --]]
  
  return true
end

local function check_reservation_is_OK(job_desc_)

   job_desc = job_desc_

   if job_desc.reservation == "chung" then return check_reservation_chung_is_OK() end
   if job_desc.reservation == "ece-gy-9431" then return check_reservation_ece_gy_9431_is_OK() end

   return true
end

-- functions

greeneReservation.check_reservation_is_OK = check_reservation_is_OK

slurm_log("To load greeneReservation.lua")

return greeneReservation
