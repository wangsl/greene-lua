#!/bin/env lua

local greeneUtils = { }

local uint16_NO_VAL = slurm.NO_VAL16 
local uint32_NO_VAL = slurm.NO_VAL
local uint64_NO_VAL = slurm.NO_VAL64

local bigIntNumber = 10240*slurm.NO_VAL

local six_hours = 360 -- six hours in mins
local twelve_hours = 720 -- 12 hours in mins
local two_days = 2880 -- in mins
local seven_days = 10080 -- in mins
local unlimited_time = 525600 -- one year in mins

-- local maintenance_mode = true
local maintenance_mode = false

local function mins_to_days(mins)
   return mins/60/24
end

local function hours_to_mins(h)
   return h*60
end

local function split(s, delimiter)
   local result = {}
   for match in (s..delimiter):gmatch("(.-)"..delimiter) do
      table.insert(result, match)
   end
   return result
end

local function in_table(tbl, item)
   for _, value in pairs(tbl) do
      if value == item then return true end
   end
   return false
end

local function insert_to_table_if_not_exist(tbl, item)
   if not in_table(tbl, item) then table.insert(tbl, item) end
end

local function is_empty(t)
   for _, _ in pairs(t) do return false end
   return true
end

local function slurm_log(s, ...)
   return io.write(s:format(...), "\n")
end

local function print_NO_VALs()
   slurm.log_info("uint16_NO_AVL: %d", uint16_NO_VAL)
   slurm.log_info("uint32_NO_AVL: %d", uint32_NO_VAL) 
   -- slurm.log_info("uint64_NO_AVL: %d", uint64_NO_VAL)
end

local function shallow_copy(original)
   local copy = {}
   for key, value in pairs(original) do
      copy[key] = value
   end
   return copy
end

local function deep_copy(original)
   local copy = {}
   for k, v in pairs(original) do
      if type(v) == "table" then
	 v = deep_copy(v)
      end
      copy[k] = v
   end
   return copy
end

-- functions

greeneUtils.split = split
greeneUtils.in_table = in_table
greeneUtils.insert_to_table_if_not_exist = insert_to_table_if_not_exist
greeneUtils.is_empty = is_empty
greeneUtils.shallow_copy = shallow_copy
greeneUtils.deep_copy = deep_copy

greeneUtils.mins_to_days = mins_to_days
greeneUtils.hours_to_mins = hours_to_mins
greeneUtils.n_intersection = n_intersection

-- data

greeneUtils.six_hours = six_hours
greeneUtils.twelve_hours  = twelve_hours
greeneUtils.two_days = two_days
greeneUtils.seven_days = seven_days
greeneUtils.unlimited_time = unlimited_time

greeneUtils.uint16_NO_VAL = uint16_NO_VAL
greeneUtils.uint32_NO_VAL = uint32_NO_VAL
greeneUtils.uint64_NO_VAL = uint64_NO_VAL
greeneUtils.bigIntNumber = bigIntNumber

-- greeneUtils.slurm_log = slurm_log
-- greeneUtils.user_log = slurm_log

greeneUtils.slurm_log = slurm.log_info
greeneUtils.user_log = slurm.log_user

greeneUtils.maintenance_mode = maintenance_mode

greeneUtils.print_NO_VALs = print_NO_VALs

greeneUtils.slurm_log("To load greeneUtils.lua")

return greeneUtils

