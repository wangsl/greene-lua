#!/bin/env lua

local greeneSpecialUsers = {}

local greeneUtils = require "greeneUtils"

local table_concat = greeneUtils.table_concat

local slurm_log = greeneUtils.slurm_log

-- data

greeneSpecialUsers.blocked_users = { } 

greeneSpecialUsers.cpuplus_users = { } -- "wang", "sw77", "zp2137"
 
greeneSpecialUsers.gpuplus_users = { }

greeneSpecialUsers.cns_wang_users = { "vg44", "yl4317", "kb3856", "ab9710", "xd432" }

greeneSpecialUsers.cds_users = {
  "aa9774", "ac5968", "agc9824", "ajr348", "amm9935", "amv458", 
  "ap6599", "ap6604", "ark576", "as17582", "as9934", "ask762", 
  "aw130", "ayl316", "bl1611", "bm106", "bm3418", "by2026", 
  "cfg3", "ci411", "cl5043", "cs5360", "csg337", "cz1285", 
  "ddr8143", "ec1302", "eo41", "fa2161", "gd1279", "gm3239", "gn523", "gw2180", 
  "hh2291", "hrr288", "hs3673", "idr2823", "iem244", 
  "ja4775", "jb4496", "jc3832", "jds405", "jdw453", "ji641", "jk185", "jm10082", 
  "jp6263", "js12196", "jz3786",
  "kc119", "ke2129", "kl3141", "kve216", "leb9763", "lhz209", "lyj2002", 
  "mat9360", "mg7285", "mkh260", "ml7557", "mm7936", "mmb557", "mr3182", "myh2014", 
  "nk3351", "nn1119", "ns4008", "nt2231", "nw1045", "pk1822", "pw44", 
  "ql518", "rhr246", "rs8020", "rst306", "sb6065", "sh7354", 
  "sk6876", "sl5924", "sl8160", "sm11197", "sm8523", 
  "tch362", "tl876", "tm1178", "tr2432", "us441", "vd2185", "vka244", 
  "vp1271", "waf251", "wcm9940", "wh992", "wl1566", "wv9", "wz2247", 
  "wz727", "yf2231", "ys1001", "yx2105", "yz1349", "zk388", "zp489", "zz1706",
  "yc5830"
}

greeneSpecialUsers.cilvr_a100_users = {
  "ac5968", "agc9824", "am10150", "anw2067", "apm470", "aw130", "aw3272", 
  "bl1611", "bne215", "cz1285", "dm5182", "eo41", "hh2291", 
  "jb4496", "jc11431", "lhz209", "lp91", "map22", "mg3479", "mr3182", "ms7490", 
  "nal9967", "nhj4247", "nk3351", "nms572", "nxb2314", 
  "rdf7", "rhr246", "rs4070", "rst306", "sb6065", "sc1104", "sh6474", 
  "tl876", "wv9", "xh1007", "yl22", "yp883", "yy2694",
  "ar7420", "ig2283", "zc2357", "up2021"
}

greeneSpecialUsers.chem_cpu0_users = {
  -- Tuckerman (mt33)
  "zl1277", "bp1473", "mt33", "ap6603", "jr4855", "rsh314", "lv37", "mt4320", 
  "tz1005", "ec3688", "ar6138", "mk8347", "drk354", "se55", "bwd223",
  -- Schlick (ts1)
  "ts1", "cc6533", "azm9134", "sj78", "qz886", "kl4524", "cls9848", 
  "rg4353", "zl3765", "sp5413", "sy3757", "ats324",
  -- Bacic(zb2)
  "mx200"
}

greeneSpecialUsers.tandon_a100_2_users = { "mr6852",
 -- PI Chinmay Hegde
 "bf996", "aaj458", "mp5847", "ntl2689", "gm2724", "km38888", "at4932",
 -- Nasir Memon
 "aj3281", "jy3694"
}

greeneSpecialUsers.chemistry_a100_2_users = { 
  "gmh4", "gm2535", 
  "zl3765", 
  "sx801", "tk2801", "cii2002", "ch3859" 
}

local stakeholders_a100_users = {} 
stakeholders_a100_users = table_concat(stakeholders_a100_users, greeneSpecialUsers.cds_users)
stakeholders_a100_users = table_concat(stakeholders_a100_users, greeneSpecialUsers.cilvr_a100_users)
stakeholders_a100_users = table_concat(stakeholders_a100_users, greeneSpecialUsers.tandon_a100_2_users)
stakeholders_a100_users = table_concat(stakeholders_a100_users, greeneSpecialUsers.chemistry_a100_2_users)

greeneSpecialUsers.stakeholders_a100_users = stakeholders_a100_users

slurm_log("To load greeneSpeicalUsers.lua")

return greeneSpecialUsers
