#/bin/csh
## Script to calculate CMIP6 results shown in Thackeray et al 22 main text
## (For CMIP5 change model list and some file naming conventions)
## Some preprocessing of CMIP output is required
## This includes the creation of daily precipitation files for each GCM
## Will create a lot of files in processing steps

## Set directories/mask
set dir = /work/cwthackeray/models/CMIP6/precip/1980-2014
set dir2 = /work/cwthackeray/models/CMIP6/precip/2080-2100
set restr = r1i1p1f1_gn
set work = /work/cwthackeray/models/CMIP6/precip/working
set regmask = /work/cwthackeray/Rainfall/REGEN/REGEN_LONG/REGEN_LongTermStns_V1-2019_1995_errormean2_msk25.nc

## Create one file for 1980-2014 daily precipitation and convert units to mm/day. Repeat for 2015-2017 and 2080-2100.
## Naming convention as follows: pr_day_CESM2_historical_r1_1980-2014_fix.nc

######################################
#### Fig 1 ####
## Panel A ##
# Global Hydrologic Sensitivity #

foreach model ( ACCESS-CM2 ACCESS-ESM1-5 BCC-CSM2-MR CanESM5 CESM2 CESM2-WACCM CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3 EC-Earth3-Veg FGOALS-g3 GFDL-CM4 HadGEM3-GC31-LL INM-CM4-8 IPSL-CM6A-LR MIROC6 MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NESM3 NorESM2-LM NorESM2-MM UKESM1-0-LL )

cdo timmean ${dir}/pr_day_${model}_historical_r1_1980-2014_fix.nc ${dir}/pr_day_${model}_historical_r1_1980-2014_fix.tm.nc
cdo timmean ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.tm.nc

cdo fldmean -sub ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.tm.nc ${dir}/pr_day_${model}_historical_r1_1980-2014_fix.tm.nc delta_pr_${model}_ssp585_r1_2080-2100_1980-2014.mmday.aa.nc # change in daily mean precip
# lastly, divide by global warming rate (obtained elsewhere) to get HS in mm/day/K

## Breaking down HS change into extreme/non-extreme (this will save steps later on)
## Calculate 99th percentile of daily precip for the 1980-2014 period
cdo timmax ${dir}/pr_day_${model}_historical_r1_1980-2014_fix.nc ${dir}/pr_day_${model}_historical_r1_1980-2014_fix_tmax.nc
cdo timmin ${dir}/pr_day_${model}_historical_r1_1980-2014_fix.nc ${dir}/pr_day_${model}_historical_r1_1980-2014_fix_tmin.nc
cdo timpctl,99 pr_day_${model}_historical_r1_1980-2014_fix.nc pr_day_${model}_historical_r1_1980-2014_fix_tmin.nc pr_day_${model}_historical_r1_1980-2014_fix_tmax.nc pr_day_${model}_historical_r1_1980-2014_fix_p99.nc

cdo ge pr_day_${model}_historical_r1_1980-2014_fix.nc  pr_day_${model}_historical_r1_1980-2014_fix_p99.nc pr_day_${model}_historical_r1_1980-2014_fix_p99_gemsk.nc      # masks all grid cells greater than or equal to the 99th percentile at each time step
cdo -L timmean -ifthen pr_day_${model}_historical_r1_1980-2014_fix_p99_gemsk.nc pr_day_${model}_historical_r1_1980-2014_fix.nc pr_day_${model}_historical_r1_1980-2014_fix_ge99p_mmday.nc  # historical daily extreme precip magnitude
cdo -L timmean -ifnotthen pr_day_${model}_historical_r1_1980-2014_fix_p99_gemsk.nc pr_day_${model}_historical_r1_1980-2014_fix.nc pr_day_${model}_historical_r1_1980-2014_fix_lt99p_mmday.nc  #daily precip magnitude below 99th percentile

# Calculate for future time period # 
cdo ge ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.nc pr_day_${model}_historical_r1_1980-2014_fix_p99.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99_gemsk.nc
cdo fldmean -timmean  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99_gemsk.nc  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99_gemsk.aa.nc    ## for use in Fig 1b
cdo -L timmean -ifthen ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99_gemsk.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.nc  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_ge99p_mmday.nc
cdo -L timmean -ifnotthen ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99_gemsk.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.nc  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_lt99p_mmday.nc

# Calculate change in daily mean precip above and below the 99th percentile
cdo fldmean -sub  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_ge99p_mmday.nc pr_day_${model}_historical_r1_1980-2014_fix_ge99p_mmday.nc delta_pr_${model}_ssp585_r1_2080-2100_1980-2014_ge99p_mmday.aa.nc
cdo fldmean -sub  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_lt99p_mmday.nc pr_day_${model}_historical_r1_1980-2014_fix_lt99p_mmday.nc delta_pr_${model}_ssp585_r1_2080-2100_1980-2014_lt99p_mmday.aa.nc

end

## Panel B ##
# Frequency of Occurrence #
foreach model ( ACCESS-CM2 ACCESS-ESM1-5 BCC-CSM2-MR CanESM5 CESM2 CESM2-WACCM CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3 EC-Earth3-Veg FGOALS-g3 GFDL-CM4 HadGEM3-GC31-LL INM-CM4-8 IPSL-CM6A-LR MIROC6 MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NESM3 NorESM2-LM NorESM2-MM UKESM1-0-LL )

foreach perc (95 97.5 99.5 99.75 99.9)
cdo -L timpctl,${perc} pr_day_${model}_historical_r1_1980-2014_fix.nc pr_day_${model}_historical_r1_1980-2014_fix_tmin.nc pr_day_${model}_historical_r1_1980-2014_fix_tmax.nc pr_day_${model}_historical_r1_1980-2014_fix_p${perc}.nc
cdo ge ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.nc pr_day_${model}_historical_r1_1980-2014_fix_p${perc}.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp${perc}_gemsk.nc
cdo fldmean -timmean ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp${perc}_gemsk.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp${perc}_gemsk.aa.nc

end
end


## Panels C and D ##
# Change in precipitation magnitude at various percentile levels #
# Send percentile files to work directory for easier cleanup after #
foreach model ( ACCESS-CM2 ACCESS-ESM1-5 BCC-CSM2-MR CanESM5 CESM2 CESM2-WACCM CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3 EC-Earth3-Veg FGOALS-g3 GFDL-CM4 HadGEM3-GC31-LL INM-CM4-8 IPSL-CM6A-LR MIROC6 MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NESM3 NorESM2-LM NorESM2-MM UKESM1-0-LL )
foreach perc (10 20 30 40 50 60 70 80 90 95 97.5 99 99.5 99.75 99.9 )

cdo -L timpctl,${perc}  pr_day_${model}_historical_r1_1980-2014_fix.nc  pr_day_${model}_historical_r1_1980-2014_fix_tmin.nc pr_day_${model}_historical_r1_1980-2014_fix_tmax.nc ${work}/pr_day_${model}_historical_r1_1980-2014_fix_p${perc}.nc
cdo zonmean  percentiles/pr_day_${model}_historical_r1_1980-2014_fix_p${perc}.nc ${work}/pr_day_${model}_historical_r1_1980-2014_fix_p${perc}.zm.nc

cdo -L timpctl,${perc}  pr_day_${model}_ssp585_r1_2080-2100_fix.nc pr_day_${model}_ssp585_r1_2080-2100_fix_tmin.nc pr_day_${model}_ssp585_r1_2080-2100_fix_tmax.nc ${work}/pr_day_${model}_ssp585_r1_2080-2100_fix_p${perc}.nc

cdo zonmean  ${work}/pr_day_${model}_ssp585_r1_2080-2100_fix_p${perc}.nc  ${work}/pr_day_${model}_ssp585_r1_2080-2100_fix_p${perc}.zm.nc

cdo sub ${work}/pr_day_${model}_ssp585_r1_2080-2100_fix_p${perc}.zm.nc ${work}/pr_day_${model}_historical_r1_1980-2014_fix_p${perc}.zm.nc ${work}/delta_pr_${model}_ssp585_r1_p${perc}.zm.nc 

cdo -L mulc,100  -div ${work}/delta_pr_${model}_ssp585_r1_p${perc}.zm.nc ${work}/pr_day_${model}_historical_r1_1980-2014_fix_p${perc}.zm.nc ${work}/percent_change_pr_${model}_ssp585_r1_p${perc}.zm.nc

cdo cat ${work}/percent_change_pr_${model}_ssp585_r1_p*.zm.nc catted_percent_change_pr_${model}_ssp585_r1.nc #concatenate all percentile files together to get 

# cdo divc,__ catted_percent_change_pr_${model}_ssp585_r1.nc catted_percent_change_pr_${model}_ssp585_r1_perK.nc   #again use global warming calculated elsewhere (not included here)

# remap to common grid for ensemble mean analysis
## cdo remapbil,r1x180 catted_percent_change_pr_${model}_ssp585_r1_perK.nc catted_percent_change_pr_${model}_ssp585_r1_perK_1deg.nc
## cdo ensmean catted_percent_change_pr_*_ssp585_r1_perK_1deg.nc cmip6mean_catted_percent_change_pr_ssp585_r1_perK_1deg.nc
end
end




######################################
#### Fig 2 ####
# Frequency of Extreme Precip Time Series #

foreach model ( ACCESS-CM2 ACCESS-ESM1-5 BCC-CSM2-MR CanESM5 CESM2 CESM2-WACCM CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3 EC-Earth3-Veg FGOALS-g3 GFDL-CM4 HadGEM3-GC31-LL INM-CM4-8 IPSL-CM6A-LR MIROC6 MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NESM3 NorESM2-LM NorESM2-MM UKESM1-0-LL )

## Append historical and future scenario files to create a 1980-2017 timeseries (to coincide with MSWEP2)
cdo cat ${dir}/pr_day_${model}_historical_r1_1980-2014_fix.nc ${dir2}/pr_day_${model}_ssp585_r1_2015-2017_fix.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix.nc
cdo ge pr_day_${model}_hist_ssp585_r1_1980-2017_fix.nc  pr_day_${model}_historical_r1_1980-2014_fix_p99.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.nc      # masks all grid cells greater than or equal to the 99th percentile at each time step
cdo yearmean pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym.nc  # calculate annual mean occurrence of extreme precip
cdo fldmean pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym.aa.nc # calculate area average

# Repeat process for all other realizations (not just r1)
foreach real (2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
cdo timmax ${dir}/pr_day_${model}_historical_r${real}_1980-2014_fix.nc ${dir}/pr_day_${model}_historical_r${real}_1980-2014_fix_tmax.nc
cdo timmin ${dir}/pr_day_${model}_historical_r${real}_1980-2014_fix.nc ${dir}/pr_day_${model}_historical_r${real}_1980-2014_fix_tmin.nc
cdo timpctl,99 pr_day_${model}_historical_r1_1980-2014_fix.nc pr_day_${model}_historical_r${real}_1980-2014_fix_tmin.nc pr_day_${model}_historical_r${real}_1980-2014_fix_tmax.nc pr_day_${model}_historical_r${real}_1980-2014_fix_p99.nc

cdo cat ${dir}/pr_day_${model}_historical_r${real}_1980-2014_fix.nc ${dir2}/pr_day_${model}_ssp585_r${real}_2015-2017_fix.nc pr_day_${model}_hist_ssp585_r${real}_1980-2017_fix.nc
cdo ge pr_day_${model}_hist_ssp585_r${real}_1980-2017_fix.nc  pr_day_${model}_historical_r${real}_1980-2014_fix_p99.nc pr_day_${model}_hist_ssp585_r${real}_1980-2017_fix_gemsk.nc      # masks all grid cells greater than or equal to the 99th percentile at each time step
cdo yearmean pr_day_${model}_hist_ssp585_r${real}_1980-2017_fix_gemsk.nc pr_day_${model}_hist_ssp585_r${real}_1980-2017_fix_gemsk.ym.nc  # calculate annual mean occurrence of extreme precip
cdo fldmean pr_day_${model}_hist_ssp585_r${real}_1980-2017_fix_gemsk.ym.nc pr_day_${model}_hist_ssp585_r${real}_1980-2017_fix_gemsk.ym.aa.nc # calculate area average

# Calculate CanESM5 mean
cdo ensmean pr_day_CanESM5_hist_ssp585_r*_1980-2017_fix_gemsk.ym.aa.nc pr_day_CanESM5_hist_ssp585_EM_1980-2017_fix_gemsk.ym.aa.nc
# Calculate for mean for each GCM then determine CMIP6 mean (simpler to do offline)
cdo ensmean pr_day_${model}_hist_ssp585_r*_1980-2017_fix_gemsk.ym.aa.nc pr_day_${model}_hist_ssp585_EM_1980-2017_fix_gemsk.ym.aa.nc
cdo ensmean pr_day_*_hist_ssp585_EM_1980-2017_fix_gemsk.ym.aa.nc cmip6mean_pr_day_hist_ssp585_EM_1980-2017_fix_gemsk.ym.aa.nc
# Repeat analysis for Observations and CMIP5

end
end






######################################
#### Fig 3 ####
# Spatial maps of historical and future change in FP>=99 #

foreach model ( ACCESS-CM2 ACCESS-ESM1-5 BCC-CSM2-MR CanESM5 CESM2 CESM2-WACCM CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3 EC-Earth3-Veg FGOALS-g3 GFDL-CM4 HadGEM3-GC31-LL INM-CM4-8 IPSL-CM6A-LR MIROC6 MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NESM3 NorESM2-LM NorESM2-MM UKESM1-0-LL )

# calculate trend in annual FP>=99
cdo trend pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_avg.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd.nc  
cdo mulc,1000 pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec.nc  # convert units from slope to %/dec

cdo remapbil,r360x180 pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec_1D.nc # put on common 1 deg grid for mapping
cdo ensmean pr_day_*_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec_1D.nc cmip6mean_pr_day_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec_1D.nc  # calculate ensemble mean

cdo zonmean pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec_1D.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec_1D.zm.nc # calculate zonal means for right side of figure
cdo ensmean pr_day_*_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec_1D.zm.nc cmip6mean_pr_day_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec_1D.zm.nc 

## Calculate Future Change in FP>=99
## Starting with a 2080-2100 daily precipitation file similar to above
cdo ge ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix.nc pr_day_${model}_historical_r1_1980-2014_fix_p99.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.nc
cdo timmean ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.nc
cdo remapbil,r360x180 ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.nc ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.nc

cdo cat ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.nc ${dir2}/cmip6_23modmean_pr_ssp585_2080-2100_histp99_gemsk.tm.1D.nc

cdo mulc,100 -subc,0.01 ${dir2}/cmip6_23modmean_pr_ssp585_2080-2100_histp99_gemsk.tm.1D.nc ${dir2}/cmip6_23modmean_pr_ssp585_2080-2100_histp99_gemsk.tm.1D.percent.nc # convert to percent change (subtracting 0.01 everywhere because historical 99th percentile is defined locally)
cdo zonmean ${dir2}/cmip6_23modmean_pr_ssp585_2080-2100_histp99_gemsk.tm.1D.percent.nc ${dir2}/cmip6_23modmean_pr_ssp585_2080-2100_histp99_gemsk.tm.1D.percent.zm.nc # zonal mean data

# Repeat for CMIP5

end






######################################
#### Fig 4 ####
# Data for Emergent Constraint Scatterplot #
foreach model ( ACCESS-CM2 ACCESS-ESM1-5 BCC-CSM2-MR CanESM5 CESM2 CESM2-WACCM CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3 EC-Earth3-Veg FGOALS-g3 GFDL-CM4 HadGEM3-GC31-LL INM-CM4-8 IPSL-CM6A-LR MIROC6 MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NESM3 NorESM2-LM NorESM2-MM UKESM1-0-LL )

cdo fldmean pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec.nc pr_day_${model}_hist_ssp585_r1_1980-2017_fix_gemsk.ym_trd_perdec.aa.nc  # x-axis quantity (global)

cdo fldmean ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.nc  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.aa.nc  # future frequency of recip exceeding the historical 99th percentile

cdo mulc,100 -subc,0.01  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.aa.nc   ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_p99_gemsk.tm.aa.perchange.nc # convert to percent change

# For Panel b the data needs to be masked #
cdo cat ${dir2}/pr_day_*_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.nc ${dir2}/cmip6_23mods_pr_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.nc

cdo ifthen ${regmask) ${dir2}/cmip6_23mods_pr_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.nc  ${dir2}/cmip6_23mods_pr_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.regenmsk.nc

cdo fldmean ${dir2}/cmip6_23mods_pr_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.regenmsk.nc ${dir2}/cmip6_23mods_pr_ssp585_r1_2080-2100_fix_p99_gemsk.tm.1D.regenmsk.aa.nc

# convert units to percent change as before

end




######################################
#### Fig 5 ####
# Data for Emergent Constraint Scatterplot #
# Repeat analysis for SSP2-4.5 (not shown here for brevity)


######################################
#### Fig 6 ####
# Data for Emergent Constraint Scatterplot #
# x-axis quantity is already calculated so just need to get the y-axis

foreach model ( ACCESS-CM2 ACCESS-ESM1-5 BCC-CSM2-MR CanESM5 CESM2 CESM2-WACCM CNRM-CM6-1 CNRM-ESM2-1 EC-Earth3 EC-Earth3-Veg FGOALS-g3 GFDL-CM4 HadGEM3-GC31-LL INM-CM4-8 IPSL-CM6A-LR MIROC6 MPI-ESM1-2-HR MPI-ESM1-2-LR MRI-ESM2-0 NESM3 NorESM2-LM NorESM2-MM UKESM1-0-LL )

#Panel A - Future Change in extreme precip magnitude
#Calculated above:  delta_pr_${model}_ssp585_r1_2080-2100_1980-2014_ge99p_mmday.aa.nc

#Panel B - Future change in FP>=99.9 (very extreme precip)

cdo timmean  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99.9_gemsk.nc  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99.9_gemsk.tm.nc

cdo fldmean  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99.9_gemsk.tm.nc  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99.9_gemsk.tm.aa.nc

cdo mulc,100 -subc,0.001  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99.9_gemsk.tm.aa.nc  ${dir2}/pr_day_${model}_ssp585_r1_2080-2100_fix_histp99.9_gemsk.tm.aa.perchange.nc


end
exit
