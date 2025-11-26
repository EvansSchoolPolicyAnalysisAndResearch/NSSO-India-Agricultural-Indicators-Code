/*
-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title:  		 Agricultural Development Indicators

*Purpose:		 This do.file was developed by the Evans School Policy Analysis & Research Group (EPAR) 
				 for the construction of a set of agricultural development indicators 
				 using the Situation Assessment Survey (SAS) of Agricultural Households published by 
				 India's National Statistical Survey Office (NSSO)
*Author(s):		 Ahana Raina, Vanisha Sharma & Federico Trindade 

*Date:	 		 This Version - 25th of November, 2025

*Contact:	     uw.eparx@uw.edu
----------------------------------------------------------------------------------------------------------------------------------------------------*/


* Data source
*-------------
* Situation Assessment Survey (SAS) of Agricultural Households and Land and Livestock Holdings (LLH) Survey: NSS 77th Round, Schedule 33.1, 2018-19 
* The data were collected over the period July 2018 - June 2019.
* All the raw data, questionnaires, and basic information documents are available for downloading free of charge at the following link
* https://microdata.gov.in/NADA/index.php/catalog/157


clear
set more off

*Set directories
global IND_SAAHH_raw_data 		"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Non-LSMS Datasets\India - NSSO\SAAHH LLH 2018-19\raw_data"
global IND_SAAHH_created_data 	"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Non-LSMS Datasets\India - NSSO\SAAHH LLH 2018-19\created_data"
global IND_SAAHH_final_data 	"\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Non-LSMS Datasets\India - NSSO\SAAHH LLH 2018-19\final_data"


***********************
*GENERAL INFORMATION 
***********************
*Survey was divided in two visits. Visit 1 covers July 2018 to December 2018 and Visit 2 cover January 2019 to June 2019. Raw data is divided in these two visits.  

*We need to adjust for inflation to generate 2016 real values and to convert to PPP to report monetary values in 2016 PPP $.
global exchange_rate 69.5661		// Monday 31 December 2018	$1 USD = ₹69.5661 - https://www.exchangerates.org.uk/USD-INR-spot-exchange-rates-history-2018.html (Accessed May 2022)
global gdp_ppp_dollar 20.6478 		// 2017 (https://data.worldbank.org/indicator/PA.NUS.PPP; Accessed March 22 2023)
global cons_ppp_dollar 19.4690 		// 2017 (https://data.worldbank.org/indicator/PA.NUS.PRVT.PP; Accessed March 22 2023) 
global inflation -0.072487   		// Between 2016-2019 – di (154.054/171.622-1) – Rate of inflation is calculated using the CPI of India - We are taking everything to 2017 CPI (https://data.worldbank.org/indicator/FP.CPI.TOTL?end=2017&locations=IN&start=2004; Accessed January 8, 2020) 

* We identify three states that are of interest to us and we generally pull estimates for these states only.
* NSS codes for focus states: Bihar (State = 10*), Odisha (State = 21*), Uttar Pradesh (State = 09*)
* Population 2011 census: Bihar 104,099,452 - Odisha 41,974,218 - UttarPradesh 199,812,341

global common_ID "FSU_num SSS_num HHID_num level" // The ID variables mentioned by the resource files are: FSU_num SSS_num HHID_num visit_num level NSS_region item_code_variable 

/*
****************************
* First row decomposition 
****************************

Household identifying variables are merged within the first variable. Each module will use a different letter (I on this example) but they always follow this sequence:

gen centre_code = substr(I1,1,3)
gen FSU_num = substr(I1,4,5)
gen round = substr(I1,9,2)
gen schedule = substr(I1,11,3)
gen sample = substr(I1,14,1)
gen sector = substr(I1,15,1)
gen NSS_region = substr(I1,16,3)
gen district = substr(I1,19,2)
gen stratum = substr(I1,21,2)
gen substratum = substr(I1,23,2)
gen subround = substr(I1,25,1)
gen FOD_subregion = substr(I1,26,4)
gen SSS_num = substr(I1,30,1)
gen HHID_num = substr(I1,31,2)
gen visit_num = substr(I1,33,1)
*/


***************
*HOUSEHOLD IDS        
***************
*Merge visit 1 and visit 2 together
use "$IND_SAAHH_raw_data/Visit 1/level_01.dta", clear
merge 1:1 A2 A13 A14 A16 using "$IND_SAAHH_raw_data/Visit 2/level_01.dta", nogen

gen centre_code = A1
gen FSU_num = A2
gen round = A3
gen schedule = A4
gen sample = A5
gen sector = A6
gen NSS_region = A7
gen district = A8
gen stratum = A9
gen substratum = A10
gen subround = A11
gen FOD_subregion = A12
gen SSS_num = A13
gen HHID_num = A14
gen visit_num = A15
gen level = A16
gen weight = A35

global common_ID "FSU_num SSS_num HHID_num level" 

duplicates r ($common_ID) // 58,040 observations with no duplicates (Report mentions 58,035 HHs in visit 1 and 56,894 HHs in visit 2). 

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num weight, replace

merge m:1 NSS_region using "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Non-LSMS Datasets\India - NSSO\SAAHH LLH 2018-19\States_NSS_regions.dta", nogen // this file should be saved in the folder with the do file

save "$IND_SAAHH_final_data\India_SAAHH_2018_hhid.dta", replace



************************
*FARM SIZE             
************************
* Note: We are using agricultural non-homestead land 

use "$IND_SAAHH_raw_data/Visit 2/level_04.dta", clear

foreach var of varlist _all {
       rename `var' `var'_2
}

ren D1_2 D1

gen centre_code = substr(D1,1,3)
gen FSU_num = substr(D1,4,5)
gen round = substr(D1,9,2)
gen schedule = substr(D1,11,3)
gen sample = substr(D1,14,1)
gen sector = substr(D1,15,1)
gen NSS_region = substr(D1,16,3)
gen district = substr(D1,19,2)
gen stratum = substr(D1,21,2)
gen substratum = substr(D1,23,2)
gen subround = substr(D1,25,1)
gen FOD_subregion = substr(D1,26,4)
gen SSS_num = substr(D1,30,1)
gen HHID_num = substr(D1,31,2)
gen visit_num = substr(D1,33,1)

destring D4_2, replace
destring D5_2, replace
destring D7_2, replace
destring D8_2, replace
destring D9_2, replace
destring D10_2, replace
destring D11_2, replace
destring D14_2, replace
destring D15_2, replace
destring D25_2, replace
destring D19_2, replace

destring NSS_region, replace

recode D7_2 D8_2 D9_2 D10_2 D11_2 (.=0)
gen weight_v2 = D25_2/100
gen agric_land_v2 = D7_2 + D8_2 + D9_2 + D10_2 + D11_2 if D6_2=="1" & (D4_2 == 1 | D4_2 == 2 | D4_2 == 3 | D4_2 == 4)   // We are excluding leased-out land and homestead land. Considering 'owned and possesed' (1), 'leased-in' (2,3) and 'otherwise possessed' (4) if they are reported to be used for agricultural prod or fallow. 
gen irrigated_v2=D14_2 if D6_2=="1" & (D4_2 == 1 | D4_2 == 2 | D4_2 == 3 | D4_2 == 4)
recode irrigated_v2 (2=0)
gen area_irrigated_ha_v2 = 0
replace area_irrigated_ha_v2 = D15_2 * 0.404686 if D6_2=="1" & (D4_2 == 1 | D4_2 == 2 | D4_2 == 3 | D4_2 == 4)

* adding sharecropping
destring D20_2, replace
destring D21_2, replace
destring D22_2, replace
destring D23_2, replace
gen sharecropping_v2 = 1 if (D20_2>0|D21_2>0) & (D4_2 == 2 | D4_2 == 3)
replace sharecropping_v2 = 0 if (D20_2==.& D21_2==.) & (D4_2 == 2 | D4_2 == 3)
replace sharecropping_v2 = 0 if (D4_2 == 1 | D4_2 == 4 | D4_2 == 5)

collapse (sum) agric_land_v2 area_irrigated_ha_v2 (max) weight_v2 irrigated_v2 sharecropping_v2, by(FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num) // 

tempfile module_05_v2
save `module_05_v2'

use "$IND_SAAHH_raw_data/Visit 1/level_04.dta", clear
gen centre_code = substr(D1,1,3)
gen FSU_num = substr(D1,4,5)
gen round = substr(D1,9,2)
gen schedule = substr(D1,11,3)
gen sample = substr(D1,14,1)
gen sector = substr(D1,15,1)
gen NSS_region = substr(D1,16,3)
gen district = substr(D1,19,2)
gen stratum = substr(D1,21,2)
gen substratum = substr(D1,23,2)
gen subround = substr(D1,25,1)
gen FOD_subregion = substr(D1,26,4)
gen SSS_num = substr(D1,30,1)
gen HHID_num = substr(D1,31,2)
gen visit_num = substr(D1,33,1)

destring D4, replace
destring D5, replace
destring D7, replace
destring D8, replace
destring D9, replace
destring D10, replace
destring D11, replace
destring D14, replace
destring D15, replace
destring D25, replace
ren D25 weight_v1

destring NSS_region, replace

recode D7 D8 D9 D10 D11 (.=0)
gen agric_land_v1 = D7 + D8 + D9 + D10 + D11 if D6=="1" & (D4 == 1 | D4 == 2 | D4 == 3 | D4 == 4)   // We are excluding leased-out land and homestead land. Considering 'owned and possesed' (1), 'leased-in' (2,3) and 'otherwise possessed' (4) if they are reported to be used for agricultural prod or fallow. 
gen irrigated_v1=D14 if D6=="1" & (D4 == 1 | D4 == 2 | D4 == 3 | D4 == 4)
recode irrigated_v1 (2=0)
gen area_irrigated_ha_v1 = 0
replace area_irrigated_ha_v1 = D15 * 0.404686 if D6=="1" & (D4 == 1 | D4 == 2 | D4 == 3 | D4 == 4)

* adding sharecropping
destring D20, replace
destring D21, replace
destring D22, replace
destring D23, replace
gen sharecropping_v1 = 1 if (D20>0|D21>0) & (D4 == 2 | D4 == 3)
replace sharecropping_v1 = 0 if (D20==.& D21==.) & (D4 == 2 | D4 == 3)
replace sharecropping_v1 = 0 if (D4 == 1 | D4 == 4 | D4 == 5)

collapse (sum) agric_land_v1 area_irrigated_ha_v1 (max) irrigated_v1 weight_v1 sharecropping_v1, by(FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num) // 

merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using `module_05_v2', nogen keep (2 3) keepusing(agric_land_v2 weight_v2 irrigated_v2 area_irrigated_ha_v2 sharecropping_v2)
merge m:1 NSS_region using "\\netid.washington.edu\wfs\EvansEPAR\Project\EPAR\Non-LSMS Datasets\India - NSSO\SAAHH LLH 2018-19\States_NSS_regions.dta", nogen // this file should be saved in the folder with the do file

* adding sharecropping
gen sharecropping = 1 if (sharecropping_v1==1 | sharecropping_v2==1)
replace sharecropping = 0 if (sharecropping_v1==0 & sharecropping_v2==0)

gen ag_hh=0
replace ag_hh=1 if SSS_num!="1" // ag_hh are those were main source of income comes from agriculture

*Focus states
gen state= "Other" 
replace state= "Bihar" if NSS_region==101  | NSS_region==102 
replace state= "Odisha" if NSS_region==211 | NSS_region==212 | NSS_region==213 
replace state= "UttarPradesh" if NSS_region==91 | NSS_region==92 | NSS_region==93 | NSS_region==94 | NSS_region==95 

gen total_land_max = max(agric_land_v1, agric_land_v2)
gen land_irrig_ha = max(area_irrigated_ha_v1, area_irrigated_ha_v2) 
gen land_max_ha = total_land_max * 0.404686   // 1 acre = 0.404686 ha
gen irrigated = max(irrigated_v1, irrigated_v2)

*State level winsorization
global wins_var_top1 "land_max_ha land_irrig_ha"
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist land_max_ha land_irrig_ha {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight_v2] if state=="`j'" & ag_hh==1, p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'" & ag_hh==1
	}
}

*National level winsorization
foreach v of varlist land_max_ha land_irrig_ha {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight_v2] if ag_hh==1, p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. & ag_hh==1
	}

gen farm_size_category = 0
replace farm_size_category = 1 if land_max_ha >0 & land_max_ha <=1
replace farm_size_category = 2 if land_max_ha >1 & land_max_ha <=2
replace farm_size_category = 3 if land_max_ha >2 & land_max_ha <=3
replace farm_size_category = 4 if land_max_ha >3 & land_max_ha <=4
replace farm_size_category = 5 if land_max_ha >4 & land_max_ha <=5
replace farm_size_category = 6 if land_max_ha >5 & land_max_ha <=10
replace farm_size_category = 7 if land_max_ha >10
label define size_category 0 "0 ha" 1 "0-1 ha" 2 "1-2 ha" 3 "2-3 ha" 4 "3-4 ha" 5 "4-5 ha" 6 "5-10 ha" 7 ">10 ha"
label values farm_size_category size_category
lab var land_max_ha "Area of land owned or possessed (in hectares) max of both visits"

* Estimates for focus states
tab farm_size_category if state=="Bihar" [aw=weight_v2] 
tab farm_size_category if state=="Odisha" [aw=weight_v2] 
tab farm_size_category if state=="UttarPradesh" [aw=weight_v2] 
tab farm_size_category [aw=weight_v2]  // All India

total weight_v2 if farm_size_category <=2 & state=="Bihar"
total weight_v2 if farm_size_category <=2 & state=="Odisha"
total weight_v2 if farm_size_category <=2 & state=="UttarPradesh"
total weight_v2 if farm_size_category <=2 // Al india

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

sum ws_land_max_ha if state=="Bihar" & ag_hh==1 [aw=weight_v2] 
sum ws_land_max_ha if state=="Odisha" & ag_hh==1 [aw=weight_v2] 
sum ws_land_max_ha if state=="UttarPradesh" & ag_hh==1 [aw=weight_v2] 
sum wn_land_max_ha if ag_hh==1 [aw=weight_v2] 

tabstat sharecropping [aw=weight_v2 * land_max_ha] if ag_hh==1, s(mean) by(state_name) 

save "$IND_SAAHH_final_data\farm_size.dta", replace


***********************
* HOUSEHOLD SIZE 	
***********************
use "$IND_SAAHH_raw_data\Visit 2\level_02.dta", clear

foreach var of varlist _all {
       rename `var' `var'_2
}

ren B1_2 B1

gen centre_code = substr(B1,1,3)
gen FSU_num = substr(B1,4,5)
gen round = substr(B1,9,2)
gen schedule = substr(B1,11,3)
gen sample = substr(B1,14,1)
gen sector = substr(B1,15,1)
gen NSS_region = substr(B1,16,3)
gen district = substr(B1,19,2)
gen stratum = substr(B1,21,2)
gen substratum = substr(B1,23,2)
gen subround = substr(B1,25,1)
gen FOD_subregion = substr(B1,26,4)
gen SSS_num = substr(B1,30,1)
gen HHID_num = substr(B1,31,2)
gen visit_num = substr(B1,33,1)

destring B4_2, replace
destring B5_2, replace
destring B6_2, replace
destring B7_2, replace
destring B8_2, replace
destring B9_2, replace

rename B4_2 person_id 
rename B5_2 relationship_head
rename B6_2 gender
rename B7_2 age

* Focus states
gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

ren B20_2  weight_v2
destring weight_v2, replace
replace  weight_v2=weight_v2/100

* Head of household
gen male_head = 0
replace male_head=1 if relationship_head==1 & gender==1

preserve
collapse (max) male_head weight_v2 , by(FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num state) // 
la var male_head "HH is male headed, 1=yes"	
save "$IND_SAAHH_final_data\India_SAAHH_2018_male_head.dta", replace
restore

* Adult equivalents            // Using Tanzania LSMS-ISA guidelines 
destring gender, replace
gen adulteq=. 
gen HH_members=1
gen HH_members_f=0
gen HH_members_m=0
replace HH_members_f=1 if gender==2
replace HH_members_m=1 if gender==1
replace adulteq=0.76 	if (age<11 & age>8)
replace adulteq=0.80 	if (age<12 & age>10) & gender==1		// 1=male, 2=female |  we are assuming girls 10-12 have higher adulteq than boys 10-12.
replace adulteq=0.88 	if (age<12 & age>10) & gender==2
replace adulteq=1 		if (age<15 & age>12)
replace adulteq=1.2 	if (age<19 & age>14) & gender==1
replace adulteq=1 		if (age<19 & age>14) & gender==2
replace adulteq=1 		if (age<60 & age>18) & gender==1
replace adulteq=0.88 	if (age<60 & age>18) & gender==2
replace adulteq=0.8 	if (age>59 & age!=.) & gender==1
replace adulteq=0.72 	if (age>59 & age!=.) & gender==2
collapse (sum) adulteq HH_members (firstnm) weight_v2, by(FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num state) //
lab var adulteq "Adult equivalents in the household"
lab var HH_members "Persons living in the household"

tempfile block_03_v2
save `block_03_v2'

use "$IND_SAAHH_raw_data\Visit 1\level_02.dta", clear

gen centre_code = substr(B1,1,3)
gen FSU_num = substr(B1,4,5)
gen round = substr(B1,9,2)
gen schedule = substr(B1,11,3)
gen sample = substr(B1,14,1)
gen sector = substr(B1,15,1)
gen NSS_region = substr(B1,16,3)
gen district = substr(B1,19,2)
gen stratum = substr(B1,21,2)
gen substratum = substr(B1,23,2)
gen subround = substr(B1,25,1)
gen FOD_subregion = substr(B1,26,4)
gen SSS_num = substr(B1,30,1)
gen HHID_num = substr(B1,31,2)
gen visit_num = substr(B1,33,1)

destring B4, replace
destring B5, replace
destring B6, replace
destring B7, replace
destring B8, replace
destring B9, replace

rename B4 person_id 
rename B5 relationship_head_v1
rename B6 gender
rename B7 age

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

ren B20  weight_v1
destring weight_v1, replace
replace  weight_v1=weight_v1/100


* Adult equivalents     
destring gender, replace
gen adulteq=. 
gen HH_members=1
gen HH_members_f=0
gen HH_members_m=0
replace HH_members_f=1 if gender==2
replace HH_members_m=1 if gender==1
replace adulteq=0.76 	if (age<11 & age>8)
replace adulteq=0.80 	if (age<12 & age>10) & gender==1		// 1=male, 2=female |  do girls have a higher equivalency than boys?
replace adulteq=0.88 	if (age<12 & age>10) & gender==2
replace adulteq=1 		if (age<15 & age>12)
replace adulteq=1.2 	if (age<19 & age>14) & gender==1
replace adulteq=1 		if (age<19 & age>14) & gender==2
replace adulteq=1 		if (age<60 & age>18) & gender==1
replace adulteq=0.88 	if (age<60 & age>18) & gender==2
replace adulteq=0.8 	if (age>59 & age!=.) & gender==1
replace adulteq=0.72 	if (age>59 & age!=.) & gender==2
collapse (sum) adulteq HH_members* (firstnm) weight_v1, by(FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num state) //
lab var adulteq "Adult equivalents in the household"
lab var HH_members "Persons living in the household"

ren adulteq adulteq_v1
ren HH_members HH_members_v1

tempfile block_03_v1
save `block_03_v1'

merge 1:1  FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using `block_03_v2'
gen ag_hh=0
replace ag_hh=1 if SSS_num!="1" // ag_hh are those were main source of income comes from agriculture

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

save "$IND_SAAHH_final_data\adulteq.dta", replace

****************************
* HOUSEHOLD CHARACTERISTICS
****************************

use "$IND_SAAHH_raw_data\Visit 1\level_03.dta", clear // particulars of households 

gen centre_code = substr(C1,1,3)
gen FSU_num = substr(C1,4,5)
gen round = substr(C1,9,2)
gen schedule = substr(C1,11,3)
gen sample = substr(C1,14,1)
gen sector = substr(C1,15,1)
gen NSS_region = substr(C1,16,3)
gen district = substr(C1,19,2)
gen stratum = substr(C1,21,2)
gen substratum = substr(C1,23,2)
gen subround = substr(C1,25,1)
gen FOD_subregion = substr(C1,26,4)
gen SSS_num = substr(C1,30,1)
gen HHID_num = substr(C1,31,2)
gen visit_num = substr(C1,33,1)

destring C27 C16 C4 C12 C7 C13 C19, replace

gen weight=C27/100
ren C16 bank_account
ren C19 farmers_group

recode bank_account farmers_group C13 (2=0)
ren C4 HH_size
ren C12 monthly_spending_Rs // usual monthly consumer expenditure
ren C13 ag_self_prod_year // from self employment
lab var ag_self_prod_year "value of agricultural production from self-employment activities during the last above 4,000 Rs (188.6 $2016PPP)"
lab var monthly_spending_Rs "Usual monthly consumer expenditures in Rupees"
lab var farmers_group "Wheter any of the household members is part of a registered farmers' organization'"

gen ag_hh = 0
replace ag_hh = 1 if C7<=4 | C7==5 | C7==7   // ag hh determined by main source of income: self employed in crop production (1), livestock production (2), other Ag activities (3), salaried earning in ag (5), and casual labour in ag (7).   | FT: should we consider casual labor in Ag even if it is their main source of income?

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

foreach v of varlist monthly_spending_Rs {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist monthly_spending_Rs {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight] if state=="`j'", p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=.
	}

gen ws_monthly_spending_2017ppp = ((ws_monthly_spending_Rs * (1+ $inflation))) / $cons_ppp_dollar
gen wn_monthly_spending_2017ppp = ((wn_monthly_spending_Rs * (1+ $inflation))) / $cons_ppp_dollar
lab var ws_monthly_spending_2017ppp "Household monthly spending in 2017 PPP US$ - Winsorized top 1% - state"
lab var wn_monthly_spending_2017ppp "Household monthly spending in 2017 PPP US$ - Winsorized top 1% - national"

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace
save "$IND_SAAHH_final_data\hh_characteristics.dta", replace


***********************
* LIVESTOCK HOLDINGS
***********************
* All livestock holding information is on module 8 of visit 1 
* In previous waves the LLH survey was not conducted jointly with SAS.

use "$IND_SAAHH_raw_data/Visit 1/level_09.dta", clear

gen centre_code = substr(I1,1,3)
gen FSU_num = substr(I1,4,5)
gen round = substr(I1,9,2)
gen schedule = substr(I1,11,3)
gen sample = substr(I1,14,1)
gen sector = substr(I1,15,1)
gen NSS_region = substr(I1,16,3)
gen district = substr(I1,19,2)
gen stratum = substr(I1,21,2)
gen substratum = substr(I1,23,2)
gen subround = substr(I1,25,1)
gen FOD_subregion = substr(I1,26,4)
gen SSS_num = substr(I1,30,1)
gen HHID_num = substr(I1,31,2)
gen visit_num = substr(I1,33,1)

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095"


destring I4, replace 	//change livestock code from a string variable to an int
destring I7, replace 	//change livestock num from a string variable to an int
destring I10, replace 	//change HH weights from a string variable to an int

ren I4 livestock_code
ren I7 num_owned
ren I10 weight
replace weight=weight/100
ren I2 level

replace livestock_code = 6 if livestock_code >= 4 & livestock_code <= 6 	//make all buffalo the same code
replace livestock_code = 5 if livestock_code >= 1 & livestock_code <= 3		//make all cattle the same code
drop if livestock_code ==11

local livestock_types cattle buffalo short_mammals equines poultry other  // Short mammals includes sheep, goat, pig, rabbit and similar. Equine includes horse, elephant, camel and similar. 

gen livestock_code_num = 5

//loop through all livestock types, and the numbers for each livestock code, and get the counts of each livestock type for each household
foreach l of local livestock_types{
	gen `l'_owned = num_owned if livestock_code == livestock_code_num
	recode `l'_owned (. = 0)
	replace livestock_code_num = livestock_code_num+1
}


//have one observation for each household, with separate counts of each livestock type
keep *owned FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num centre_code livestock_code weight state
drop num_owned

*Generating counts of HH with each number of animals
quietly summarize weight
gen wgt_sum = r(sum)

local livestock_types cattle buffalo short_mammals equines poultry other cow_buff  // Short mammals includes sheep, goat, pig, rabbit and similar. Equine includes horse, elephant, camel and similar. 

gen cow_buff_owned = cattle_owned + buffalo_owned

preserve
foreach lt of local livestock_types{
	gen has_`lt' = `lt'_owned > 0 
	replace has_`lt' = has_`lt'*weight
	quietly summarize has_`lt'
	replace has_`lt' = r(sum)
	replace has_`lt' = has_`lt'/wgt_sum
}
keep has*
keep if _n==1
save "$IND_SAAHH_final_data\livestock_counts.dta", replace
restore



collapse (sum) *_owned (max)weight , by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num state) 
save "$IND_SAAHH_final_data\livestock_counts_HH.dta", replace

gen ag_hh=0
replace ag_hh=1 if SSS_num!="1" // ag_hh are those were main source of income comes from agriculture


preserve
keep if ag_hh==1

// Estimates by states
*Bihar
tab cattle_owned if state=="Bihar" & cattle_owned > 0  [aw=weight]
tab buffalo_owned if state=="Bihar" & buffalo_owned > 0  [aw=weight] 
tab short_mammals_owned if state=="Bihar" & short_mammals_owned > 0  [aw=weight] 
tab equines_owned if state=="Bihar" & equines_owned > 0  [aw=weight] 
tab poultry_owned if state=="Bihar" & poultry_owned > 0  [aw=weight]  // There is one respondant that reported 2000 units
tab cow_buff_owned if state=="Bihar" & cow_buff_owned > 0  [aw=weight] 
total weight if cow_buff_owned>0 & cow_buff_owned<=10 & state=="Bihar" 
total weight if short_mammals_owned>0 & short_mammals_owned <=10 & state=="Bihar"   
total weight if poultry_owned>0 & poultry_owned <=50 & state=="Bihar"   

*Odisha
tab cattle_owned if state=="Odisha" & cattle_owned > 0  [aw=weight] 
tab buffalo_owned if state=="Odisha" & buffalo_owned > 0  [aw=weight] 
tab short_mammals_owned if state=="Odisha" & short_mammals_owned > 0  [aw=weight] 
tab equines_owned if state=="Odisha" & equines_owned > 0  [aw=weight] 
tab poultry_owned if state=="Odisha" & poultry_owned > 0  [aw=weight] 
tab cow_buff_owned if state=="Odisha" & cow_buff_owned > 0  [aw=weight] 
total weight if cow_buff_owned>0 & cow_buff_owned<=10 & state=="Odisha" 
total weight if short_mammals_owned>0 & short_mammals_owned <=10 & state=="Odisha"   
total weight if poultry_owned>0 & poultry_owned <=50 & state=="Odisha" 

*UttarPradesh
tab cattle_owned if state=="UttarPradesh" & cattle_owned > 0  [aw=weight] 
tab buffalo_owned if state=="UttarPradesh" & buffalo_owned > 0  [aw=weight] 
tab short_mammals_owned if state=="UttarPradesh" & short_mammals_owned > 0  [aw=weight] 
tab equines_owned if state=="UttarPradesh" & equines_owned > 0  [aw=weight] 
tab poultry_owned if state=="UttarPradesh" & poultry_owned > 0  [aw=weight] 
tab cow_buff_owned if state=="UttarPradesh" & cow_buff_owned > 0  [aw=weight] 
total weight if cow_buff_owned>0 & cow_buff_owned<=10 & state=="UttarPradesh" 
total weight if short_mammals_owned>0 & short_mammals_owned <=10 & state=="UttarPradesh"   
total weight if poultry_owned>0 & poultry_owned <=50 & state=="UttarPradesh" 

*India
tab cattle_owned if cattle_owned > 0  [aw=weight] 
tab buffalo_owned if buffalo_owned > 0  [aw=weight] 
tab short_mammals_owned if short_mammals_owned > 0  [aw=weight] 
tab equines_owned if equines_owned > 0  [aw=weight] 
tab poultry_owned if poultry_owned > 0  [aw=weight] 
tab cow_buff_owned if cow_buff_owned > 0  [aw=weight] 
total weight if cow_buff_owned>0 & cow_buff_owned<=10 
total weight if short_mammals_owned>0 & short_mammals_owned <=10
total weight if poultry_owned>0 & poultry_owned <=50
restore

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

save "$IND_SAAHH_final_data\livestock_estimates.dta", replace

/*
*************************
* SSP memo estimates
*************************

* use "$IND_SAAHH_final_data\livestock_estimates.dta", clear
* merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "$IND_SAAHH_final_data\farm_size.dta", assert(3)

use "$IND_SAAHH_final_data\farm_size.dta", clear
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "$IND_SAAHH_final_data\livestock_estimates.dta", keep(1 3)


gen AND_SSP = .
recode cow_buff_owned short_mammals_owned poultry_owned /* farm_size_category */ (.=0)
replace AND_SSP =0 if /*((cow_buff_owned>10) | (short_mammals_owned>10) | (poultry_owned>50)) & */ farm_size_category>2 
replace AND_SSP =1 if (cow_buff_owned<=10) & (short_mammals_owned<=10) & (poultry_owned<=50) & farm_size_category<=2  // check why size is increasing

preserve
keep if ag_hh==1
tab AND_SSP if state=="Bihar"  [aw=weight] 
tab AND_SSP if state=="Odisha" [aw=weight] 
tab AND_SSP if state=="UttarPradesh" [aw=weight] 
tab AND_SSP [aw=weight] 

total weight if AND_SSP==1 & state=="Bihar" 
total weight if AND_SSP==1 & state=="Odisha"  
total weight if AND_SSP==1 & state=="UttarPradesh"  
total weight if AND_SSP==1 

sum farm_size_category if farm_size_category<=2 & state=="Bihar" [aw=weight] 
sum farm_size_category if farm_size_category<=2 & state=="Odisha" [aw=weight] 
sum farm_size_category if farm_size_category<=2 & state=="UttarPradesh" [aw=weight] 
sum farm_size_category if farm_size_category<=2 [aw=weight] 

tab farm_size_category if state=="Bihar"  [aw=weight] 
tab farm_size_category if state=="Odisha" [aw=weight] 
tab farm_size_category if state=="UttarPradesh" [aw=weight] 
tab farm_size_category [aw=weight] 

*only matched
tab AND_SSP if state=="Bihar" & _merge==3 [aw=weight] 
tab AND_SSP if state=="Odisha" & _merge==3  [aw=weight] 
tab AND_SSP if state=="UttarPradesh" & _merge==3  [aw=weight] 
tab AND_SSP if _merge==3 [aw=weight] 

sum AND_SSP if state=="Bihar" & _merge==3 [aw=weight] 
sum AND_SSP if state=="Odisha" & _merge==3  [aw=weight] 
sum AND_SSP if state=="UttarPradesh" & _merge==3  [aw=weight] 
sum AND_SSP if _merge==3 [aw=weight] 

sum farm_size_category if farm_size_category<=2 & state=="Bihar" & _merge==3  [aw=weight] 
sum farm_size_category if farm_size_category<=2 & state=="Odisha" & _merge==3 [aw=weight] 
sum farm_size_category if farm_size_category<=2 & state=="UttarPradesh" & _merge==3  [aw=weight] 
sum farm_size_category if farm_size_category<=2 & _merge==3 [aw=weight] 
restore

/*
gen OR_SSP = .
replace OR_SSP =0 if ((cow_buff_owned>10 & cattle_owned > 0) | (short_mammals_owned>10 & short_mammals_owned > 0) | (poultry_owned>50 & poultry_owned > 0)) & farm_size_category>2 
replace OR_SSP =1 if (cow_buff_owned<=10 & cattle_owned > 0) | (short_mammals_owned<=10 & short_mammals_owned > 0) | (poultry_owned<=50 & poultry_owned > 0) & farm_size_category<=2 
*/
*/



************************
*TOTAL HOUSEHOLD INCOME 
************************

********************************
*PURCHASED INPUT EXPENSES 
********************************
*crop inputs expenses
*Visit 2
use "$IND_SAAHH_raw_data\Visit 2\level_08.dta", clear

gen centre_code = substr(H1,1,3)
gen FSU_num = substr(H1,4,5)
gen round = substr(H1,9,2)
gen schedule = substr(H1,11,3)
gen sample = substr(H1,14,1)
gen sector = substr(H1,15,1)
gen NSS_region = substr(H1,16,3)
gen district = substr(H1,19,2)
gen stratum = substr(H1,21,2)
gen substratum = substr(H1,23,2)
gen subround = substr(H1,25,1)
gen FOD_subregion = substr(H1,26,4)
gen SSS_num = substr(H1,30,1)
gen HHID_num = substr(H1,31,2)
gen visit_num = substr(H1,33,1)

destring H*, replace
ren H13 weight_v2
replace weight_v2=weight_v2/100

keep if H4==22 | H4==6 | H4==7 | H4==8 |  H4==9 |  H4==10 |  H4==11 |  H4==12 |  H4==13   // 6-fertilizer, 7-biofertilizer, 8-manures, 9-chemicals, 10-biopesticides, 11-diesel, 12-electricity, 13-irrigation
recode H9 H10 (.=0)

gen fertilizer_used2=1 if H4==6 & H7!=.
gen chemicals_used2=1 if (H4==9 | H4==10) & H7!=. // chemicals and biopesticides
gen manure_used2=1 if (H4==7 | H4==8) & H7!=. // manure and biofertilizers
gen diesel_used2=1 if H4==11 & H7!=.
gen electricity_used2=1 if H4==12 & H7!=.


recode fertilizer_used2 chemicals_used2 manure_used2 diesel_used2 electricity_used2 (.=0)

gen crop_expenses_v2 = H9 if H4==22
gen crop_imputed_exp_v2 = H10 if H4==22
gen crop_exp_tot_v2 = H9 + H10 

collapse (sum) crop_expenses_v2 crop_imputed_exp_v2 crop_exp_tot_v2 (firstnm) weight_v2 (max) fertilizer_used2 chemicals_used2 manure_used2 diesel_used2 electricity_used2, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

tempfile block_07_v2
save `block_07_v2'

*Visit 1
use "$IND_SAAHH_raw_data\Visit 1\level_08.dta", clear  


gen centre_code = substr(H1,1,3)
gen FSU_num = substr(H1,4,5)
gen round = substr(H1,9,2)
gen schedule = substr(H1,11,3)
gen sample = substr(H1,14,1)
gen sector = substr(H1,15,1)
gen NSS_region = substr(H1,16,3)
gen district = substr(H1,19,2)
gen stratum = substr(H1,21,2)
gen substratum = substr(H1,23,2)
gen subround = substr(H1,25,1)
gen FOD_subregion = substr(H1,26,4)
gen SSS_num = substr(H1,30,1)
gen HHID_num = substr(H1,31,2)
gen visit_num = substr(H1,33,1)

destring H*, replace
ren H13 weight_v1
replace weight_v1=weight_v1/100


keep if H4==22 | H4==6 | H4==7 | H4==8 |  H4==9 |  H4==10 |  H4==11 |  H4==12 |  H4==13   // 6-fertilizer, 7-biofertilizer, 8-manures, 9-chemicals, 10-biopesticides, 11-diesel, 12-electricity, 13-irrigation
recode H9 H10 (.=0)

gen fertilizer_used1=1 if H4==6 & H7!=.
gen chemicals_used1=1 if (H4==9 | H4==10) & H7!=. // chemicals and biopesticides
gen manure_used1=1 if (H4==7 | H4==8) & H7!=. // manure and biofertilizers
gen diesel_used1=1 if H4==11 & H7!=.
gen electricity_used1=1 if H4==12 & H7!=.


recode fertilizer_used1 chemicals_used1 manure_used1 diesel_used1 electricity_used1 (.=0)

gen crop_expenses_v1 = H9
gen crop_imputed_exp_v1 = H10
gen crop_exp_tot_v1 = H9 + H10 

collapse (sum) crop_expenses_v1 crop_imputed_exp_v1 crop_exp_tot_v1 (firstnm) weight_v1 (max) fertilizer_used1 chemicals_used1 manure_used1 diesel_used1 electricity_used1, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

gen ag_hh=0
replace ag_hh=1 if SSS_num!="1" // ag_hh are those were main source of income comes from agriculture

merge 1:1  FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using `block_07_v2', nogen keepusing(crop_exp_tot_v2 crop_expenses_v2 crop_imputed_exp_v2 fertilizer_used2 chemicals_used2 manure_used2 diesel_used2 electricity_used2 weight_v2)

gen crop_expenses = crop_expenses_v1 + crop_expenses_v2
gen crop_imputed_exp = crop_imputed_exp_v1 + crop_imputed_exp_v2
gen crop_exp_tot = crop_exp_tot_v1 + crop_exp_tot_v2
gen fertilizer_used = max(fertilizer_used1, fertilizer_used2)
gen chemicals_used = max(chemicals_used1, chemicals_used2)
gen manure_used = max(manure_used1, manure_used2)
gen diesel_used = max(diesel_used1, diesel_used2)
gen electricity_used = max(electricity_used1, electricity_used2)

lab var crop_expenses "Reported paid out expenses in Rs."
lab var crop_imputed_exp "Reported self imputed expenses in Rs."
lab var crop_exp_tot "Reported paid out + self imputed expenses in Rs."

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

global wins_var_top1 "crop_expenses crop_imputed_exp"
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other (change the local variable to the state variable to winsorize for each state)
foreach v of varlist crop_expenses crop_imputed_exp {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight_v2] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist crop_expenses crop_imputed_exp {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight_v2], p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. 
	}

gen ws_crop_exp_tot = ws_crop_expenses + ws_crop_imputed_exp
gen wn_crop_exp_tot = wn_crop_expenses + wn_crop_imputed_exp
gen crop_expenses_2017ppp = ((crop_exp_tot*(1+ $inflation ))/ $cons_ppp_dollar )
gen ws_crop_expenses_2017ppp = ((ws_crop_exp_tot * (1+ $inflation))) / $cons_ppp_dollar
gen wn_crop_expenses_2017ppp = ((wn_crop_exp_tot * (1+ $inflation))) / $cons_ppp_dollar

lab var crop_expenses_2017ppp "Crop input expenses in 2017 consumption PPP $"
lab var ws_crop_expenses_2017ppp "Crop input expenses in 2017 consumption PPP $ - Winsorized at top 1% - state"
lab var wn_crop_expenses_2017ppp "Crop input expenses in 2017 consumption PPP $ - Winsorized at top 1% - national"
lab var crop_exp_tot "Crop input expenses in rupees"
lab var ws_crop_exp_tot "Crop input expenses in rupees - Winsorized at top 1% - state"
lab var wn_crop_exp_tot "Crop input expenses in rupees - Winsorized at top 1% - national"


lab var fertilizer_used "1= HH used fertilizer during the survey period"
lab var chemicals_used "1= HH used chemicals during the survey period"
lab var manure_used1 "1= HH used manure during the survey period"
lab var diesel_used1 "1= HH used diesel during the survey period"
lab var electricity_used "1= HH used electricity during the survey period"

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

preserve
keep if ag_hh==1
sum wn_crop_expenses_2017ppp [aw= weight_v2] // national estimates all
sum ws_crop_expenses_2017ppp [aw= weight_v2] if state=="Bihar"
sum ws_crop_expenses_2017ppp [aw= weight_v2] if state=="Odisha" 
sum ws_crop_expenses_2017ppp [aw= weight_v2] if state=="UttarPradesh" 

sum wn_crop_exp_tot [aw= weight_v2] // national estimates all
sum ws_crop_exp_tot [aw= weight_v2] if state=="Bihar"
sum ws_crop_exp_tot [aw= weight_v2] if state=="Odisha" 
sum ws_crop_exp_tot [aw= weight_v2] if state=="UttarPradesh" 
restore

save "${IND_SAAHH_created_data}/purchased_input_expenses.dta", replace


******************************
*GROSS CROP INCOME (REVENUE) 
******************************

*Level_06 - quantity produced
use "$IND_SAAHH_raw_data\Visit 1\level_06.dta", clear 
append using "$IND_SAAHH_raw_data\Visit 2\level_06.dta"

gen centre_code = substr(F1,1,3)
gen FSU_num = substr(F1,4,5)
gen round = substr(F1,9,2)
gen schedule = substr(F1,11,3)
gen sample = substr(F1,14,1)
gen sector = substr(F1,15,1)
gen NSS_region = substr(F1,16,3)
gen district = substr(F1,19,2)
gen stratum = substr(F1,21,2)
gen substratum = substr(F1,23,2)
gen subround = substr(F1,25,1)
gen FOD_subregion = substr(F1,26,4)
gen SSS_num = substr(F1,30,1)
gen HHID_num = substr(F1,31,2)
gen visit_num = substr(F1,33,1)

tempfile level_06
save `level_06'

*Level_07 - sales information
use "$IND_SAAHH_raw_data\Visit 1\level_07.dta", clear 
append using "$IND_SAAHH_raw_data\Visit 2\level_07.dta"

gen centre_code = substr(G1,1,3)
gen FSU_num = substr(G1,4,5)
gen round = substr(G1,9,2)
gen schedule = substr(G1,11,3)
gen sample = substr(G1,14,1)
gen sector = substr(G1,15,1)
gen NSS_region = substr(G1,16,3)
gen district = substr(G1,19,2)
gen stratum = substr(G1,21,2)
gen substratum = substr(G1,23,2)
gen subround = substr(G1,25,1)
gen FOD_subregion = substr(G1,26,4)
gen SSS_num = substr(G1,30,1)
gen HHID_num = substr(G1,31,2)
gen visit_num = substr(G1,33,1)

ren G4 F4

merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num visit_num F4 using `level_06', nogen 

gen crop_id = ""
replace crop_id = "rice" 			if F5=="0101"
replace crop_id = "maize" 			if F5=="0104"
replace crop_id = "wheat" 			if F5=="0106"
replace crop_id = "jute" 			if F5=="1102"
replace crop_id = "cotton" 			if F5=="1101"
replace crop_id = "sugarcane" 		if F5=="0401"
replace crop_id = "coconut" 		if F5=="1006"
replace crop_id = "soybean" 		if F5=="1009"
replace crop_id = "other fodder" 	if F5=="1488"
replace crop_id = "potato" 			if F5=="0701"
replace crop_id = "other leafy veg" if F5=="0810"
replace crop_id = "rapeseed&mustard" if F5=="1004"
replace crop_id = "sorghum" 		if F5=="0102"
replace crop_id = "millet" 			if F5=="0103"
replace crop_id = "chick pea" 		if F5=="0201"
replace crop_id = "urad beans" 		if F5=="0203"
replace crop_id = "mung beans" 		if F5=="0204"
replace crop_id = "groundnut" 		if F5=="1001"
replace crop_id = "cassava" 		if F5=="0702"

drop F1 G1
destring F* G*, replace

ren F6 unit
ren F11 kg_produced
ren F19 weight
ren F16 major_disp_value_rs
ren G6 other_disp_value_rs
ren G8 all_disp_value_rs
ren G13 value_prod_rs 

sum kg_produced
replace kg_produced=. if unit!="1"   // ignoring those observations with no declared unit (4,160 changes / 120,679 obs)
sum kg_produced
recode F7 F9 F15 F17 (.=0)

gen ha_harvested = (F7 + F9) * 0.404686  // Area irrigated (F7) and un-irrigated (F9) 1 acre = 0.404686 ha
gen kg_sold = F15 + F17 // Major disposal (F15) and other disposals (F17)
destring weight, replace
gen weight_v1 = weight if visit_num=="1"
gen weight_v2 = weight if visit_num=="2"

gen Item = ""
replace Item = "1st Crop" 			if F4==1
replace Item = "2nd Crop" 			if F4==2
replace Item = "3rd Crop" 			if F4==3
replace Item = "4th Crop" 			if F4==4
replace Item = "Not top 4 crops"    if F4==5
replace Item = "All Crops" 			if F4==9

gen group_id = "Out"  // groups to allocate within FS and HV crops
replace group_id="Low" if inrange(F5, 0101, 0199) // Cereals
replace group_id="Low" if inrange(F5, 0201, 0299) // Pulses
replace group_id="Low" if inrange(F5, 0701, 0799) // Tubers
replace group_id="Low" if inrange(F5, 1401, 1499) // Fodders
replace group_id="High" if inrange(F5, 0501, 0599) // Spices
replace group_id="High" if inrange(F5, 0601, 0699) // Fruits
replace group_id="High" if inrange(F5, 0801, 0899) // Vegetables
replace group_id="High" if inrange(F5, 1001, 1099) // Oilseeds
replace group_id="High" if inrange(F5, 1501, 1599) // Plantation 
replace group_id="High" if inrange(F5, 1601, 1699) // Flowers
replace group_id="High" if inrange(F5, 1701, 1799) // Medicinal

keep FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num kg_produced weight_v1 weight_v2 crop_id ha_harvested kg_sold value_prod_rs all_disp_value_rs Item group_id
save "${IND_SAAHH_created_data}/crop_level_income.dta", replace

* Creating the share of high value crop produced
gen value_prod_rs_low = value_prod_rs if group_id=="Low"
gen value_prod_rs_high = value_prod_rs if group_id=="High"

gen grew_rice=1 if crop_id == "rice"

collapse (sum) kg_produced ha_harvested kg_sold value_prod_rs all_disp_value_rs value_prod_rs_low value_prod_rs_high (firstnm) weight_v2 weight_v1 (max) grew_*, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)
gen weight = weight_v2/100
replace weight = weight_v1/100 if weight_v2==.

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

global wins_var_top1 "kg_produced ha_harvested kg_sold value_prod_rs all_disp_value_rs value_prod_rs_low value_prod_rs_high"
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist $wins_var_top1 {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist $wins_var_top1 {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight], p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. 
	}

gen ws_total_crop_income_rs = ws_value_prod_rs
gen wn_total_crop_income_rs = wn_value_prod_rs
gen share_production_high_value = value_prod_rs_high / (value_prod_rs_high+value_prod_rs_low)

gen total_crop_income_2017ppp = ((value_prod_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen ws_total_crop_income_2017ppp = ((ws_value_prod_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen wn_total_crop_income_2017ppp = ((wn_value_prod_rs * (1+ $inflation)) / $cons_ppp_dollar)

lab var total_crop_income_2017ppp "Value of crop sales in 2017 consumption PPP $ (including by-products)"
lab var ws_total_crop_income_2017ppp "Value of crop sales in 2017 consumption PPP $ (including by-products) - Winsorized at top 1% - state"
lab var wn_total_crop_income_2017ppp "Value of crop sales in 2017 consumption PPP $ (including by-products) - Winsorized at top 1% - national"

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace
recode grew_* (.=0)
save "${IND_SAAHH_created_data}/crop_income.dta", replace




******************************
*NET CROP INCOME  
******************************

use "${IND_SAAHH_created_data}/crop_income.dta", clear
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}/purchased_input_expenses.dta", nogen keep (3) // 8 unmatched observations dropped

gen net_revenue_impl_rs = value_prod_rs - crop_exp_tot
lab var net_revenue_impl_rs "Net revenue including implicit costs (in rupees)"
gen net_revenue_expl_rs = value_prod_rs - crop_expenses
lab var net_revenue_expl_rs "Net revenue excluding implicit costs (in rupees)"

gen net_revenue_impl_2017ppp = ((net_revenue_impl_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen net_revenue_expl_2017ppp = ((net_revenue_expl_rs * (1+ $inflation)) / $cons_ppp_dollar)

lab var net_revenue_impl_2017ppp "Net revenue including implicit costs (in 2016 consumption PPP $)"
lab var net_revenue_expl_2017ppp "Net revenue excluding implicit costs (in 2016 consumption PPP $)"

gen ws_net_revenue_impl_rs = ws_value_prod_rs - ws_crop_exp_tot
gen wn_net_revenue_impl_rs = wn_value_prod_rs - wn_crop_exp_tot
gen ws_net_revenue_expl_rs = ws_value_prod_rs - ws_crop_expenses
gen wn_net_revenue_expl_rs = wn_value_prod_rs - wn_crop_expenses

global wins_state_top1_bott1 ws_net_revenue_impl_rs ws_net_revenue_expl_rs
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist $wins_state_top1_bott1 {
	local  l`v' : var lab `v'
	label  var  `v'  "`l`v'' - Winsorized top and bottom 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(1 99) 
		replace `v'= r(r1) if `v' < r(r1) & `v'!=. & state=="`j'"
		replace `v'= r(r2) if `v' > r(r2) & `v'!=. & state=="`j'"
	}
}

global wins_nat_top1_bott1 wn_net_revenue_impl_rs wn_net_revenue_expl_rs
foreach v of varlist $wins_nat_top1_bott1 {
	local  l`v' : var lab `v'
	label  var  `v'  "`l`v'' - Winsorized top and bottom 1% - state"
	_pctile `v' [aw=weight], p(1 99) 
	replace `v'= r(r1) if `v' < r(r1) & `v'!=.
	replace `v'= r(r2) if `v' > r(r2) & `v'!=.
	}

lab var ws_net_revenue_impl_rs "Net revenue including implicit costs (in rupees) - Winsorized at top and bottom 1% - state"
lab var wn_net_revenue_impl_rs "Net revenue including implicit costs (in rupees) - Winsorized at top and bottom 1% - national"
lab var ws_net_revenue_expl_rs "Net revenue excluding implicit costs (in rupees) - Winsorized at top and bottom 1% - state"
lab var wn_net_revenue_expl_rs "Net revenue excluding implicit costs (in rupees) - Winsorized at top and bottom 1% - national"

gen ws_net_revenue_impl_2017ppp = ((ws_net_revenue_impl_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen ws_net_revenue_expl_2017ppp = ((ws_net_revenue_expl_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen wn_net_revenue_impl_2017ppp = ((wn_net_revenue_impl_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen wn_net_revenue_expl_2017ppp = ((wn_net_revenue_expl_rs * (1+ $inflation)) / $cons_ppp_dollar)

lab var ws_net_revenue_impl_2017ppp "Net crop revenue including implicit costs (in 2016 consumption PPP $) - Winsorized at top and bottom 1% - state"
lab var ws_net_revenue_expl_2017ppp "Net crop revenue excluding implicit costs (in 2016 consumption PPP $) - Winsorized at top and bottom 1% - state"
lab var wn_net_revenue_impl_2017ppp "Net crop revenue including implicit costs (in 2016 consumption PPP $) - Winsorized at top and bottom 1% - national"
lab var wn_net_revenue_expl_2017ppp "Net crop revenue excluding implicit costs (in 2016 consumption PPP $) - Winsorized at top and bottom 1% - national"

/* reporting average net revenuew for focus states
preserve
keep if ag_hh==1
sum wn_net_revenue_impl_2017ppp [aw= weight_v2] // national estimates all
sum ws_net_revenue_impl_2017ppp [aw= weight_v2] if state=="Bihar"
sum ws_net_revenue_impl_2017ppp [aw= weight_v2] if state=="Odisha" 
sum ws_net_revenue_impl_2017ppp [aw= weight_v2] if state=="UttarPradesh"
*/

save "${IND_SAAHH_created_data}/India_SAAHH_2018_netcropincome.dta", replace


******************************************
*SHARE OF CROP OUTPUT VALUE SOLD    // There are 140 households that reported more output sold than produced, and 46 that reported more sales than value of production // estimates are much lower than CACP  
******************************************
*only for 4 main crops reporte in each household
use "${IND_SAAHH_created_data}/crop_level_income.dta", clear
drop if Item== "All Crops" | Item=="Not top 4 crops"
*encode  crop_id, gen(list_crop_id)
*gen cereal =1 if inlist(list_crop_id, 13, 18, 6, 7, 14)
*keep if cereal==1
collapse (sum) kg_produced ha_harvested kg_sold value_prod_rs all_disp_value_rs (firstnm) weight_v2 weight_v1, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

global wins_var_top1 "kg_produced ha_harvested kg_sold value_prod_rs all_disp_value_rs"
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist $wins_var_top1 {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight_v2] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist $wins_var_top1 {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight_v2] if state=="`j'", p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=.
	}


gen output_sold_ratio_s = 0
gen output_sold_ratio_n = 0
replace output_sold_ratio_s = ws_kg_sold / ws_kg_produced if ws_kg_produced!=0
replace output_sold_ratio_n = wn_kg_sold / wn_kg_produced if wn_kg_produced!=0
gen value_sold_ratio_s = 0
gen value_sold_ratio_n = 0
replace value_sold_ratio_s = ws_all_disp_value_rs / ws_value_prod_rs if ws_value_prod_rs!=0
replace value_sold_ratio_n = wn_all_disp_value_rs / wn_value_prod_rs if wn_value_prod_rs!=0
lab var output_sold_ratio_s "Ratio of the quantity (kg) of crop product sold for reported crops - state" 
lab var value_sold_ratio_s "Ratio of the value of crop product sold for reported crops - state" 
lab var output_sold_ratio_s "Ratio of the quantity (kg) of crop product sold for reported crops - national" 
lab var value_sold_ratio_s "Ratio of the value of crop product sold for reported crops - national" 

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

save "${IND_SAAHH_created_data}/India_SAAHH_2018_share_crop_sold.dta", replace

/* Summary statistics sale_ratio for focus states
sum value_sold_ratio_n [aw= weight_v2] if value_sold_ratio_n>=0 // national estimates all
sum value_sold_ratio_s [aw= weight_v2] if state=="Bihar" & value_sold_ratio_s>=0
sum value_sold_ratio_s [aw= weight_v2] if state=="Odisha"  & value_sold_ratio_s>=0
sum value_sold_ratio_s [aw= weight_v2] if state=="UttarPradesh"  & value_sold_ratio_s>=0
*/
 
*************************************
** GROSS LAND PRODUCTIVITY
*************************************

use "${IND_SAAHH_created_data}/crop_income.dta", clear // Income data
*Land productivity
gen g_land_prod_rs = value_prod_rs / ha_harvested
lab var g_land_prod_rs "Gross income from crop production (includes by-products) per ha cultivated (in rupees)" // for all crops
gen g_ws_land_prod_rs = ws_value_prod_rs / ws_ha_harvested
gen g_wn_land_prod_rs = wn_value_prod_rs / wn_ha_harvested
lab var g_ws_land_prod_rs "Gross income from crop production (includes by-products) per ha cultivated (in rupees) - Winsorized top 1% - state" // for all crops
lab var g_wn_land_prod_rs "Gross income from crop production (includes by-products) per ha cultivated (in rupees) - Winsorized top 1% - national" // for all crops

global wins_var_top1 "g_ws_land_prod_rs"
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist g_ws_land_prod_rs {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight_v2] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

global wins_var_top1 "g_wn_land_prod_rs"
foreach v of varlist g_wn_land_prod_rs {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight_v2], p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. 
	}

gen ws_g_ws_land_prod_2017ppp = (ws_g_ws_land_prod_rs * (1+ $inflation)) / $cons_ppp_dollar
gen wn_g_wn_land_prod_2017ppp = (wn_g_wn_land_prod_rs * (1+ $inflation)) / $cons_ppp_dollar
lab var ws_g_ws_land_prod_2017ppp "Winsorized gross income from crop production (includes by-products) per ha cultivated (2017 consumption PPP $) - Winsorized top 1% - state" // for all crops
lab var wn_g_wn_land_prod_2017ppp "Winsorized gross income from crop production (includes by-products) per ha cultivated (2017 consumption PPP $) - Winsorized top 1% - national" // for all crops

replace ws_ha_harvested = wn_ha_harvested if ws_ha_harvested > wn_ha_harvested // merging both winsorizations to create the land weights
gen land_weight = weight_v2 * ws_ha_harvested

* Summary statistics gross land productivity sample weights
sum wn_g_wn_land_prod_2017ppp [aw= weight_v2]
sum ws_g_ws_land_prod_2017ppp [aw= weight_v2] if state=="Bihar"
sum ws_g_ws_land_prod_2017ppp [aw= weight_v2] if state=="Odisha" 
sum ws_g_ws_land_prod_2017ppp [aw= weight_v2] if state=="UttarPradesh" 

* Summary statistics gross land productivity sample + hectares weights
sum wn_g_wn_land_prod_2017ppp [aw= land_weight]
sum ws_g_ws_land_prod_2017ppp [aw= land_weight] if state=="Bihar"
sum ws_g_ws_land_prod_2017ppp [aw= land_weight] if state=="Odisha" 
sum ws_g_ws_land_prod_2017ppp [aw= land_weight] if state=="UttarPradesh" 

save "${IND_SAAHH_created_data}/India_SAAHH_2018_productivity.dta", replace



*****************************************
*  Yield for selected crops and states
*****************************************

use "${IND_SAAHH_created_data}/crop_level_income.dta", clear
destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

collapse (sum) ha_harvested kg_produced  (firstnm) weight_v1 weight_v2 , by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num crop_id)
gen NSS_Region = NSS_region 
destring NSS_Region, replace
gen state="Other"
replace state="Bihar" if NSS_Region==101 | NSS_Region==102
replace state="Odisha" if NSS_Region==211 | NSS_Region==212 | NSS_Region==213
replace state="UttarPradesh" if NSS_Region==91 | NSS_Region==92 | NSS_Region==93 | NSS_Region==94 | NSS_Region==95
gen focus_state = 1 if state=="Bihar" | state=="Odisha" | state=="UttarPradesh"
replace state="AndhraPradesh" if NSS_Region==281 | NSS_Region==282 | NSS_Region==283
replace state="ArunachalPradesh" if NSS_Region==121 
replace state="Assam" if NSS_Region==181 | NSS_Region==182 | NSS_Region==183 | NSS_Region==184
replace state="Chhattisgarh" if NSS_Region==221 | NSS_Region==222 | NSS_Region==223
*replace state="Jharkhand" if NSS_Region==201 | NSS_Region==202
replace state="MadhyaPradesh" if NSS_Region==231 | NSS_Region==232 | NSS_Region==233 | NSS_Region==234 | NSS_Region==235 | NSS_Region==236
replace state="Nagaland" if NSS_Region==131
replace state="Rajasthan" if NSS_Region==81 | NSS_Region==82 | NSS_Region==83 | NSS_Region==84 | NSS_Region==85
gen non_focus_agstate = 1 if inlist(state, "AndhraPradesh", "ArunachalPradesh", "Assam",  "Chhattisgarh", "MadhyaPradesh", "Nagaland", "Rajasthan")
gen other_states = 1 if non_focus_agstate!=1 & focus_state!=1
gen sub_group = "focus_state" if focus_state==1
replace sub_group = "non_focus_agstate" if non_focus_agstate==1
replace sub_group = "other" if other_states==1

gen Weight_SC = weight_v2
replace Weight_SC = weight_v1 if weight_v2==.

global wins_var_top1 "kg_produced ha_harvested"
levelsof state, local(list_state) // Winsorization groups are Ag States
foreach v of varlist $wins_var_top1 {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight_v2] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist $wins_var_top1 {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight_v2], p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. 
	}

gen yield_kg = ws_kg_produced/ws_ha_harvested
*For Rice
gen yield_kg_rice = ws_kg_produced/ws_ha_harvested if crop_id=="rice"
gen yield_kg_grdnt = ws_kg_produced/ws_ha_harvested if crop_id=="groundnut"
gen yield_kg_maize = ws_kg_produced/ws_ha_harvested if crop_id=="maize"
gen yield_kg_millet = ws_kg_produced/ws_ha_harvested if crop_id=="millet"
gen yield_kg_sorg = ws_kg_produced/ws_ha_harvested if crop_id=="sorghum"
gen yield_kg_wheat = ws_kg_produced/ws_ha_harvested if crop_id=="wheat"
gen yield_kg_cassava = ws_kg_produced/ws_ha_harvested if crop_id=="cassava"





global wins_var_top1 "yield_kg yield_kg_rice yield_kg_grdnt yield_kg_maize yield_kg_millet yield_kg_sorg yield_kg_wheat yield_kg_cassava"
levelsof state, local(list_state) // Winsorization groups are Ag states 
foreach v of varlist $wins_var_top1 {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight_v2] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist $wins_var_top1 {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight_v2], p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. 
	}

	
merge m:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "$IND_SAAHH_final_data\farm_size.dta", nogen keep(1 3) force // Farm size data 
	
label var ws_yield_kg "Household total output for land cultivated winsorised"
label var ws_yield_kg_rice "Household total output for land cultivated winsorised for rice"

tabstat ws_yield_kg_rice [aw=Weight_SC ] if (state=="Bihar" | state=="Odisha" | state=="UttarPradesh"), by(state) s(mean median N)
tabstat ws_yield_kg_rice [aw=Weight_SC ] if farm_size<=2 , by(sub_group) s(mean median N)
tabstat ws_yield_kg_rice [aw=Weight_SC ] if farm_size<=2, by(state) s(mean median N)

save "${IND_SAAHH_created_data}/India_SAAHH_2019_yields.dta", replace


***************************************
*ANNUAL FARM INCOME (LIVESTOCK) 					
****************************************

*Animal Income (including own consumption but might need to be revised as it might include holdings) 

use "$IND_SAAHH_raw_data\Visit 1\level_11.dta", clear 
append using "$IND_SAAHH_raw_data\Visit 2\level_11.dta"

gen centre_code = substr(K1,1,3)
gen FSU_num = substr(K1,4,5)
gen round = substr(K1,9,2)
gen schedule = substr(K1,11,3)
gen sample = substr(K1,14,1)
gen sector = substr(K1,15,1)
gen NSS_region = substr(K1,16,3)
gen district = substr(K1,19,2)
gen stratum = substr(K1,21,2)
gen substratum = substr(K1,23,2)
gen subround = substr(K1,25,1)
gen FOD_subregion = substr(K1,26,4)
gen SSS_num = substr(K1,30,1)
gen HHID_num = substr(K1,31,2)
gen visit_num = substr(K1,33,1)
ren K4 serial_no

tempfile level_11
save `level_11'

use "$IND_SAAHH_raw_data\Visit 1\level_10.dta", clear 
append using "$IND_SAAHH_raw_data\Visit 2\level_10.dta"

gen centre_code = substr(J1,1,3)
gen FSU_num = substr(J1,4,5)
gen round = substr(J1,9,2)
gen schedule = substr(J1,11,3)
gen sample = substr(J1,14,1)
gen sector = substr(J1,15,1)
gen NSS_region = substr(J1,16,3)
gen district = substr(J1,19,2)
gen stratum = substr(J1,21,2)
gen substratum = substr(J1,23,2)
gen subround = substr(J1,25,1)
gen FOD_subregion = substr(J1,26,4)
gen SSS_num = substr(J1,30,1)
gen HHID_num = substr(J1,31,2)
gen visit_num = substr(J1,33,1)

ren J4 serial_no

merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num serial_no visit_num using `level_11', keep(1 3)

ren J5 own_consumption_Q
ren J6 own_consumption_Rs
ren K7 total_produce_Q
ren K8 total_produce_Rs

destring own_consumption_Q own_consumption_Rs total_produce_Q total_produce_Rs serial_no J15, replace


gen milk_production_Q = 0
replace milk_production_Q = total_produce_Q if serial_no==01
replace milk_production_Q = total_produce_Q if serial_no==02

gen egg_production_Q = 0
replace egg_production_Q = total_produce_Q if serial_no==04

gen lvstk_production_Rs = 0
replace lvstk_production_Rs = total_produce_Rs if serial_no==16

gen weight = J15/100

collapse (sum) milk_production_Q egg_production_Q lvstk_production_Rs (lastnm) weight_v2=weight, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

*Transform bimonthly data to yearly data
replace milk_production_Q = milk_production_Q * 6
replace egg_production_Q = egg_production_Q * 6
replace lvstk_production_Rs = lvstk_production_Rs * 6

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist milk_production_Q egg_production_Q lvstk_production_Rs {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist milk_production_Q egg_production_Q lvstk_production_Rs {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
		_pctile `v' [aw=weight], p(99) 
		replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. 
	}

lab var ws_lvstk_production_Rs "Annualized gross income from livestock production in rupees - Winsorized top 1% - state"
lab var wn_lvstk_production_Rs "Annualized gross income from livestock production in rupees - Winsorized top 1% - national"
gen ws_lvstk_production_2017ppp = ( ws_lvstk_production_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_lvstk_production_2017ppp = ( wn_lvstk_production_Rs * (1+ $inflation) ) / $cons_ppp_dollar
lab var ws_lvstk_production_2017ppp "Winsorized annualized gross income from livestock production (2017 consumption PPP $) - Winsorized top 1% - state" //
lab var wn_lvstk_production_2017ppp "Winsorized annualized gross income from livestock production (2017 consumption PPP $) - Winsorized top 1% - national" //

save "${IND_SAAHH_created_data}\India_SAAHH_2018_animalincome.dta", replace


*Animal Expenses
use "$IND_SAAHH_raw_data\Visit 1\level_12.dta", clear 
append using "$IND_SAAHH_raw_data\Visit 2\level_12.dta"

gen centre_code = substr(L1,1,3)
gen FSU_num = substr(L1,4,5)
gen round = substr(L1,9,2)
gen schedule = substr(L1,11,3)
gen sample = substr(L1,14,1)
gen sector = substr(L1,15,1)
gen NSS_region = substr(L1,16,3)
gen district = substr(L1,19,2)
gen stratum = substr(L1,21,2)
gen substratum = substr(L1,23,2)
gen subround = substr(L1,25,1)
gen FOD_subregion = substr(L1,26,4)
gen SSS_num = substr(L1,30,1)
gen HHID_num = substr(L1,31,2)
gen visit_num = substr(L1,33,1)

ren L4 serial_no
ren L7 lvstk_expenses
ren L8 lvstk_imputed_exp

destring serial_no lvstk_expenses lvstk_imputed_exp L11, replace

gen weight = L11/100

keep if serial_no == 18

gen lvstk_expenses_tot = lvstk_expenses + lvstk_imputed_exp

collapse (sum) lvstk_expenses lvstk_imputed_exp lvstk_expenses_tot (lastnm) weight_v2=weight, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)


*Transform bimonthly data to yearly data
replace lvstk_expenses = lvstk_expenses *6
replace lvstk_imputed_exp = lvstk_imputed_exp  * 6
replace lvstk_expenses_tot = lvstk_expenses_tot * 6

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 


levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist lvstk_expenses lvstk_imputed_exp lvstk_expenses_tot {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist lvstk_expenses lvstk_imputed_exp lvstk_expenses_tot {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight] if state=="`j'", p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=.
	}

lab var ws_lvstk_expenses_tot "Winsorized annualized paid out and imputed expenses from livestock production in rupees - Winsorized top 1% - state"
lab var wn_lvstk_expenses_tot "Winsorized annualized paid out and imputed expenses from livestock production in rupees - Winsorized top 1% - national"

gen ws_lvstk_expenses_tot_2017ppp = ( ws_lvstk_expenses_tot * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_lvstk_expenses_tot_2017ppp = ( wn_lvstk_expenses_tot * (1+ $inflation) ) / $cons_ppp_dollar

lab var ws_lvstk_expenses_tot_2017ppp "Winsorized annualized paid out and imputed expenses from livestock production in 2017 consumption PPP $ - Winsorized top 1% - state" //
lab var wn_lvstk_expenses_tot_2017ppp "Winsorized annualized paid out and imputed expenses from livestock production in 2017 consumption PPP $ - Winsorized top 1% - national" //

save "${IND_SAAHH_created_data}\India_SAAHH_2018_animalexpenses.dta", replace


*Net animal income 
use "${IND_SAAHH_created_data}\India_SAAHH_2018_animalincome.dta", clear 
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}/India_SAAHH_2018_animalexpenses.dta", nogen keep (3) // 8 unmatched observations dropped
gen ag_hh=0
replace ag_hh=1 if SSS_num!="1" 

gen lvstk_net_rev_exp_rs = lvstk_production_Rs - lvstk_expenses
lab var lvstk_net_rev_exp_rs "Livestock production net revenue excluding implicit costs (in rupees)"
gen lvstk_net_rev_tot_rs = lvstk_production_Rs - lvstk_expenses_tot
lab var lvstk_net_rev_tot_rs "Livestock production net revenue including implicit costs (in rupees)"

gen lvstk_net_rev_exp_2017ppp = ((lvstk_net_rev_exp_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen lvstk_net_rev_tot_2017ppp = ((lvstk_net_rev_tot_rs * (1+ $inflation)) / $cons_ppp_dollar)

lab var lvstk_net_rev_tot_2017ppp "Net revenue including implicit costs (in 2017 consumption PPP $)"
lab var lvstk_net_rev_exp_2017ppp "Net revenue excluding implicit costs (in 2017 consumption PPP $)"

gen ws_lvstk_net_rev_exp_rs = ws_lvstk_production_Rs - ws_lvstk_expenses
gen wn_lvstk_net_rev_exp_rs = wn_lvstk_production_Rs - wn_lvstk_expenses
lab var ws_lvstk_net_rev_exp_rs "Livestock production net revenue excluding implicit costs (in rupees)"
lab var wn_lvstk_net_rev_exp_rs "Livestock production net revenue excluding implicit costs (in rupees)"
gen ws_lvstk_net_rev_tot_rs = ws_lvstk_production_Rs - ws_lvstk_expenses_tot
gen wn_lvstk_net_rev_tot_rs = wn_lvstk_production_Rs - wn_lvstk_expenses_tot
lab var ws_lvstk_net_rev_tot_rs "Livestock production net revenue including implicit costs (in rupees)"
lab var wn_lvstk_net_rev_tot_rs "Livestock production net revenue including implicit costs (in rupees)"


global wins_state_top1_bott1 ws_lvstk_net_rev_exp_rs ws_lvstk_net_rev_tot_rs
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist $wins_state_top1_bott1 {
	local  l`v' : var lab `v'
	label  var  `v'  "`l`v'' - Winsorized top and bottom 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(1 99) 
		replace `v'= r(r1) if `v' < r(r1) & `v'!=. & state=="`j'"
		replace `v'= r(r2) if `v' > r(r2) & `v'!=. & state=="`j'"
	}
}

global wins_nat_top1_bott1 wn_lvstk_net_rev_exp_rs wn_lvstk_net_rev_tot_rs
foreach v of varlist $wins_nat_top1_bott1 {
	local  l`v' : var lab `v'
	label  var  `v'  "`l`v'' - Winsorized top and bottom 1% - national"
		_pctile `v' [aw=weight], p(1 99) 
		replace `v'= r(r1) if `v' < r(r1) & `v'!=. & state=="`j'"
		replace `v'= r(r2) if `v' > r(r2) & `v'!=. & state=="`j'"
	}

gen ws_lvstk_net_rev_exp_2017ppp = ((ws_lvstk_net_rev_exp_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen ws_lvstk_net_rev_tot_2017ppp = ((ws_lvstk_net_rev_tot_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen wn_lvstk_net_rev_exp_2017ppp = ((wn_lvstk_net_rev_exp_rs * (1+ $inflation)) / $cons_ppp_dollar)
gen wn_lvstk_net_rev_tot_2017ppp = ((wn_lvstk_net_rev_tot_rs * (1+ $inflation)) / $cons_ppp_dollar)

lab var ws_lvstk_net_rev_tot_2017ppp "Net revenue including implicit costs (in 2017 consumption PPP $)- Winsorized at top 1% - state"
lab var ws_lvstk_net_rev_exp_2017ppp "Net revenue excluding implicit costs (in 2017 consumption PPP $)- Winsorized at top 1% - state"
lab var wn_lvstk_net_rev_tot_2017ppp "Net revenue including implicit costs (in 2017 consumption PPP $)- Winsorized at top 1% - national"
lab var wn_lvstk_net_rev_exp_2017ppp "Net revenue excluding implicit costs (in 2017 consumption PPP $)- Winsorized at top 1% - national"

/* Summary statistics focus states
preserve
keep if ag_hh==1
sum wn_lvstk_net_rev_tot_2017ppp [aw= weight]
sum ws_lvstk_net_rev_tot_2017ppp [aw= weight] if state=="Bihar"
sum ws_lvstk_net_rev_tot_2017ppp [aw= weight] if state=="Odisha" 
sum ws_lvstk_net_rev_tot_2017ppp [aw= weight] if state=="UttarPradesh" 

sum wn_lvstk_net_rev_exp_2017ppp [aw= weight]
sum ws_lvstk_net_rev_exp_2017ppp [aw= weight] if state=="Bihar"
sum ws_lvstk_net_rev_exp_2017ppp [aw= weight] if state=="Odisha" 
sum ws_lvstk_net_rev_exp_2017ppp [aw= weight] if state=="UttarPradesh" 
*/


destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

save "${IND_SAAHH_created_data}\India_SAAHH_2018_animalnetincome.dta", replace 
 
********************
*INCOME FROM WAGES
********************

use "$IND_SAAHH_raw_data\Visit 2\level_02.dta", clear 

gen centre_code = substr(B1,1,3)
gen FSU_num = substr(B1,4,5)
gen round = substr(B1,9,2)
gen schedule = substr(B1,11,3)
gen sample = substr(B1,14,1)
gen sector = substr(B1,15,1)
gen NSS_region = substr(B1,16,3)
gen district = substr(B1,19,2)
gen stratum = substr(B1,21,2)
gen substratum = substr(B1,23,2)
gen subround = substr(B1,25,1)
gen FOD_subregion = substr(B1,26,4)
gen SSS_num = substr(B1,30,1)
gen HHID_num = substr(B1,31,2)
gen visit_num = substr(B1,33,1)

destring B14 B15 B20 B4 B11 B16 B9 B7 B8, replace

recode B9 (2=0)
ren B9 ag_training_v2 // formal ag training  yes = 1

ren B15 inc_pension_Rs_v2
ren B4 person_id

gen inc_self_ag_Rs_v2 = B14 if (B10=="11" | B10=="12" | B10=="21") & B11==01 // self income from crops and livestock holding
gen inc_self_otherag_Rs_v2 = B14 if (B10=="11" | B10=="12" | B10=="21") & (B11==03 | B11==02) // self income from forestry and fishing
gen inc_self_nonag_Rs_v2 = B14 if (B10=="11" | B10=="12" | B10=="21") & (B11>=04) // self income from non agric activities
gen inc_wage_ag_Rs_v2 = B14 if (B10!="11" & B10!="12" & B10!="21") & B11==01 // income from crops and livestock holding
gen inc_wage_otherag_Rs_v2 = B14 if (B10!="11" & B10!="12" & B10!="21") & (B11==03 | B11==02) // income from forestry and fishing
gen inc_wage_nonag_Rs_v2 = B14 if (B10!="11" & B10!="12" & B10!="21") & (B11>=04) // income from non agric activities
gen inc_rent_Rs_v2 = B16 // income from rent or leased-out land


tempfile level_02
save `level_02'

use "$IND_SAAHH_raw_data\Visit 1\level_02.dta", clear 

gen centre_code = substr(B1,1,3)
gen FSU_num = substr(B1,4,5)
gen round = substr(B1,9,2)
gen schedule = substr(B1,11,3)
gen sample = substr(B1,14,1)
gen sector = substr(B1,15,1)
gen NSS_region = substr(B1,16,3)
gen district = substr(B1,19,2)
gen stratum = substr(B1,21,2)
gen substratum = substr(B1,23,2)
gen subround = substr(B1,25,1)
gen FOD_subregion = substr(B1,26,4)
gen SSS_num = substr(B1,30,1)
gen HHID_num = substr(B1,31,2)
gen visit_num = substr(B1,33,1)

destring B14 B15 B20 B4 B11 B16 B9 B7 B8, replace

ren B15 inc_pension_Rs_v1
ren B4 person_id

gen fhh = 0
replace fhh=1 if B5=="1" & B6=="2"
gen age_hoh = B7 if B5=="1"
destring age_hoh, replace

gen educ_hoh = B8 if B5=="1"

gen inc_self_ag_Rs_v1 = B14 if (B10=="11" | B10=="12" | B10=="21") & B11==01 // self income from crops and livestock holding
gen inc_self_otherag_Rs_v1 = B14 if (B10=="11" | B10=="12" | B10=="21") & (B11==03 | B11==02) // self income from forestry and fishing
gen inc_self_nonag_Rs_v1 = B14 if (B10=="11" | B10=="12" | B10=="21") & (B11>=04) // self income from non agric activities
gen inc_wage_ag_Rs_v1 = B14 if (B10!="11" & B10!="12" & B10!="21") & B11==01 // income from crops and livestock holding
gen inc_wage_otherag_Rs_v1 = B14 if (B10!="11" & B10!="12" & B10!="21") & (B11==03 | B11==02) // income from forestry and fishing
gen inc_wage_nonag_Rs_v1 = B14 if (B10!="11" & B10!="12" & B10!="21") & (B11>=04) // income from non agric activities
gen inc_rent_Rs_v1 = B16 // income from rent or leased-out land

recode B9 (2=0)
ren B9 ag_training_v1 // formal ag training  yes = 1


merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num person_id using "`level_02'", nogen update // replacing the weights of visit 1 with those of visit 2 

gen weight = B20/100 
gen ag_hh=0
replace ag_hh=1 if SSS_num!="1" 

gen inc_self_ag_Rs = inc_self_ag_Rs_v1 + inc_self_ag_Rs_v2 
gen inc_self_otherag_Rs = inc_self_otherag_Rs_v1 + inc_self_otherag_Rs_v2 
gen inc_self_nonag_Rs = inc_self_nonag_Rs_v1 + inc_self_nonag_Rs_v2 
gen inc_wage_ag_Rs = inc_wage_ag_Rs_v1 + inc_wage_ag_Rs_v2 
gen inc_wage_otherag_Rs = inc_wage_otherag_Rs_v1 + inc_wage_otherag_Rs_v2 
gen inc_wage_nonag_Rs =inc_wage_nonag_Rs_v1 + inc_wage_nonag_Rs_v2 
gen inc_pension_Rs = inc_pension_Rs_v1 + inc_pension_Rs_v2
gen inc_rent_Rs = inc_rent_Rs_v1 + inc_rent_Rs_v2

egen ag_training = rowmax(ag_training_v1 ag_training_v2)

gen inc_wage_priv_Rs = B14 if (B10=="31") & (B11>=04) // wages not from gov employment program
gen inc_wage_pubMGNREG_Rs = B14 if (B10=="42") & (B11>=04) // wages from gov employment program
gen inc_wage_pubnonMGNREG_Rs = B14 if (B10=="41") & (B11>=04) // wages not from gov employment program



collapse (sum) inc* (max) ag_training fhh age_hoh educ_hoh ag_hh (lastnm) weight_v2=weight, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist inc* {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(99) 
		replace  ws_`v' = r(r1) if  ws_`v' > r(r1) &  ws_`v'!=. & state=="`j'"
	}
}

foreach v of varlist inc* {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top 1% - national"
	_pctile `v' [aw=weight], p(99) 
	replace  wn_`v' = r(r1) if  wn_`v' > r(r1) &  wn_`v'!=. 
	}

lab var ws_inc_self_ag_Rs "Winsorized earning from self employment in crop and livestock activities in rupees - top 1% - state"
lab var ws_inc_self_otherag_Rs "Winsorized earning from self employment in fishing or forestry activities in rupees - top 1% - state"
lab var ws_inc_self_nonag_Rs "Winsorized earning from self employment in non-agricultural activities in rupees - top 1% - state"
lab var ws_inc_wage_ag_Rs "Winsorized wage earning from employment in crop and livestock activities in rupees - top 1% - state"
lab var ws_inc_wage_otherag_Rs "Winsorized wage earning from employment in forestry and fishing activities in rupees - top 1% - state"
lab var ws_inc_wage_nonag_Rs "Winsorized wage earning from employment in non-agricultural activities in rupees - top 1% - state"
lab var ws_inc_pension_Rs "Winsorized earning from pensions/remittances in rupees - top 1% - state"
lab var ws_inc_rent_Rs "Winsorized earning from rent or leased-out land in rupees - top 1% - state"
lab var wn_inc_self_ag_Rs "Winsorized earning from self employment in crop and livestock activities in rupees - top 1% - national"
lab var wn_inc_self_otherag_Rs "Winsorized earning from self employment in fishing or forestry activities in rupees - top 1% - national"
lab var wn_inc_self_nonag_Rs "Winsorized earning from self employment in non-agricultural activities in rupees - top 1% - national"
lab var wn_inc_wage_ag_Rs "Winsorized wage earning from employment in crop and livestock activities in rupees - top 1% - national"
lab var wn_inc_wage_otherag_Rs "Winsorized wage earning from employment in forestry and fishing activities in rupees - top 1% - national"
lab var wn_inc_wage_nonag_Rs "Winsorized wage earning from employment in non-agricultural activities in rupees - top 1% - national"
lab var wn_inc_pension_Rs "Winsorized earning from pensions/remittances in rupees - top 1% - national"
lab var wn_inc_rent_Rs "Winsorized earning from rent or leased-out land in rupees - top 1% - national"
lab var ag_training "Whether anyone in the household received any formal training in agriculture"

lab var age_hoh "Age of the head of household (visit 2)"
lab var educ_hoh "Highest level of education of the head of household (visit 2)"

gen ws_inc_self_ag_2017ppp = ( ws_inc_self_ag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen ws_inc_self_otherag_2017ppp = ( ws_inc_self_otherag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen ws_inc_self_nonag_2017ppp = ( ws_inc_self_nonag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen ws_inc_wage_ag_2017ppp = ( ws_inc_wage_ag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen ws_inc_wage_otherag_2017ppp = ( ws_inc_wage_otherag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen ws_inc_wage_nonag_2017ppp = ( ws_inc_wage_nonag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen ws_inc_pension_2017ppp = ( ws_inc_pension_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen ws_inc_rent_2017ppp = ( ws_inc_rent_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_self_ag_2017ppp = ( wn_inc_self_ag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_self_otherag_2017ppp = ( wn_inc_self_otherag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_self_nonag_2017ppp = ( wn_inc_self_nonag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_wage_ag_2017ppp = ( wn_inc_wage_ag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_wage_otherag_2017ppp = ( wn_inc_wage_otherag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_wage_nonag_2017ppp = ( wn_inc_wage_nonag_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_pension_2017ppp = ( wn_inc_pension_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_inc_rent_2017ppp = ( wn_inc_rent_Rs * (1+ $inflation) ) / $cons_ppp_dollar


gen inc_wage_priv_2017ppp = ( ws_inc_wage_priv_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen inc_wage_pubMGNREG_2017ppp = ( ws_inc_wage_pubMGNREG_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen inc_wage_pubnonMGNREG_2017ppp = ( ws_inc_wage_pubnonMGNREG_Rs * (1+ $inflation) ) / $cons_ppp_dollar


lab var ws_inc_self_ag_2017ppp "Winsorized earning from self employment in crop and livestock activities in 2017 consumption PPP - top 1% - state $"
lab var ws_inc_self_otherag_2017ppp "Winsorized earning from self employment in fishing or forestry activities in 2017 consumption PPP $ - top 1% - state"
lab var ws_inc_self_nonag_2017ppp "Winsorized earning from self employment in non-agricultural activities in 2017 consumption PPP $ - top 1% - state"
lab var ws_inc_wage_ag_2017ppp "Winsorized wage earning from employment in crop and livestock activities in 2017 consumption PPP $ - top 1% - state"
lab var ws_inc_wage_otherag_2017ppp "Winsorized wage earning from employment in forestry and fishing activities in 2017 consumption PPP $ - top 1% - state"
lab var ws_inc_wage_nonag_2017ppp "Winsorized wage earning from employment in non-agricultural activities in 2017 consumption PPP $ - top 1% - state"
lab var ws_inc_pension_2017ppp "Winsorized earning from pensions/remittances in 2017 consumption PPP $ - top 1% - state"
lab var ws_inc_rent_2017ppp "Winsorized earning from rent or leased-out land in 2017 consumption PPP $ - top 1% - state"

lab var wn_inc_self_ag_2017ppp "Winsorized earning from self employment in crop and livestock activities in 2017 consumption PPP $ - top 1% - national"
lab var wn_inc_self_otherag_2017ppp "Winsorized earning from self employment in fishing or forestry activities in 2017 consumption PPP $ - top 1% - national"
lab var wn_inc_self_nonag_2017ppp "Winsorized earning from self employment in non-agricultural activities in 2017 consumption PPP $ - top 1% - national"
lab var wn_inc_wage_ag_2017ppp "Winsorized wage earning from employment in crop and livestock activities in 2017 consumption PPP $ - top 1% - national"
lab var wn_inc_wage_otherag_2017ppp "Winsorized wage earning from employment in forestry and fishing activities in 2017 consumption PPP $ - top 1% - national"
lab var wn_inc_wage_nonag_2017ppp "Winsorized wage earning from employment in non-agricultural activities in 2017 consumption PPP $ - top 1% - national"
lab var wn_inc_pension_2017ppp "Winsorized earning from pensions/remittances in 2017 consumption PPP $ - top 1% - national"
lab var wn_inc_rent_2017ppp "Winsorized earning from rent or leased-out land in 2017 consumption PPP $ - top 1% - national"

gen ws_inc_empl_all_Rs = ws_inc_self_nonag_Rs + ws_inc_wage_ag_Rs + ws_inc_wage_otherag_Rs + ws_inc_wage_nonag_Rs + ws_inc_pension_Rs 
lab var ws_inc_empl_all_Rs "Winsorized earning from employment (all sources including self- and pensions) in rupees - top 1% - state"
gen wn_inc_empl_all_Rs = wn_inc_self_nonag_Rs + wn_inc_wage_ag_Rs + wn_inc_wage_otherag_Rs + wn_inc_wage_nonag_Rs + wn_inc_pension_Rs 
lab var wn_inc_empl_all_Rs "Winsorized earning from employment (all sources including self- and pensions) in rupees - top 1% - national"

gen ws_inc_empl_all_2017ppp = ws_inc_self_nonag_2017ppp + ws_inc_wage_ag_2017ppp + ws_inc_wage_otherag_2017ppp + ws_inc_wage_nonag_2017ppp + ws_inc_pension_2017ppp 
lab var ws_inc_empl_all_2017ppp "Winsorized earning from employment (all sources including self- and pensions) in 2017 consumption PPP $ - top 1% - state"
gen wn_inc_empl_all_2017ppp = wn_inc_self_nonag_2017ppp + wn_inc_wage_ag_2017ppp + wn_inc_wage_otherag_2017ppp + wn_inc_wage_nonag_2017ppp + wn_inc_pension_2017ppp 
lab var wn_inc_empl_all_2017ppp "Winsorized earning from employment (all sources including self- and pensions) in 2017 consumption PPP $ - top 1% - national"

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

sum wn_inc_empl_all_2017ppp [aw= weight]  if ag_hh==1 
sum ws_inc_empl_all_2017ppp [aw= weight] if state=="Bihar" &  ag_hh==1 
sum ws_inc_empl_all_2017ppp [aw= weight] if state=="Odisha" &  ag_hh==1  
sum ws_inc_empl_all_2017ppp [aw= weight] if state=="UttarPradesh" &  ag_hh==1  


save "${IND_SAAHH_created_data}\India_SAAHH_2018_wage_income.dta", replace


***********************************
*ANNUAL FARM INCOME (TOTAL) 				
***********************************

use "${IND_SAAHH_created_data}\India_SAAHH_2018_netcropincome.dta", clear
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_animalnetincome.dta", nogen // 
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_wage_income.dta", nogen // 

recode ws_lvstk_net_rev_tot_2017ppp ws_net_revenue_impl_2017ppp ws_inc_self_ag_2017ppp ws_inc_self_otherag_2017ppp ws_inc_wage_ag_2017ppp ws_inc_wage_otherag_2017ppp (.=0)
recode wn_lvstk_net_rev_tot_2017ppp wn_net_revenue_impl_2017ppp wn_inc_self_ag_2017ppp wn_inc_self_otherag_2017ppp wn_inc_wage_ag_2017ppp wn_inc_wage_otherag_2017ppp (.=0)
egen ws_total_farm_netincome_2017ppp = rowtotal(ws_lvstk_net_rev_tot_2017ppp ws_net_revenue_impl_2017ppp /* ws_inc_self_ag_2017ppp ws_inc_self_otherag_2017ppp */ ws_inc_wage_ag_2017ppp ws_inc_wage_otherag_2017ppp)
egen wn_total_farm_netincome_2017ppp = rowtotal(wn_lvstk_net_rev_tot_2017ppp wn_net_revenue_impl_2017ppp /* wn_inc_self_ag_2017ppp wn_inc_self_otherag_2017ppp */ wn_inc_wage_ag_2017ppp wn_inc_wage_otherag_2017ppp)

preserve
keep if ag_hh==1
sum wn_total_farm_netincome_2017ppp [aw= weight]
sum ws_total_farm_netincome_2017ppp [aw= weight] if state=="Bihar"
sum ws_total_farm_netincome_2017ppp [aw= weight] if state=="Odisha" 
sum ws_total_farm_netincome_2017ppp [aw= weight] if state=="UttarPradesh" 
restore

save "${IND_SAAHH_created_data}\India_SAAHH_2018_total_farm_net_income.dta", replace

*****************************
*NET NON-FARM BUSINESS INCOME 
*****************************

use "$IND_SAAHH_raw_data\Visit 1\level_13.dta", clear 
append using "$IND_SAAHH_raw_data\Visit 2\level_13.dta"

gen centre_code = substr(M1,1,3)
gen FSU_num = substr(M1,4,5)
gen round = substr(M1,9,2)
gen schedule = substr(M1,11,3)
gen sample = substr(M1,14,1)
gen sector = substr(M1,15,1)
gen NSS_region = substr(M1,16,3)
gen district = substr(M1,19,2)
gen stratum = substr(M1,21,2)
gen substratum = substr(M1,23,2)
gen subround = substr(M1,25,1)
gen FOD_subregion = substr(M1,26,4)
gen SSS_num = substr(M1,30,1)
gen HHID_num = substr(M1,31,2)
gen visit_num = substr(M1,33,1)

keep if M4=="99"

destring  M8 M11, replace

gen nonfarm_net_bus_income_Rs = M8*6 // non-farm business income
gen weight = M11/100 
gen ag_hh=0
replace ag_hh=1 if SSS_num!="1" 

collapse (sum) nonfarm_net_bus_income_Rs  (max) ag_hh weight_v2=weight, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 

global wins_state_top1_bott1 "nonfarm_net_bus_income_Rs"
levelsof state, local(list_state) // Winsorization groups are Bihar, Odisha, UP and Other 
foreach v of varlist $wins_state_top1_bott1 {
	gen ws_`v'=`v'
	local  l`v' : var lab `v'
	label  var  ws_`v'  "`l`v'' - Winsorized top and bottom 1% - state"
	foreach j of local list_state  {
		_pctile `v' [aw=weight] if state=="`j'", p(1 99) 
		replace ws_`v'= r(r1) if ws_`v' < r(r1) & ws_`v'!=. & state=="`j'"
		replace ws_`v' = r(r2) if  ws_`v' > r(r2) & ws_`v'!=. & state=="`j'"
	}
}

global wins_nat_top1_bott1 "nonfarm_net_bus_income_Rs"
foreach v of varlist $wins_nat_top1_bott1 {
	gen wn_`v'=`v'
	local  l`v' : var lab `v'
	label  var  wn_`v'  "`l`v'' - Winsorized top and bottom 1% - national"
		_pctile `v' [aw=weight], p(1 99) 
		replace wn_`v'= r(r1) if wn_`v' < r(r1) & wn_`v'!=. 
		replace wn_`v' = r(r2) if  wn_`v' > r(r2) & wn_`v'!=. 
	}

gen ws_nonfarm_net_bus_inc_2017ppp = ( ws_nonfarm_net_bus_income_Rs * (1+ $inflation) ) / $cons_ppp_dollar
gen wn_nonfarm_net_bus_inc_2017ppp = ( wn_nonfarm_net_bus_income_Rs * (1+ $inflation) ) / $cons_ppp_dollar
lab var ws_nonfarm_net_bus_inc_2017ppp "Winsorized annualized earning from non-farm business in 2016 consumption PPP $ - state"
lab var wn_nonfarm_net_bus_inc_2017ppp "Winsorized annualized earning from non-farm business in 2016 consumption PPP $ - national"

preserve
keep if ag_hh==1
sum wn_nonfarm_net_bus_inc_2017ppp [aw= weight]
sum ws_nonfarm_net_bus_inc_2017ppp [aw= weight] if state=="Bihar"
sum ws_nonfarm_net_bus_inc_2017ppp [aw= weight] if state=="Odisha" 
sum ws_nonfarm_net_bus_inc_2017ppp [aw= weight] if state=="UttarPradesh"
restore

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace


save "${IND_SAAHH_created_data}\India_SAAHH_2018_nonfarm_netincome.dta", replace



***********************************************
*TOTAL HOUSEHOLD INCOME (ALL SOURCES)
***********************************************

use "$IND_SAAHH_final_data\adulteq.dta", clear
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "$IND_SAAHH_final_data\farm_size.dta", nogen keep(1 3) // Farm size data
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_wage_income.dta", nogen // Labor income
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_nonfarm_netincome.dta", nogen // Non-farm business net income
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_animalnetincome.dta", nogen // Animal farming net income
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_netcropincome.dta", nogen // Crops net income
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_total_farm_net_income.dta", nogen // Total farm net income
recode ws_nonfarm_net_bus_inc_2017ppp ws_lvstk_net_rev_tot_2017ppp ws_net_revenue_impl_2017ppp ws_inc_empl_all_2017ppp (.=0)
recode wn_nonfarm_net_bus_inc_2017ppp wn_lvstk_net_rev_tot_2017ppp wn_net_revenue_impl_2017ppp wn_inc_empl_all_2017ppp (.=0)

egen ws_total_hh_income = rowtotal(ws_nonfarm_net_bus_inc_2017ppp ws_lvstk_net_rev_tot_2017ppp ws_net_revenue_impl_2017ppp ws_inc_empl_all_2017ppp ws_inc_rent_2017ppp) // total hh income to use for state estimates
egen wn_total_hh_income = rowtotal(wn_nonfarm_net_bus_inc_2017ppp wn_lvstk_net_rev_tot_2017ppp wn_net_revenue_impl_2017ppp wn_inc_empl_all_2017ppp wn_inc_rent_2017ppp) // total hh income to use for national estimates

gen ws_nonfarm_netincome_2017ppp = ws_total_hh_income - ws_total_farm_netincome_2017ppp
gen ws_total_hh_inc_cap = ws_total_hh_income / HH_members

gen wn_nonfarm_netincome_2017ppp = wn_total_hh_income - wn_total_farm_netincome_2017ppp
gen wn_total_hh_inc_cap = wn_total_hh_income / HH_members

lab var ws_total_hh_inc_cap "Winsorized net income per household member from any sources in 2016 consumption PPP $ - state"
lab var wn_total_hh_inc_cap "Winsorized net income per household member from any sources in 2016 consumption PPP $ - national"

preserve
keep if SSS_num!=1
* All farmers
sum wn_total_hh_inc_cap [aw= weight] // India estimates
sum ws_total_hh_inc_cap [aw= weight] if state=="Bihar"
sum ws_total_hh_inc_cap [aw= weight] if state=="Odisha" 
sum ws_total_hh_inc_cap [aw= weight] if state=="UttarPradesh"

* All farmers HH income
sum wn_total_hh_income [aw= weight] // India estimates
sum ws_total_hh_income [aw= weight] if state=="Bihar"
sum ws_total_hh_income [aw= weight] if state=="Odisha" 
sum ws_total_hh_income [aw= weight] if state=="UttarPradesh"

* SSPs (<2ha) non livestock definition
sum wn_total_hh_inc_cap [aw= weight] if farm_size_category<=2 // India estimates
sum ws_total_hh_inc_cap [aw= weight] if farm_size_category<=2 & state=="Bihar"
sum ws_total_hh_inc_cap [aw= weight] if farm_size_category<=2 & state=="Odisha" 
sum ws_total_hh_inc_cap [aw= weight] if farm_size_category<=2 & state=="UttarPradesh"
restore

save "${IND_SAAHH_created_data}\India_SAAHH_2018_all_income.dta", replace


***********************
* EXTENSION SERVICES
***********************

/* sources list:
1 - progressive farmer
2 - input dealers
3 - gov extension
4 - Krishi Vigyan Kendra
5 - Ag university/college
6 - private agents
7 - veterinary department
8 - cooperatives
9 - farmer producer organizations (FPO)
10 - private processors
11 - Agr clinics & Ag Bus centers
12 - NGOs
13 - Kisan Call Center
14 - print median
15 - radio/TV/ other electronic media
16 - smart phone apps based
*/

use "$IND_SAAHH_raw_data/Visit 2/level_17.dta", clear

gen centre_code = substr(q1,1,3)
gen FSU_num = substr(q1,4,5)
gen round = substr(q1,9,2)
gen schedule = substr(q1,11,3)
gen sample = substr(q1,14,1)
gen sector = substr(q1,15,1)
gen NSS_region = substr(q1,16,3)
gen district = substr(q1,19,2)
gen stratum = substr(q1,21,2)
gen substratum = substr(q1,23,2)
gen subround = substr(q1,25,1)
gen FOD_subregion = substr(q1,26,4)
gen SSS_num = substr(q1,30,1)
gen HHID_num = substr(q1,31,2)
gen visit_num = substr(q1,33,1)

ren q2 level
rename q4 source
rename q5 yesno
ren q10 weight
ren q6 type
label var yesno "1 = yes, 2 = no"
ren q7 followed
destring followed, replace
recode followed (2=0)
label var followed "1 = yes, 0 = no"

destring source, replace
destring yesno type, replace
destring weight, replace
replace weight = weight/100

gen exten_pub_cont = 0
gen exten_priv_cont = 0
gen exten_media_cont = 0 
gen exten_mobile_app = 0
gen exten_f2f_cont = 0
gen exten_ngo_cont = 0
gen exten_cont_dig = 0
gen exten_cont_trad = 0
gen exten_cont_any = 0

replace exten_pub_cont = 1 if (source==3 | source==4 | source==5 | source==7 | source==13) & yesno==1   // =1 if farmer was contacted by a gov extension agent(3), krishi vigyan Kendra(4), ag university/college(5), veterinary dept(7), or Kisan Call Centre(13)
replace exten_priv_cont = 1 if (source==2 | source==6 | source==10 | source==11) & yesno==1   // =1 if farmer was contacted by input dealers(2), priv comm agents(6), private processors(10), ag bus centre(11). 
replace exten_ngo_cont = 1 if (source==1 | source==8 | source==9 | source==12) & yesno==1   // =1 if farmer was contacted by NGO(8), farm prod org(9), NGO(12), Progressive farmer(1). 
replace exten_media_cont = 1 if (source==14 | source==15) & yesno==1 // =1 if farmer declared using print media(14) or radio/TV/other electronic media(15)
replace exten_f2f_cont = 1 if (source==1) & yesno==1 // =1 if farmer received advise from progressive farmer (f2f)
replace exten_mobile_app = 1 if (source==16) & yesno==1 // =1 if farmer declared using smart phone apps based information(16)
replace exten_cont_dig = 1 if (source==16 | source==13 | source== 15 ) & yesno==1 // =1 if farmer declared using smart phone apps based information(16), Kisan call center (13) or electronic media (15)
replace exten_cont_trad = 1 if ((source>=2 & source<=12) | source==14) & yesno==1 // =1 if no digital
replace exten_cont_any = 1 if (exten_pub_cont==1 | exten_priv_cont == 1 | exten_media_cont==1 | exten_f2f_cont==1 | exten_ngo_cont==1 | exten_mobile_app==1  )  

* By type of information from any contact
gen ext_cont_seed = 0 
replace ext_cont_seed = 1 if exten_cont_any==1 & type==11
gen ext_cont_fert = 0 
replace ext_cont_fert = 1 if exten_cont_any==1 & type==12
gen ext_cont_crops = 0 
replace ext_cont_crops = 1 if exten_cont_any==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk = 0 
replace ext_cont_lvstk = 1 if exten_cont_any==1 & (type==21 | type==22 | type==23 | type==24 | type==29)
gen ext_cont_fish = 0 
replace ext_cont_fish = 1 if exten_cont_any==1 & (type==31 | type==32 | type==33 | type==39)

*  By type of information from Traditional
gen ext_cont_seed_trad = 0 
replace ext_cont_seed_trad = 1 if exten_cont_trad==1 & type==11
gen ext_cont_fert_trad = 0 
replace ext_cont_fert_trad = 1 if exten_cont_trad==1 & type==12
gen ext_cont_crops_trad = 0 
replace ext_cont_crops_trad = 1 if exten_cont_trad==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk_trad = 0 
replace ext_cont_lvstk_trad = 1 if exten_cont_trad==1 & (type==21 | type==22 | type==23 | type==24 | type==29)

*  By type of information from Digital
gen ext_cont_seed_dig = 0 
replace ext_cont_seed_dig = 1 if exten_cont_dig==1 & type==11
gen ext_cont_fert_dig = 0 
replace ext_cont_fert_dig = 1 if exten_cont_dig==1 & type==12
gen ext_cont_crops_dig = 0 
replace ext_cont_crops_dig = 1 if exten_cont_dig==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk_dig = 0 
replace ext_cont_lvstk_dig = 1 if exten_cont_dig==1 & (type==21 | type==22 | type==23 | type==24 | type==29)

*  By type of information from F2F
gen ext_cont_seed_f2f = 0 
replace ext_cont_seed_f2f = 1 if exten_f2f_cont==1 & type==11
gen ext_cont_fert_f2f = 0 
replace ext_cont_fert_f2f = 1 if exten_f2f_cont==1 & type==12
gen ext_cont_crops_f2f = 0 
replace ext_cont_crops_f2f = 1 if exten_f2f_cont==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk_f2f = 0 
replace ext_cont_lvstk_f2f = 1 if exten_f2f_cont==1 & (type==21 | type==22 | type==23 | type==24 | type==29)


* Creating extension indicator by source
levelsof source, local(levels)
foreach l of local levels {
		gen ext_`l'_dum=0
    	replace ext_`l'_dum = 1 if source==`l' & yesno==1
	    gen ext_`l'_foll=0 if ext_`l'_dum == 1
		replace ext_`l'_foll = 1 if followed==1 & ext_`l'_dum == 1
}


foreach v of varlist ext* weight followed {
	ren `v' v2_`v'
		}

collapse (max) v2_* , by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

tempfile module_05_v2
save `module_05_v2'

use "$IND_SAAHH_raw_data/Visit 1/level_17.dta", clear

gen centre_code = substr(q1,1,3)
gen FSU_num = substr(q1,4,5)
gen round = substr(q1,9,2)
gen schedule = substr(q1,11,3)
gen sample = substr(q1,14,1)
gen sector = substr(q1,15,1)
gen NSS_region = substr(q1,16,3)
gen district = substr(q1,19,2)
gen stratum = substr(q1,21,2)
gen substratum = substr(q1,23,2)
gen subround = substr(q1,25,1)
gen FOD_subregion = substr(q1,26,4)
gen SSS_num = substr(q1,30,1)
gen HHID_num = substr(q1,31,2)
gen visit_num = substr(q1,33,1)

ren q2 level
rename q4 source
rename q5 yesno
ren q10 weight
ren q6 type
label var yesno "1 = yes, 2 = no"
ren q7 followed
destring followed, replace
recode followed (2=0)
label var followed "1 = yes, 0 = no"
destring source, replace
destring yesno type, replace
destring weight, replace
replace weight = weight/100

gen exten_pub_cont = 0
gen exten_priv_cont = 0
gen exten_media_cont = 0 
gen exten_mobile_app = 0
gen exten_f2f_cont = 0
gen exten_ngo_cont = 0
gen exten_cont_dig = 0
gen exten_cont_trad = 0
gen exten_cont_any = 0

replace exten_pub_cont = 1 if (source==3 | source==4 | source==5 | source==7 | source==13) & yesno==1   // =1 if farmer was contacted by a gov extension agent(3), krishi vigyan Kendra(4), ag university/college(5), veterinary dept(7), or Kisan Call Centre(13)
replace exten_priv_cont = 1 if (source==2 | source==6 | source==10 | source==11) & yesno==1   // =1 if farmer was contacted by input dealers(2), priv comm agents(6), private processors(10), ag bus centre(11). 
replace exten_ngo_cont = 1 if (source==1 | source==8 | source==9 | source==12) & yesno==1   // =1 if farmer was contacted by NGO(8), farm prod org(9), NGO(12), Progressive farmer(1). 
replace exten_media_cont = 1 if (source==14 | source==15) & yesno==1 // =1 if farmer declared using print media(14) or radio/TV/other electronic media(15)
replace exten_f2f_cont = 1 if (source==1) & yesno==1 // =1 if farmer received advise from progressive farmer (f2f)
replace exten_mobile_app = 1 if (source==16) & yesno==1 // =1 if farmer declared using smart phone apps based information(16)
replace exten_cont_dig = 1 if (source==16 | source==13 | source== 15 ) & yesno==1 // =1 if farmer declared using smart phone apps based information(16), Kisan call center (13) or electronic media (15)
replace exten_cont_trad = 1 if ((source>=2 & source<=12) | source==14) & yesno==1 // =1 if no digital
replace exten_cont_any = 1 if (exten_pub_cont==1 | exten_priv_cont == 1 | exten_media_cont==1 | exten_f2f_cont==1 | exten_ngo_cont==1 )  

* By type of information from any contact
gen ext_cont_seed = 0 
replace ext_cont_seed = 1 if exten_cont_any==1 & type==11
gen ext_cont_fert = 0 
replace ext_cont_fert = 1 if exten_cont_any==1 & type==12
gen ext_cont_crops = 0 
replace ext_cont_crops = 1 if exten_cont_any==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk = 0 
replace ext_cont_lvstk = 1 if exten_cont_any==1 & (type==21 | type==22 | type==23 | type==24 | type==29)
gen ext_cont_fish = 0 
replace ext_cont_fish = 1 if exten_cont_any==1 & (type==31 | type==32 | type==33 | type==39)

*  By type of information from Traditional
gen ext_cont_seed_trad = 0 
replace ext_cont_seed_trad = 1 if exten_cont_trad==1 & type==11
gen ext_cont_fert_trad = 0 
replace ext_cont_fert_trad = 1 if exten_cont_trad==1 & type==12
gen ext_cont_crops_trad = 0 
replace ext_cont_crops_trad = 1 if exten_cont_trad==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk_trad = 0 
replace ext_cont_lvstk_trad = 1 if exten_cont_trad==1 & (type==21 | type==22 | type==23 | type==24 | type==29)

*  By type of information from Digital
gen ext_cont_seed_dig = 0 
replace ext_cont_seed_dig = 1 if exten_cont_dig==1 & type==11
gen ext_cont_fert_dig = 0 
replace ext_cont_fert_dig = 1 if exten_cont_dig==1 & type==12
gen ext_cont_crops_dig = 0 
replace ext_cont_crops_dig = 1 if exten_cont_dig==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk_dig = 0 
replace ext_cont_lvstk_dig = 1 if exten_cont_dig==1 & (type==21 | type==22 | type==23 | type==24 | type==29)

*  By type of information from F2F
gen ext_cont_seed_f2f = 0 
replace ext_cont_seed_f2f = 1 if exten_f2f_cont==1 & type==11
gen ext_cont_fert_f2f = 0 
replace ext_cont_fert_f2f = 1 if exten_f2f_cont==1 & type==12
gen ext_cont_crops_f2f = 0 
replace ext_cont_crops_f2f = 1 if exten_f2f_cont==1 & (type==11 | type==12 | type==13 | type==14 | type==15 | type==19)
gen ext_cont_lvstk_f2f = 0 
replace ext_cont_lvstk_f2f = 1 if exten_f2f_cont==1 & (type==21 | type==22 | type==23 | type==24 | type==29)


* Creating extension indicator by source
levelsof source, local(levels)
foreach l of local levels {
		gen ext_`l'_dum=0
    	replace ext_`l'_dum = 1 if source==`l' & yesno==1
	    gen ext_`l'_foll=0 if ext_`l'_dum == 1
		replace ext_`l'_foll = 1 if followed==1 & ext_`l'_dum == 1
}

collapse (max) ext* followed (firstnm) weight, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num)

ren weight weight_v1
merge 1:1  FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using `module_05_v2', nogen 
gen state= "Other" 
replace state= "Bihar" if NSS_region=="101"  | NSS_region=="102" 
replace state= "Odisha" if NSS_region=="211" | NSS_region=="212" | NSS_region=="213" 
replace state= "UttarPradesh" if NSS_region=="091" | NSS_region=="092" | NSS_region=="093" | NSS_region=="094" | NSS_region=="095" 


quietly destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace
merge 1:1  FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_wage_income.dta", nogen keepusing(fhh)

ren v2_weight weight

foreach v of varlist ext* followed {
	replace `v' = v2_`v' if v2_`v'==1
		}

drop v2_*

*Label variables
label var exten_pub_cont "Household had contact with public extension"
label var exten_priv_cont "Household had contact with private extension"
label var exten_ngo_cont "Household had contact with cooperatives, producers organizations or NGOs extension"
label var exten_media_cont "Household had contact with media extension"
label var exten_f2f_cont "Household had contact with Progressive Farmer extension"
label var exten_cont_any "Household had contact with any type of extension"
label var exten_cont_trad "Household had contact with extension using traditional means"
label var exten_cont_dig "Household had contact with extension using digital means"

* Summary statistics
gen ag_hh=0
replace ag_hh=1 if SSS_num!=1 // ag_hh are those were main source of income comes from agriculture
keep if ag_hh==1

* Extension contact: Pub + Priv + Media + Dig + F2F + Any (overlapping)
sum exten_pub_cont exten_priv_cont exten_ngo_cont exten_media_cont exten_cont_trad exten_cont_dig exten_f2f_cont exten_cont_any  [aw= weight] // national estimates all
sum exten_pub_cont exten_priv_cont exten_ngo_cont exten_media_cont exten_cont_trad exten_cont_dig exten_f2f_cont exten_cont_any  [aw= weight] if state=="Bihar" // Bihar
sum exten_pub_cont exten_priv_cont exten_ngo_cont exten_media_cont exten_cont_trad exten_cont_dig exten_f2f_cont exten_cont_any [aw= weight] if state=="Odisha"  // Odisha
sum exten_pub_cont exten_priv_cont exten_ngo_cont exten_media_cont exten_cont_trad exten_cont_dig exten_f2f_cont exten_cont_any  [aw= weight] if state=="UttarPradesh"  // UP


/*
** Reporting extension contact by type of information

*Any
sum exten_cont_any ext_cont_seed ext_cont_fert ext_cont_crops ext_cont_lvstk   [aw= weight] // national estimates all
sum exten_cont_any ext_cont_seed ext_cont_fert ext_cont_crops ext_cont_lvstk  [aw= weight] if state=="Bihar" // Bihar
sum exten_cont_any ext_cont_seed ext_cont_fert ext_cont_crops ext_cont_lvstk  [aw= weight] if state=="Odisha"  // Odisha
sum exten_cont_any ext_cont_seed ext_cont_fert ext_cont_crops ext_cont_lvstk [aw= weight] if state=="UttarPradesh"  // UP

*Traditional
sum exten_cont_trad ext_cont_seed_trad ext_cont_fert_trad ext_cont_crops_trad ext_cont_lvstk_trad   [aw= weight] // national estimates all
sum exten_cont_trad ext_cont_seed_trad ext_cont_fert_trad ext_cont_crops_trad ext_cont_lvstk_trad  [aw= weight] if state=="Bihar" // Bihar
sum exten_cont_trad ext_cont_seed_trad ext_cont_fert_trad ext_cont_crops_trad ext_cont_lvstk_trad   [aw= weight] if state=="Odisha"  // Odisha
sum exten_cont_trad ext_cont_seed_trad ext_cont_fert_trad ext_cont_crops_trad ext_cont_lvstk_trad  [aw= weight] if state=="UttarPradesh"  // UP

*Digital
sum exten_cont_dig ext_cont_seed_dig ext_cont_fert_dig ext_cont_crops_dig ext_cont_lvstk_dig   [aw= weight] // national estimates all
sum exten_cont_dig ext_cont_seed_dig ext_cont_fert_dig ext_cont_crops_dig ext_cont_lvstk_dig  [aw= weight] if state=="Bihar" // Bihar
sum exten_cont_dig ext_cont_seed_dig ext_cont_fert_dig ext_cont_crops_dig ext_cont_lvstk_dig   [aw= weight] if state=="Odisha"  // Odisha
sum exten_cont_dig ext_cont_seed_dig ext_cont_fert_dig ext_cont_crops_dig ext_cont_lvstk_dig  [aw= weight] if state=="UttarPradesh"  // UP

*F2F
sum exten_f2f_cont ext_cont_seed_f2f ext_cont_fert_f2f ext_cont_crops_f2f ext_cont_lvstk_f2f   [aw= weight] // national estimates all
sum exten_f2f_cont ext_cont_seed_f2f ext_cont_fert_f2f ext_cont_crops_f2f ext_cont_lvstk_f2f  [aw= weight] if state=="Bihar" // Bihar
sum exten_f2f_cont ext_cont_seed_f2f ext_cont_fert_f2f ext_cont_crops_f2f ext_cont_lvstk_f2f   [aw= weight] if state=="Odisha"  // Odisha
sum exten_f2f_cont ext_cont_seed_f2f ext_cont_fert_f2f ext_cont_crops_f2f ext_cont_lvstk_f2f  [aw= weight] if state=="UttarPradesh"  // UP


* Extension contact by source (all sources)
sum ext_*_dum [aw= weight] if fhh==1
sum ext_*_dum [aw= weight] if state=="Bihar" & fhh==1 // Bihar
sum ext_*_dum [aw= weight] if state=="Odisha" & fhh==1   // Odisha
sum ext_*_dum [aw= weight] if state=="UttarPradesh" & fhh==1   // UP

sum ext_*_foll [aw= weight] if fhh==1
sum ext_*_foll [aw= weight] if state=="Bihar" & fhh==1 // Bihar
sum ext_*_foll [aw= weight] if state=="Odisha" & fhh==1   // Odisha
sum ext_*_foll [aw= weight] if state=="UttarPradesh" & fhh==1   // UP
*/
save "${IND_SAAHH_created_data}/India_SAAHH_2018_extension_services.dta", replace

****************************	
* FINANCIAL SERVICES 
****************************

*Use of crop insurance by farmers that produced crops 
use "$IND_SAAHH_raw_data\Visit 1\level_18.dta", clear // particulars of other aspects of farming during July to December 2012
append using "$IND_SAAHH_raw_data\Visit 2\level_18.dta"

gen centre_code = substr(R1,1,3)
gen FSU_num = substr(R1,4,5)
gen round = substr(R1,9,2)
gen schedule = substr(R1,11,3)
gen sample = substr(R1,14,1)
gen sector = substr(R1,15,1)
gen NSS_region = substr(R1,16,3)
gen district = substr(R1,19,2)
gen stratum = substr(R1,21,2)
gen substratum = substr(R1,23,2)
gen subround = substr(R1,25,1)
gen FOD_subregion = substr(R1,26,4)
gen SSS_num = substr(R1,30,1)
gen HHID_num = substr(R1,31,2)
gen visit_num = substr(R1,33,1)

destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num R9 R10, replace
destring R6 R16, replace
gen crop_insured = 0
gen weight = R16/100
replace crop_insured = 1 if (R6==1 | R6==2 )   // =1 if farmer insured at least one crop during the period

* Adding questions related to climate losses
gen crop_losses = R9
recode R9 (2=0)
gen crop_losses_drought = R9 if R10==1
gen crop_losses_flood = R9 if R10==3
gen crop_losses_climate = R9 if R10==1 | R10==3
recode crop_losses_* (.=0)



collapse (max) crop_insured crop_losses* (max) weight, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num) // 

merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}\India_SAAHH_2018_netcropincome.dta", nogen // Households that produced crops
sum crop_insured [aw= weight] // India estimates
sum crop_insured [aw= weight] if state=="Bihar"
sum crop_insured [aw= weight] if state=="Odisha" 
sum crop_insured [aw= weight] if state=="UttarPradesh"



save "${IND_SAAHH_created_data}\India_SAAHH_2018_insurance.dta", replace


*Use of loan services by all farmers 

use "$IND_SAAHH_raw_data\Visit 1\level_15.dta", clear // particulars of other aspects of farming during July to December 2012

gen centre_code = substr(O1,1,3)
gen FSU_num = substr(O1,4,5)
gen round = substr(O1,9,2)
gen schedule = substr(O1,11,3)
gen sample = substr(O1,14,1)
gen sector = substr(O1,15,1)
gen NSS_region = substr(O1,16,3)
gen district = substr(O1,19,2)
gen stratum = substr(O1,21,2)
gen substratum = substr(O1,23,2)
gen subround = substr(O1,25,1)
gen FOD_subregion = substr(O1,26,4)
gen SSS_num = substr(O1,30,1)
gen HHID_num = substr(O1,31,2)
gen visit_num = substr(O1,33,1)

rename O5 nature_of_loan
rename O6 source_of_loan
destring nature_of_loan, replace
destring source_of_loan, replace
destring O13, replace
gen weight = O13/100 
gen credits = 0
replace credits = 1  if (nature_of_loan==2 | nature_of_loan==3 | nature_of_loan==4) & (source_of_loan!=9 & source_of_loan!=18)  // =1 if farmer had loans (cash and kind) payable as on the date of survey | See questionnaire page D-13 for detail


collapse (max) credits weight, by (FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num) // Household values
destring FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num, replace

save "${IND_SAAHH_created_data}\India_SAAHH_2018_credit.dta", replace



use "$IND_SAAHH_final_data\hh_characteristics.dta", clear
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}/India_SAAHH_2018_insurance.dta", nogen // Insurance data
merge 1:1 FSU_num round schedule sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num using "${IND_SAAHH_created_data}/India_SAAHH_2018_credit.dta", nogen // Insurance data

recode credits (.=0)
recode crop_insured (.=0)
recode bank_account (.=0)

gen fin_services = 0
replace fin_services=1 if credits==1 | crop_insured==1 | bank_account==1   // 98% of HH have a bank account

lab var fin_services "Whether any of the household member has a loan, crop insurance or a bank account"
lab var crop_insured "Whether any of the household member has crop insurance"
lab var credits "Whether any of the household member has a loan from a formal institutions"



sum credits bank_account crop_insured fin_services [aw= weight] // India estimates
sum credits bank_account crop_insured fin_services [aw= weight] if state=="Bihar"
sum credits bank_account crop_insured fin_services [aw= weight] if state=="Odisha" 
sum credits bank_account crop_insured fin_services [aw= weight] if state=="UttarPradesh"

keep credits bank_account crop_insured fin_services FSU_num round schedule crop_loss* sample sector NSS_region district stratum substratum subround FOD_subregion SSS_num HHID_num weight C1
save "${IND_SAAHH_created_data}\India_SAAHH_2018_financial_serv.dta", replace

