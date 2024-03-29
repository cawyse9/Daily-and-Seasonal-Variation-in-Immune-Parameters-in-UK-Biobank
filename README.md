# Daily-and-Seasonal-Variation-in-Immune-Parameters-in-UK-Biobank

<img align="right" src="https://user-images.githubusercontent.com/29300100/199220628-dc966475-5b5c-4de7-9032-c34149432692.png" width="200">

## Background
Circulating white blood cell counts are known to oscillate across days and seasons under basal conditions, reflecting distribution of cells between tissues and the periphery. Importantly, daily rhythms persist in constant conditions and are absent in animals with ablated clock function, indicating that they are mediated via innate circadian timing mechanisms. The extensive data collection within UK Biobank represents an unprecedented opportunity to assess seasonal and time-of-day and seasonal variation in levels of human immune parameters. 

## Objective
The aim of this project is to investigate seasonal and daytime variability in multiple immune parameters in 329,261 participants in UK Biobank while adjusting for a wide range of environmental and lifestyle factors, including changes in day length, outdoor temperature and vitamin D at the time the blood sample was collected. 

## Data
The study sample were participants of UK Biobank, a general population cohort study that recruited over half a million UK residents continuously between 2006 and 2010, at 22 assessment centres located across the UK (www.ukbiobank.co.uk). Participants provided full informed consent to participate in UK Biobank. This study was covered by the generic ethical approval for UK Biobank studies from the NHS National Research Ethics Service.  

Seasonal and daily variation were assessed by plotting mean values of white blood cell and CRP values against month or hour of sample collection, fitting models to describe annual and daily variation, and then investigating whether any variation was independent of confounding factors and directly related to day length. The sampling distribution for CRP was positively-skewed, and a logarithmic transformation was applied before regression analysis, but original data are shown in the descriptive data summaries. Seasonal patterns were analyzed by fitting a linear regression model for each outcome of interest that included a sine and a cosine term of transformations of the time variable, taken as month:

$$Y_i = M + \beta \text{ } Cos  (2\pi \frac{t_{i}}{12}) + \gamma \text{ } Sin (2\pi \frac{t_{i}}{12}) $$

Where Y is t is time (months), and M, β and γ were predicted by regression, above. The acrophase $(\Phi)$ and amplitude (A) was predicted as:

$$ A = (\beta^{2} + \gamma^{2})^{1/2}$$

$$ \Phi = tan^{-1}(-\gamma/\beta)$$

The intercept (M) was the mean level of the curve and thus an estimate of the annual mean of each outcome variable. The amplitude (A) was the distance from the mean to the acrophase or the nadir, providing an estimate of the magnitude of seasonality. The acrophase $(\Phi)$ is the peak x axis value of the curve, whereas the nadir is the trough. Seasonality was indicated by statistical significance of the estimated cosinor (sine and cosine) regression coefficients.

Variation of the markers over the daily time course of sample collection was modeled using linear methods since the absence of nighttime samples precluded assumption of circadian patterns. Although assessment centre appointments started at 8am, the blood sample was collected at the end of the 40-minute assessment, so the 8am time point was excluded due to small sample numbers at this time (n= 1843). The relationship between time of day and the immune parameters was represented by a series of linear regression lines connected at breakpoints where the slope of each line changed. This analysis was implemented using the R package “segmented” to predict the times of breakpoints during the test period for each analyte. The statistical significance of the segmented regression model was assessed using the Davies test to test the null hypothesis that a breakpoint does not exist, and that the difference in slope parameter (𝜓) of the segmented relationship is zero. The breakpoints and slopes of each segment indicate peaks and troughs in WBC and CRP levels over time, as well as the rate and direction of any changes.

If seasonal and daily variation were indicated, we next investigated if these patterns were related to day length, and to time of day, and if any relationships were independent of lifestyle and environmental factors. The daytime data were modelled as a series of linear splines to account for the non-linear relationships between time of day and the immune parameters. Three multiple linear regression models were run that included an increasing number of covariates and progressively adjusted for sociodemographic, disease, lifestyle and environmental (temperature and day length) factors, with results reported as point estimates and 95% confidence intervals.

Potential confounders included as covariables were age; sex; ethnicity; Townsend area deprivation score; physical activity and sedentary behaviour; alcohol intake and smoking status; outdoor temperature; blood analyser; vitamin D; sleep duration; chronotype and UK Biobank assessment centre. Multicollinearity between the covariables was assessed using variance inflation factors (VIF) and tolerance factors, with values of VIF > 10 taken to denote problematic collinearity.

All analyses were performed using R version 3.5, and Stata 14 statistical software (StataCorp LP) and values of p < 0.01 were considered to represent statistical significance.
Link to Stata code [here](https://github.com/cawyse9/Daily-and-Seasonal-Variation-in-Immune-Parameters-in-UK-Biobank/blob/main/Analysis/covid%20july2020v2.do) and 
[here](https://github.com/cawyse9/Daily-and-Seasonal-Variation-in-Immune-Parameters-in-UK-Biobank/blob/main/Analysis/covid%20sept2020_total%20counts.do)



## Acknowledgments
Co-authors were Grace O’Malley (RCSI), Andrew Coogan (Maynooth University), Sam McConkey (RCSI), Daniel Smith (University of Edinburgh)
