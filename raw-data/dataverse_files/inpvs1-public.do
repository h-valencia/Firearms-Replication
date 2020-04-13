# delimit ;

**********************************************************************************;
* read in publicly available Vital Statistics multiple cause of death mortality  *;
* file from NCHS and convert into collapsed dataset of month/year mortality      *;
* for accidental firearm deaths.  These data were download from the NCHS webside,*;

* and we renamed the downloaded files mort07.dat - mort15.dat                    *;                             
**********************************************************************************;

* read in microdata for all deaths;

clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using mort07.dat;

keep if ageunit == 1;

save temp1.dta, replace;

clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using mort08.dat;

keep if ageunit == 1;

append using temp1.dta;
save temp1.dta, replace;

clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using mort09.dat;

keep if ageunit == 1;

append using temp1.dta;
save temp1.dta, replace;


forvalues num = 10/15{;
     clear;
infix month 65-66 year 102-105 ageunit 70 age 71-73 icd10r 154-156 
	 using mort`num'.dat;

keep if ageunit == 1;

append using temp1.dta;
save temp1.dta, replace;
};

compress;
save temp1.dta, replace;

drop if age > 110;

gen firearm = icd10r == 119;
gen causedeath = "acc_firearms" if firearm == 1;
keep if causedeath == "acc_firearms";
drop firearm;

gen agecat = "0_14" if age <= 14;
     replace agecat = "15p" if age >= 15;
drop age;
	 
drop ageunit icd10r;

compress;
save alldeathsmicro-public.dta, replace;
erase temp1.dta;

*************************************************************************;
* create a collapsed dataset of mortality rates by month, year, and age *;
*************************************************************************;

clear;
use alldeathsmicro-public.dta;
gen index = [_n];

sort year month causedeath;
collapse (count) numdeaths=index, by(year month agecat causedeath);

fillin year month agecat causedeath;
tab _fillin;
replace numdeaths = 0 if _fillin == 1;
drop _fillin;

sort year agecat;
merge year agecat using population-age-public.dta;
tab _merge;
drop if _merge ~= 3;
drop _merge;

sort year month agecat;
save deaths-age-public.dta, replace;

