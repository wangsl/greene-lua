#!/bin/env lua

function slurm_job_submit(job_desc, part_list, submit_uid)

   package.path = ';/share/apps/admins/slurm-lua/?.lua;' .. package.path
   package.cpath = ';/share/apps/admins/slurm-lua/?.so;' .. package.cpath
   
   local greenePkgs = require "greenePkgs"
   greenePkgs.unload_new_updated_packages()

   local greene = require "greene"
   return greene.job_submission(job_desc, part_list, submit_uid)

   --return slurm.SUCCESS
end

function slurm_job_modify(job_desc, job_rec, part_list, modify_uid)
   if modify_uid == 0 then
      return slurm.SUCCESS
   else
      return slurm.ERROR
   end
end

slurm.log_info("**** SLURM Lua plugin initialized with Lua version %s ****", _VERSION)

return slurm.SUCCESS


