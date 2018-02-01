function [dSMBG, dU, bolus, basal, meal_mgpmin, dates, siopt, fastingBG, BW, avgbasalprofilerate_mUpmin, dCGM]... 
= GV_data_vecs(search_path_input, patient_number)

addpath(search_path_input);
all_data = importdata(['database_for_BROM' num2str(patient_number) '.mat']);

nomsi = all_data.si;
siopt = nomsi;
fastingBG = all_data.fastingBG;
BW = all_data.BW;
avgbasalprofilerate_mUpmin = all_data.avgbasalprofilerate_mUpmin;

dSMBG = all_data.smbg-fastingBG;
dU = all_data.dU;
bolus = all_data.BOLUS;
basal = all_data.BASAL;
meal_mgpmin = all_data.meals_mgpmin;
dates = all_data.cgmd;
dCGM = all_data.cgm-fastingBG;