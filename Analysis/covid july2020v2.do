
*1 SUMMARY STATS
*******************************************************************************************

*export to R for tableone
*daylen BS_hr age ethnicity deprivation_t5 centre bmi blood_count_device totalpa_METhwk totalSED_hday_c smoker_yesno alcohol_frequency tmean VITD sex


eid lymphocytes neutrophils monocytes eosinophils basophils leucocytes diseased daylen age ethnicity deprivation_t5 bmi totalpa_METhwk totalSED_hday_c smoker_yesno alcohol_frequency chronotype shiftwork_yesno tmean VITD BS_hr sex eid sleep_duration CRP BS_month

label var daylen "Daylength"
label var age "Age"
label var ethnicity "Ethnicity"
label var deprivationindex "Social Deprivation"
label var bmi "BMI"
label var totalpa_METhwk "Physical Activity"
label var totalSED_hday_c "Sedentary Behaviour"
label var smoker_yesno "Smoking"
label var alcohol_frequency "Alcohol" 
label var chronotype "Chronotype"
label var tmean "Outdoor Temperature"
label var VITD "Vitamin D"
label var BS_hr "Time of Day"
label var sex "Sex"
label var sleep_duration "Sleep Duration"
label var shiftwork_yesno "Shiftwork"
label var blood_count_device "Blood Analyser"
label var centre "Assessment Centre"
*stratify

*remove diseased

*clean blood sample time
*2008-02-25T09:19:54

*format as stata time var
gen double BS_datetime = clock(v782, "YMD#hms")
format BS_datetime %tc 

*extract year month time
gen BS_hr=hh(BS_datetime)
gen BS_min=mm(BS_datetime)
gen BS_month= month(dofc(BS_datetime))
gen BS_year= year(dofc(BS_datetime))

label variable BS_datetime "Time blood sample collected"
ssc install binscatter
binscatter CRP BS_hr_8to8, by(shiftwork_yesno)

binscatter wage tenure, discrete rd(2.5 14.5)

binscatter CRP BS_hr_8to8 if diseased==0, discrete rd(13)
binscatter neutrophils BS_hr_8to8 if diseased==0, discrete rd(11,14)
binscatter monocytes BS_hr_8to8 if diseased==0, discrete rd(9, 14)
binscatter lymphocytes BS_hr_8to8 if diseased==0, discrete rd(12, 15)





binscatter CRP BS_month
binscatter CRP daylen if diseased ==0
binscatter monocytes daylen if diseased==0
binscatter VITD BS_month if sex==1
binscatter VITD tmean
binscatter CRPlog VITD if diseased==0
binscatter CRPlog daylen if diseased==0

mean monocytes, over(BS_month)
reg CRPlog VITD, beta

reg CRPlog daylen, beta

binscatter VITD BS_day
binscatter VITD daylen, by (blood_count_device)
mean monocyte_pc_log, over(blood_count_device)
mean VITD, over(ethnicity)
codebook (blood_count_device)

drop remove_BS_device
gen remove_BS_device = blood_count_device
replace remove_BS_device = . if blood_count_device==1
codebook remove_BS_device

*correct BS_hr to remove samples between
*get rid of 0-07 and 8-23

gen BS_hr_8to8 = BS_hr
replace BS_hr_8to8 =. if inrange(BS_hr,0,7)
replace BS_hr_8to8 =. if inrange(BS_hr,20,23)
mean CRP, over ( BS_hr_8to8)
gen BS_hr_9to8 = BS_hr_8to8
replace BS_hr_9to8 =. if inrange(BS_hr,0,8)
*make a season variable for interaction
gen season = .

recode season 3/5=1 6/8=2 9/11=3 12=4 1/2 = 4
replace season = 1 if inrange(BS_month,3,5)
replace season = 2 if inrange(BS_month,6,8)
replace season = 3 if inrange(BS_month,9,11)
replace season = 4 if inrange(BS_month,12,12)
replace season = 4 if inrange(BS_month,1,2)
label define seasons 1 "spring"  2 "summer" 3 "autumn" 4 "winter"
label values season seasons

gen monocytes = v249
gen lymphocytes= v236
gen basophils= v288
gen eosinophils=v275
gen neutrophils=v262
gen leucocytes=v2

label variable monocytes "30190"
label variable lymphocytes "30180"
label variable basophils "30220"
label variable eosinophils "30210"
label variable neutrophils "30200"
label variable leucocytes "30000"

hist monocytes
hist lymphocytes
hist basophils
hist eosinophils
hist neutrophils
hist leucocytes

sum monocytes
sum lymphocytes
sum basophils
sum eosinophils
sum neutrophils
sum leucocytes


*=======================================================================================================
*2.  Linear model correcting for daylength - check seasonal effects


*model - centre fixed effect correct for temp time of day
*********************************************************************************************************************************************************

*model 1 daylength age ethnicity deprviation centre
*model 2 daylength age ethnicity deprviation centre bmi pa sed smok alcohol 
*model 3 daylength age ethnicity deprviation centre bmi pa sed smok alcohol blood count device tmean VITD

*outcomes=================================== 
*1	lymphocyte LY_PC 
*2	log_eosinophil  eosinophil_pc_log
*3	CRPlog_corrected
*4	neutrophilNE_PC_corrected
*5	basophil basophil_pc_log
*6	monocyte monocyte_pc_log
 

*LY_PC NE_PC_corrected eosinophil_pc_log basophil_pc_log monocyte_pc_log CRPlog_corrected
*================================================

*stepwise regression
* for CRP there is significant interaction between vitD and sex and between vitD and bmi


***CRP interaction VitD * sex and VitD* bmi
reg CRPlog daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  shiftwork_yesno smoker_yesno alcohol_frequency c.VITD##c.sex c.VITD##c.bmi tmean BS_hr blood_count_device centre if diseased == 0
est sto m1
reg CRPlog daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
 reg CRPlog daylen sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using CRPregression.rtf, ci(3) b(3) noconstant r2(3) nodepvars nonumber star wide append label  mtitles("Model 1" "Model 2" "Model 3")



***monocytes interaction daylength and bs device
reg monocytes daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency VITD tmean BS_hr blood_count_device centre if diseased == 0
est sto m1
reg monocytes daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg monocytes daylen sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using monocyte_regression.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")

**neutrophils and lymphocytes sex*vitd interactions
foreach var in lymphocytes neutrophils {
reg `var' daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency c.VITD##c.sex c.bmi##c.VITD tmean BS_hr blood_count_device centre if diseased == 0
est sto m1
reg `var' daylen sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype shiftwork_yesno smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg `var' daylen sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using deleteneut_lymph_regression.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")
}

*************************************************************

*****************************   diurnal data  *****************************

**neutrophils 
mkspline hour1 11 hour2 15 hour3 = BS_hr_8to8
reg neutrophils hour1 hour2 hour3 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  daylen  blood_count_device centre if diseased == 0
est sto m1
reg neutrophils hour1 hour2 hour3 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg neutrophils hour1 hour2 hour3 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnalneutrophils.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")
drop hour1
drop hour2
drop hour3



**lymphocytes 
mkspline hour1 12 hour2 15 hour3 = BS_hr_9to8
reg lymphocytes hour1 hour2 hour3 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency daylen  blood_count_device centre if diseased == 0
est sto m1
reg lymphocytes hour1 hour2 hour3 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg lymphocytes hour1 hour2 hour3 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnallymphocytes.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")
drop hour1
drop hour2
drop hour3


***monocytes 
mkspline hour1 14 hour2 = BS_hr_9to8
reg monocytes hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  daylen blood_count_device centre if diseased == 0
est sto m1
reg monocytes hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg monocytes hour1 hour2 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnalmonocytes.rtf, ci(3) b(3) noconstant r2(3) depvars nonumber star wide append  label  mtitles("Model 1" "Model 2" "Model 3")


drop hour1
drop hour2

***CRP 
mkspline hour1 12.5 hour2 = BS_hr_9to8 
reg CRP hour1 hour2  sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c  sleep_duration chronotype  smoker_yesno alcohol_frequency daylen  centre if diseased == 0
est sto m1
reg CRP hour1 hour2 sex age ethnicity deprivationindex bmi totalpa_METhwk totalSED_hday_c sleep_duration chronotype  smoker_yesno alcohol_frequency  if diseased == 0
est sto m2
reg CRP hour1 hour2 sex age ethnicity deprivationindex  if diseased == 0
est sto m3
esttab m3 m2 m1 using diurnalCRP.rtf, ci(3) b(3) noconstant r2(3) nodepvars nonumber star wide append label  mtitles("Model 1" "Model 2" "Model 3")
drop hour1
drop hour2


**  data for export to r for pirate plots

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
reg monocytes hour1 hour2  if diseased == 0
predict x1 if e(sample),xb
	quietly mean x1, over (BS_hr_9to8)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (crp_mo_ly_ne) title ("`var'") append 
drop x1 
drop hour1
drop hour2

*lymphocytes
mkspline hour1 12 hour2 15 hour3 = BS_hr_9to8 
reg lymphocytes hour1 hour2 hour3 if diseased == 0
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
mkspline hour1 11 hour2 15 hour3 = BS_hr_9to8 
reg neutrophils hour1 hour2 hour3 if diseased == 0
predict x1 if e(sample),xb
	quietly mean x1, over (BS_hr_9to8)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (crp_mo_ly_ne) title ("`var'") append 
drop x1 
drop hour1
drop hour2
drop hour3







*=======================================================================================================
*3. COMPARE AIC AND SIG OF COSINOR MODEL

*foreach var in WBC RBC HGB HCT MCV MCH MCHC  RDW  PLT  MPV  LY_PC  MO_PC  NE_PC  EO_PC  BA_PC  ///
 *LY_C  MO_C  NE_C  EO_C  BA_C  NRBC_PC NRBC_C  RET_PC  RET_C  HLR_PC  HLR_C  IRF MRV ///
 *MSCV  PCT  PDW	 { 
*eststo A: quietly reg `var' c.cosA c.sinA age time_bs_min ethnicity deprivation_t5 centre bmi blood_count_device totalpa_METhwk totalSED_hday_c smoking alcohol_frequency *tmean if sex == 0
*eststo B: quietly reg `var' age ethnicity time_bs_min deprivation_t5 centre bmi blood_count_device totalpa_METhwk totalSED_hday_c smoking alcohol_frequency tmean if sex == 0
*estadd lrtest A
*esttab using 100716blood_UKB_trim_F.rtf, scalars(lrtest_chi2 lrtest_df lrtest_p) se aic r2 depvars nonumber star wide append 
*eststo clear
*}

*	

*foreach var in WBC RBC HGB HCT MCV MCH MCHC  RDW  PLT  MPV  LY_PC  MO_PC  NE_PC  EO_PC  BA_PC  ///
* LY_C  MO_C  NE_C  EO_C  BA_C  NRBC_PC NRBC_C  RET_PC  RET_C  HLR_PC  HLR_C  IRF MRV ///
* MSCV  PCT  PDW	 { 
*eststo A: quietly reg `var' c.cosA c.sinA age time_bs_min ethnicity deprivation_t5 centre bmi blood_count_device totalpa_METhwk totalSED_hday_c smoking alcohol_frequency *tmean if sex == 1
*eststo B: quietly reg `var' age ethnicity time_bs_min deprivation_t5 centre bmi blood_count_device totalpa_METhwk totalSED_hday_c smoking alcohol_frequency tmean if sex == 1
*estadd lrtest A
*esttab using 100716blood_UKB_trim_M.rtf, scalars(lrtest_chi2 lrtest_df lrtest_p) se aic r2 depvars nonumber star wide append 
*eststo clear
*}
*

*=================================================================

*4.  Get data for cosinor graphs

foreach var in CRP lymphocytes neutrophils monocytes {  
reg `var' cosA sinA if diseased==0
	predict x1 if e(sample),xb
	quietly mean x1, over (BS_month)
	matrix a2 = r(table)
	matrix b2 = a2'
	mat2txt, matrix(b2) saving (covid_cosinor2) title ("`var'") append 
	drop x1 
}

*foreach var in NE_PC_corrected eosinophil_pc_log basophil_pc_log monocyte_pc_log CRPlog_corrected {  

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

foreach var in CRP lymphocytes neutrophils monocytes {  
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





reg bmi cosA sinA

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

quietly mean `var' if diseased==0, over (BS_hr_8to8) 
	matrix g = r(table)
	matrix e = g'
mat2txt, matrix(e) saving (bloodTODmale) title ("`var'") append 

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

