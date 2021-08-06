# Projected-Summer-climate-change-in-the-Aral-Sea-region
Step 1: replace the land cover in default ECOCLIMAP (ECOCLIMAP.m)
Step 2: create the CLIM file for the same domain (job_923_model.12km)
Step 3: Make Domain, create the pgd for domain in order to have the orography (job_pgd_ca_2015_10km_FUTURE.sh)
Step 4: create the physical pgd with cy36 (make_pgd_923_model.10km)
Step 5: run the 50 km runs over the Central Asia for the period from 1980-1989 (script_outerdomain.sh)
Step 6: run the 4 km runs over the Aral Sea region with default parameters for the period from 1980-1989 (script_inerdomain.sh)
Step 7: run the 4 km runs over the Aral Sea region with updated parameters for the period from 1980-1989 (script_inerdomain.sh)
Step 8: extract the modeling result and compare with observation (ectract_station_day_t2m.R)
Step 10: calculate the mean value of Case 3 and Case 4, then conduct student-t test to plot the significant difference (pvalue < 0.01) (Ttest_TP.R)
