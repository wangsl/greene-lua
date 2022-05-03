#!/bin/env lua

local greeneSpecialUsers = {}

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log

-- data

greeneSpecialUsers.blocked_users = { }

greeneSpecialUsers.cpuplus_users = { } --"wang", "sw77", "zp2137"
 
greeneSpecialUsers.gpuplus_users = { }

greeneSpecialUsers.cns_wang_users = { "vg44", "yl4317", "kb3856", "ab9710", "xd432" }

greeneSpecialUsers.a100_alpha_test_users = { 
  "wang", "sw77", "deng", "wd35", 
  "gm2724", "aj3281", "jy3694",
  "fkb2011", "zp489", "ask762", "vm2134", "eo41",
  "wjm363", "ap6604", "ms7490", "tk3097", "jz3224",
  "jc11431", "ejp416", "at4524", "ks4765", "pp1994",
  "spf248", "og2114", "pfi203"
}

slurm_log("To load greeneSpeicalUsers.lua")

return greeneSpecialUsers
