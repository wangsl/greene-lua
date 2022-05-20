#!/bin/env lua

local greeneSpecialUsers = {}

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log

-- data

greeneSpecialUsers.blocked_users = { } 

greeneSpecialUsers.cpuplus_users = { } --"wang", "sw77", "zp2137"
 
greeneSpecialUsers.gpuplus_users = { }

greeneSpecialUsers.cns_wang_users = { "vg44", "yl4317", "kb3856", "ab9710", "xd432" }

-- greeneSpecialUsers.a100_alpha_test_users = { 
--   "wang", "sw77", "deng", "wd35", 
--   "gm2724", "aj3281", "jy3694",
--   "fkb2011", "zp489", "ask762", "vm2134", "eo41",
--   "wjm363", "ap6604", "ms7490", "tk3097", "jz3224",
--   "jc11431", "ejp416", "at4524", "ks4765", "pp1994",
--   "spf248", "og2114", "pfi203",
--   "wjm363", "pk1822", "sk6876", "pi390", "nvg7270", "sl8160", "rs8020",
--   "da2963", "vg2097", "gmh4"
-- }

greeneSpecialUsers.cds_users = {
  "ab8700", "ac5968", "ajr348", "amm9935", "amv458", 
  "ark576", "as9934", "ask762", "avp295", "aw3272", 
  "bm106", "by2026", "cg3306", "ci411", "cjb617", 
  "cl5625", "cz1285", "db4045", "dh148", 
  "eb162", "ec2684", "ejp416", "eo41", "es5223",
  "gd1279", "go533", "hh2291", "ji641", "jk185", "js12196", "jz3224", "jz3786", 
  "kc119", "kl3141", "ml7557", "nhj4247", "nk3351", "nt2231", "nvg7279", 
  "oem214", "onm217", "pk1822", "pmh330", "qx244", "raf466", "rs8020", 
  "ry708", "sb6065", "sk6876", "sl5924", "sm7582", "tw2112", "us441", 
  "vp1271", "wjm363", "wv9", "wz727", "xl3119", 
  "yf2231", "yp883", "yz1349", "yz4135", "zp489", "zz737"
}

greeneSpecialUsers.cilvr_a100_users = {
  "gm2724", "aj3281", "jy3694", -- users from Tandon
  "ac5968", "agc9824", "am10150", "anw2067", "aw130", "aw3272", 
  "bl1611", "bne215", "dm5182", "eo41", "hh2291", "jb4496", "jc11431", 
  "lp91", "map22", "mr3182", "nk3351", "nms572", "nxb2314", 
  "rdf7", "rhr246", "rs4070", "rst306", 
  "sb6065", "sc1104", "sh6474", "tl876", "wv9", "yl22", "yy2694"
}

slurm_log("To load greeneSpeicalUsers.lua")

return greeneSpecialUsers
