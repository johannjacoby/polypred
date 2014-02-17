** Example data.
DATA LIST FREE  / Cont (F1.0) typeOfEmployment (F1.0) Crit (F1.0).
BEGIN DATA
7 1 5 7 1 6 2 1 2 5 1 5 8 1 6 8 1 6 6 1 6 1 1 0 4 1 8 5 1 4 7 1 5 6 1 6 3 1 4 5 1 2 1 1 7 7 1 7 5 1 5 7 1 4 5 1 6 2 1 3 7 1 7 4 1 3 1 1 4 4 1 2 4 1 3 3 1 3 4 1 5 5 1 5 6 1 5 4 1 3 2 1 2 9 1 8 6 1 3 8 1 6 4 1 3 9 1 
3 6 1 4 3 1 3 5 1 5 4 1 7 1 1 5 7 1 3 4 1 2 6 2 4 6 2 5 6 2 4 5 2 2 5 2 1 5 2 4 4 2 2 6 2 5 4 2 6 3 2 2 3 2 5 5 2 5 6 2 5 5 2 5 7 2 7 3 2 4 4 2 0 2 2 3 4 2 2 8 2 2 4 2 6 8 2 4 7 2 5 12 2 7 6 2 6 5 2 4 6 2 6 7 2 5 
8 2 7 6 2 5 7 2 6 6 2 5 6 2 6 9 2 6 6 2 4 5 2 5 6 2 4 5 2 3 6 2 3 6 2 6 4 2 2 5 2 5 6 3 8 6 3 3 3 3 5 9 3 8 7 3 1 5 3 7 8 3 8 7 3 5 3 3 3 4 3 4 3 3 3 7 3 4 7 3 4 6 3 4 4 3 3 6 3 4 7 3 5 8 3 4 6 3 6 4 3 6 6 3 4 6 3 
4 4 3 3 7 3 4 3 3 4 2 3 4 3 3 5 2 3 2 3 3 5 5 3 7 7 3 6 5 3 5 7 3 1 5 3 4 6 3 4 7 3 4 8 3 2 5 3 3 7 3 4 5 3 2 7 3 3 5 3 7 5 3 4 7 3 1 5 4 3 4 4 6 8 4 3 6 4 6 6 4 0 3 4 8 5 4 4 4 4 6 8 4 1 6 4 4 4 4 3 4 4 3 1 4 6 4 
4 5 5 4 4 4 4 5 6 4 5 4 4 1 4 4 4 3 4 3 4 4 5 6 4 7 6 4 2 5 4 5 4 4 1 7 4 6 7 4 0 2 4 3 6 4 6 2 4 3 5 4 6 4 4 7 8 4 2 6 4 4 3 4 6 5 4 3 7 4 3 7 4 4 4 4 0 7 4 2 8 4 2 5 4 4 2 4 5 7 4 3
END DATA.

** center variable Cont into cCont.
COMPU temp = 1. 
EXE. 
AGG /BREAK temp /meanCont = MEAN(Cont). 
COMPU cCont = Cont - meanCont. 
EXE.
DEL VAR temp meanCont.

* Recode typeOfEmployment into dummy variables.
RECODE typeOfEmployment (1=1)(2,3,4=0)(ELSE=SYSMIS) INTO D1.
RECODE typeOfEmployment (2=1)(1,3,4=0)(ELSE=SYSMIS) INTO D2.
RECODE typeOfEmployment (3=1)(1,2,4=0)(ELSE=SYSMIS) INTO D3.
EXEC.
*Product terms of cCont and dummy variables.
COMPUTE IA_cCont_D1 = cCont*D1.
COMPUTE IA_cCont_D2 = cCont*D2.
COMPUTE IA_cCont_D3 = cCont*D3.
EXEC.

* Complete model, Model 0.
REGRESSION /STAT=COEF R ANOVA CHANGE /DEPENDENT=Crit /METHOD=ENTER cCont D1 D2 D3 IA_cCont_D1 IA_cCont_D2 IA_cCont_D3.

* Omnibus test of typeOfEmployment.
REGRESSION /STAT=COEF R ANOVA CHANGE /DEPENDENT=Crit /METHOD=ENTER cCont IA_cCont_D1 IA_cCont_D2 IA_cCont_D3 /METHOD=ENTER D1 D2 D3.
* Omnibus test of typeOfEmployment x Cont interaction.
REGRESSION /STAT=COEF R ANOVA CHANGE /DEPENDENT=Crit /METHOD=ENTER cCont  D1 D2 D3 /METHOD=ENTER IA_cCont_D1 IA_cCont_D2 IA_cCont_D3.


* create Dummy D4.
RECODE typeOfEmployment (4=1)(1,2,3=0)(ELSE=SYSMIS) INTO D4.
* create interaction term involving Dummy II-3.
COMPUTE IA_cCont_D4 = cCont*D4.
* estimate the simple slope of Cont at typeOfEmployment = 3.
REGRESSION /DEPENDENT = Crit /METHOD=ENTER cCont D1 D2 D4 IA_cCont_D1 IA_cCont_D2 IA_cCont_D4.

* estimate the simple slope of Cont at typeOfEmployment = 2.
REGRESSION /DEPENDENT = Crit /METHOD=ENTER cCont D1 D3 D4 IA_cCont_D1 IA_cCont_D3 IA_cCont_D4.

* estimate the simple slope of Cont at typeOfEmployment = 1.
REGRESSION /DEPENDENT = Crit /METHOD=ENTER cCont D2 D3 D4 IA_cCont_D2 IA_cCont_D3 IA_cCont_D4.


*** Obtaining pattern tests of simple slopes.
*Focal contrast.
RECODE typeOfEmployment (1,2=1)(3=0)(4=-2)(ELSE=SYSMIS) INTO KF.
*Residual contrasts Kr1 and Kr2.
RECODE typeOfEmployment (1=1)(2=-1)(3,4=0)(ELSE=SYSMIS) INTO Kr1.
RECODE typeOfEmployment (1,2,4=1)(3=-3)(ELSE=SYSMIS) INTO Kr2.
*Product terms.
COMPUTE P_KF_cCont = cCont*KF.
COMPUTE P_Kr1_cCont = cCont*Kr1.
COMPUTE P_Kr2_cCont = cCont*Kr2.
EXEC.

REGRESSION /DEPENDENT Crit /METHOD = ENTER cCont KF Kr1 Kr2 P_KF_cCont P_Kr1_cCont P_Kr2_cCont.


*Obtaining the average effect of Cont on Crit across conditions of typeOfEmployment.
RECODE typeOfEmployment (1=-1)(2=1)(3,4=0)(ELSE=SYSMIS) INTO E2_1.
RECODE typeOfEmployment (1,4=0)(2=1)(3=-1)(ELSE=SYSMIS) INTO E2_2.
RECODE typeOfEmployment (1,3=0)(2=1)(4=-1)(ELSE=SYSMIS) INTO E2_3.
COMPUTE IA_cCont_E2_1 = cCont*E2_1.
COMPUTE IA_cCont_E2_2 = cCont*E2_2.
COMPUTE IA_cCont_E2_3 = cCont*E2_3.
EXEC.

REGRESSION /DEPENDENT Crit /METHOD = ENTER cCont E2_1 E2_2 E2_3 IA_cCont_E2_1 IA_cCont_E2_2 IA_cCont_E2_3.
