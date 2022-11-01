
*1 SUMMARY STATS
*******************************************************************************************

*clean the raw data
gen WBC_count = v2 


gen NE_count = v184
gen NE_PC = v262
 
gen LY_count = v158 
gen LY_PC = v236

gen MO_count = v171
gen MO_PC = v249

label variable WBC_count "30000"
label variable NE_count "30140"
label variable LY_count "30120"
label variable MO_count "30130"

label variable NE_PC "30200"
label variable LY_PC "30180"
label variable MO_PC "30190"
*WBC_count WBC_count NE_count  LY_count  MO_count

hist WBC_count
gen WBC_count_C = WBC_count
replace WBC_count_C = . if WBC_count > 15 
replace WBC_count_C = . if WBC_count < 2 
hist WBC_count_C

hist NE_count
gen NE_count_C = NE_count
replace NE_count_C = . if NE_count > 10 
replace NE_count_C = . if NE_count < 1 
hist NE_count_C

hist MO_count
gen MO_count_C = MO_count
replace MO_count_C = . if MO_count > 1.5
hist MO_count_C

hist LY_count
gen LY_count_C = LY_count
replace LY_count_C = . if LY_count > 5
hist LY_count_C

hist LY_PC
hist NE_PC

hist MO_PC
replace MO_PC = . if MO_PC>20


*export to R for tableone
*daylen BS_hr age ethnicity deprivation_t5 centre bmi blood_count_device totalpa_METhwk totalSED_hday_c smoker_yesno alcohol_frequency tmean VITD sex

keep  WBC_count_C  NE_count_C  LY_count_C  MO_count_C CRP BS_hr_9to8 season diseased BS_month

keep  neutrophils lymphocytes monocytes CRP BS_hr_9to8 season diseased BS_month

keep eid  WBC_count_C  NE_count_C  LY_count_C  MO_count_C diseased daylen age ethnicity deprivation_t5 bmi totalpa_METhwk totalSED_hday_c smoker_yesno alcohol_frequency chronotype shiftwork_yesno tmean VITD BS_hr sex sleep_duration CRP BS_month


ssc install binscatter
binscatter WBC_count_C  BS_hr_9to8 if diseased==0
binscatter WBC_count_C  BS_month if diseased==0

mean WBC_count_C if diseased ==0, over (BS_month)
mean LY_count_C if diseased ==0, over (BS_month)
mean NE_count_C if diseased ==0, over (BS_month)
mean MO_count_C if diseased ==0, over (BS_month)

mean WBC_count_C if diseased ==0, over (BS_hr_9to8)
mean LY_count_C if diseased ==0, over (BS_hr_9to8)
mean NE_count_C if diseased ==0, over (BS_hr_9to8)
mean MO_count_C if diseased ==0, over (BS_hr_9to8)

mean WBC_count_C if diseased ==0, over (BS_year)
mean LY_count_C if diseased ==0, over (BS_year)
mean NE_count_C if diseased ==0, over (BS_year)
mean MO_count_C if diseased ==0, over (BS_year)

mean LY_PC if diseased ==0, over (BS_month)
mean NE_PC if diseased ==0, over (BS_month)
mean MO_PC if diseased ==0, over (BS_month)

mean LY_PC if diseased ==0, over (BS_hr_9to8)
mean NE_PC if diseased ==0, over (BS_hr_9to8)
mean MO_PC if diseased ==0, over (BS_hr_9to8)

binscatter CRP BS_hr_8to8 if diseased==0, discrete rd(13)
binscatter neutrophils BS_hr_8to8 if diseased==0, discrete rd(11,14)
binscatter monocytes BS_hr_8to8 if diseased==0, discrete rd(9, 14)
binscatter lymphocytes BS_hr_8to8 if diseased==0, discrete rd(12, 15)




*=======================================================================================================
*2.  Linear model correcting for daylength - check seasonal effects

*stepwise regression

***CRP 
reg CRPlog daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  shiftwork_yesno smoker_yesno alcohol_frequency c.VITD##c.sex c.VITD##c.bmi tmean BS_hr blood_count_device centre if diseased == 0
est sto m1
reg CRPlog daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
 reg CRPlog daylen sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using CRPtotal.rtf, ci(3) b(3) noconstant r2(3) nodepvars nonumber star wide append label  mtitles("Model 1" "Model 2" "Model 3")

***monocytes interaction daylength and bs device
reg MO_count_C daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency VITD tmean BS_hr blood_count_device centre if diseased == 0
est sto m1
reg MO_count_C daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg MO_count_C daylen sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using MO_C.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")

**neutrophils and lymphocytes 
foreach var in LY_count_C NE_count_C {
reg `var' daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency VITD tmean BS_hr blood_count_device centre if diseased == 0
est sto m1
reg `var' daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg `var' daylen sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using NE_LY_C.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")
}


**wbc 
foreach var in WBC_count_C {
reg `var' daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency VITD tmean BS_hr blood_count_device centre if diseased == 0
est sto m1
reg `var' daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg `var' daylen sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using WBC_C.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")
}

*************************************************************

*****************************   diurnal data  *****************************

**neutrophils 
mkspline hour1 15 hour2 = BS_hr_9to8
reg NE_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  daylen  blood_count_device centre if diseased == 0
est sto m1
reg NE_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg NE_count_C hour1 hour2 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnalneutrophils_C.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")
drop hour1
drop hour2

**wbc 
mkspline hour1 14 hour2 = BS_hr_9to8
reg WBC_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency daylen  blood_count_device centre if diseased == 0
est sto m1
reg  WBC_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg  WBC_count_C hour1 hour2 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnalWBC.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")

drop hour1 hour2


**lymphocytes 
mkspline hour1 16 hour2 = BS_hr_9to8
reg LY_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency daylen  blood_count_device centre if diseased == 0
est sto m1
reg  LY_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg  LY_count_C hour1 hour2 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnallymphocytes_C.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")



***monocytes 
mkspline hour1 13 hour2 = BS_hr_9to8
reg MO_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  daylen blood_count_device centre if diseased == 0
est sto m1
reg MO_count_C hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg MO_count_C hour1 hour2 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnalmonocytes_C.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")
drop hour1
drop hour2

***CRP 
mkspline hour1 13 hour2 = BS_hr_9to8 
reg CRP hour1 hour2  sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c  sleep_duration chronotype  smoker_yesno alcohol_frequency daylen  centre if diseased == 0
est sto m1
reg CRP hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg CRP hour1 hour2 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnalCRP.rtf, ci(3) b(3) noconstant r2(3) nodepvars nonumber star wide append label  mtitles("Model 1" "Model 2" "Model 3")
drop hour1
drop hour2


**  data for export to excel for plots

*crp
mkspline hour1 13 hour2 = BS_hr_9to8 
reg CRP hour1 hour2  if diseased == 0
predict x1 if e(sample),xb
	quietly mean x1, over (BS_hr_9to8)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (crp_mo_ly_ne) title ("`var'") append 
drop x1 
drop hour1
drop hour2

*monocytes
mkspline hour1 14 hour2 = BS_hr_9to8 
reg MO_count_C hour1 hour2  if diseased == 0
predict x1 if e(sample),xb
	quietly mean x1, over (BS_hr_9to8)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (crp_mo_ly_ne) title ("`var'") append 
drop x1 
drop hour1
drop hour2

*lymphocytes
mkspline hour1 13 hour2 15 hour3 = BS_hr_9to8 
reg LY_count_C hour1 hour2 hour3 if diseased == 0
predict x1 if e(sample),xb
	quietly mean x1, over (BS_hr_9to8)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (crp_mo_ly_ne) title ("`var'") append 
drop x1 
drop hour1
drop hour2
drop hour3

*neutrophils
mkspline hour1 15 hour2 = BS_hr_9to8 
reg NE_count_C hour1 hour2 if diseased == 0
predict x1 if e(sample),xb
	mean x1, over (BS_hr_9to8)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (crp_mo_ly_ne) title ("`var'") append 
drop x1 
drop hour1
drop hour2

*wbc
mkspline hour1 14 hour2 = BS_hr_9to8 
reg WBC_count_C hour1 hour2 if diseased == 0
predict x1 if e(sample),xb
	mean x1, over (BS_hr_9to8)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (crp_mo_ly_ne) title ("`var'") append 
drop x1 
drop hour1
drop hour2

*=================================================================

*4.  Get data for cosinor graphs

foreach var in LY_count_C NE_count_C MO_count_C WBC_count_C {  
reg `var' cosA sinA if diseased==0
	predict x1 if e(sample),xb
    mean x1, over (BS_month)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (covid_cosinor) title ("`var'") append 
	drop x1 
}

*foreach var in NE_PCorrected eosinophil_pc_log basophil_pc_log monocyte_pc_log CRPlog_corrected {  

*quietly mean `var' if sex==1 & diseased==0, over (BS_month) 
*	matrix g = r(table)
*	matrix e = g'
*mat2txt, matrix(e) saving (bloodmale) title ("`var'") append 

*quietly reg `var' cosA sinA if sex==1 & diseased==0
*	predict x1 if e(sample),xb
*	quietly mean x1, over (BS_month)
*	matrix a2 = r(table)
*	matrix b2 = a2'
*	mat2txt, matrix(b2) saving (bloodmale) title ("`var'") append 
*	drop x1 
*}

********************************************

*parameters for all cosinors
******************************************************************

foreach var in CRP LY_C NE_C MO_C {  
	quietly reg `var' cosA sinA if diseased==0
	predict x1 if e(sample),xb
	
	*mesor
	gen mesor=_b[_cons] if e(sample) 

	*amplitude of cosinor
	gen amp = sqrt(_b[cosA]^2 + _b[sinA]^2) if e(sample) 

	*temporal peak of cosinor (convert radians to months)
	gen phase = 12*((atan(-_b[sinA] / _b[cosA]))/2*_pi)+1 if e(sample) 
display 12*((atan(0.03067/-0.06042))/2*3.142)+1 

	sum mesor amp phase
	matrix b2 = r(table)
	
	mat2txt, matrix(b2) saving (parameters_covid) title ("`var'") append 
	drop x1 
	drop mesor
	drop amp
	drop phase
	
}



*cosinor predicted
predict d2 if e(sample),xb

*se cosinor
predict dse if e(sample),stdp
gen dlo = d2 - dse*1.96
gen dhi = d2 + dse*1.96

*get aic
estat ic
mean d2 dse dlo dhi, over (BS_month)

svy, subpop(subpop): mean d2 dse dlo dhi, over BS_month
putexcel c4=("Means") B5=matrix(e(b)) using  "C:\Users\cathywyse\Documents\cosinordata.xls"

*95% CI of cosinor
mean dlo, over(BS_month)
mean dhi, over(BS_month)

*mesor
gen mesor=_b[_cons] if e(sample) 

*amplitude of cosinor
gen amp = sqrt(_b[cosA]^2 + _b[sinA]^2) if e(sample) 

*temporal peak of cosinor (convert radians to months)
gen phase = 12*((atan(-_b[sinA] / _b[cosA]))/2*_pi)+1 if e(sample) 
display 12*((atan(0.03067/-0.06042))/2*3.142)+1 

sum mesor amp phase
*cosinor is significant if cos or sin parameter pvalue > 0.025

drop mesor
drop amp
drop phase
drop d2
drop dlo
drop dhi
drop dse
******************************************************************************************

* get data for TOD graphs


foreach var in lymphocytes neutrophils monocytes {  

quietly mean `var' if diseased==0, over (BS_hr_9to8) 
	matrix g = r(table)
	matrix e = g'
mat2txt, matrix(e) saving (percent) title ("`var'") append 

}


foreach var in LY_C LY_PC NE_C NE_PC MO_C MO_PC {  

quietly mean `var' if diseased==0, over (BS_hr_9to8) 
	matrix g = r(table)
	matrix e = g'
mat2txt, matrix(e) saving (count) title ("`var'") append 

}

summarize NE_PC neutrophils


foreach var in NE_PC {  

quietly mean `var' if diseased==0, over (BS_month) 
	matrix g = r(table)
	matrix e = g'
mat2txt, matrix(e) saving (countmonth2) title ("`var'") append 

}

foreach var in neutrophils {  

quietly mean `var' if diseased==0, over (BS_month) 
	matrix g = r(table)
	matrix e = g'
mat2txt, matrix(e) saving (countmonth2) title ("`var'") append 

}
foreach var in lymphocyte lymphocytes monocyte monocytes neutrophils neutrophil {  

quietly mean `var' if diseased==0, over (BS_month) 
	matrix g = r(table)
	matrix e = g'
mat2txt, matrix(e) saving (diff) title ("`var'") append 

}

***************************************************************
*parameters for all cosinors
*******************************************************************************

*do this for CRP, neutrophils, lymphocytes and monocytes and copy data to excel for tables and to R for pirate plots (already in this do file, see above)

drop cosA
drop sinA

gen pi = 3.147
gen double cosA = cos(2*pi*BS_month) 
gen double sinA = sin(2*pi*BS_month)

drop d2
drop mesor
drop phase
*drop dlo
*drop dhi
*drop dse

*regression
reg  monocytes c.cosA c.sinA if diseased==0

*cosinor predicted
predict d2 if e(sample),xb

*get mean by months
mean d2, over (BS_month)

*se cosinor
*predict dse if e(sample),stdp
*gen dlo = d2 - dse*1.96
*gen dhi = d2 + dse*1.96

*get aic
*estat ic
*mean d2 dse dlo dhi, sum (month)


*svy, subpop(subpop): mean d2 dse dlo dhi, over month
*putexcel c4=("Means") B5=matrix(e(b)) using *"d:\biobank\means.xlsx"  

*95% CI of cosinor
*mean dlo, over(month)
*mean dhi, over(month)

*mesor
gen mesor=_b[_cons] if e(sample) 

*amplitude of cosinor
gen amp = sqrt(_b[cosA]^2 + _b[sinA]^2) if e(sample) 

*temporal peak of cosinor (convert radians to months)
gen phase = 12*((atan(-_b[sinA] / _b[cosA]))/2*_pi)+1 if e(sample) 
display 12*((atan(0.03067/-0.06042))/2*3.142)+1 

sum mesor amp phase
*cosinor is significant if cos and sin parameter pvalue > 0.025

******************************************************************

