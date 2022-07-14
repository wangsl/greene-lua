#!/bin/env lua

local greeneSpecialUsers = {}

local greeneUtils = require "greeneUtils"

local slurm_log = greeneUtils.slurm_log

-- data

greeneSpecialUsers.blocked_users = { } 

greeneSpecialUsers.cpuplus_users = { } --"wang", "sw77", "zp2137"
 
greeneSpecialUsers.gpuplus_users = { }

greeneSpecialUsers.cns_wang_users = { "vg44", "yl4317", "kb3856", "ab9710", "xd432" }

greeneSpecialUsers.cds_users = {
  "ac5968", "ajr348", "amm9935", "amv458", "ark576", "as9934", "ask762", "bm106", "by2026", "ci411", "cz1285", "eo41", "es5223", "gd1279", "hh2291", "ji641", "jk185", "js12196", "jz3786", "kc119", "kl3141", "ml7557", "nk3351", "nt2231", "onm217", "pk1822", "pmh330", "rs8020", "rst306", "sb6065", "sk6876", "sl5924", "sm7582", "us441", "vp1271", "wjm363", "wv9", "wz727", "yf2231", "yz1349", "zp489",
  "as17582"
}

greeneSpecialUsers.cilvr_a100_users = {
  "gm2724", "aj3281", "jy3694", -- users from Tandon
  "ac5968", "agc9824", "am10150", "anw2067", "aw130", "aw3272", 
  "bl1611", "bne215", "dm5182", "eo41", "hh2291", "jb4496", "jc11431", 
  "lp91", "map22", "mr3182", "nk3351", "nms572", "nxb2314", 
  "rdf7", "rhr246", "rs4070", "rst306", 
  "sb6065", "sc1104", "sh6474", "tl876", "wv9", "yl22", "yy2694",
  "sa5914", "yp883", "as17582"
}

greeneSpecialUsers.chem_cpu0_users = {
  -- Tuckerman (mt33)
  "zl1277", "bp1473", "mt33", "ap6603", "jr4855", "rsh314", "lv37", "mt4320", 
  "tz1005", "ec3688", "ar6138", "mk8347", "drk354", "se55", "bwd223",
  -- Schlick (ts1)
  "ts1", "cc6533", "azm9134", "sj78", "qz886", "kl4524", "cls9848", 
  "rg4353", "zl3765", "sp5413", "sy3757", "ats324",
  -- Bacic(zb2)
  "mx2000"
}

slurm_log("To load greeneSpeicalUsers.lua")

return greeneSpecialUsers
