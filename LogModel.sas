 /*consider leaving*/ 
%let d1 = train;
Proc means data = &d1 nmiss;
run;

Proc Logistic data = train desc outest = betas outmodel=scoringdata 
plots(MAXPOINTS = NONE);
model Consider_Leaving = sex Years_Continue_toWork NotThinking_Clearly 
	Distracted Easy_Concentrate Felt_Focused Cheerful Calm_Relaxed 
	Active_Rigorous Fresh_Rested Interested_Daily_Activities 
	Hard_Think_Complicated Think_Slower Done_All_atWork Job_Useless
    Purpose_Work Trivial_Daily_Activities Enjoy_Future_Workplans 
    Rely_Management Principal_Confidence Colleagues_Trust_Me Teacher_Rely_Others
	Trust_Colleagues Enough_Time Too_Much_Work Meet_Expectations Time_For_Breaks 
	noTime_Personal Tasks_Affect_Teach 
	/*odseqYears_Continue_toWork ordYears_Continue_toWork oddsYears_Continue_toWork*/
	/selection = backward
 CTABLE pprob=(0 to 1 by .05)
 LACKFIT RISKLIMITS;
output out = output p = predicted;
score data=valid out=score;
Run;

*model with only good vars;
Proc Logistic data = train desc outest = betas outmodel=scoringdata
plots(maxpoints = none)=(roc);
model Consider_Leaving =  sex
	Years_Continue_toWork NotThinking_Clearly Distracted Cheerful
	Calm_Relaxed Fresh_Rested Done_All_atWork Job_Useless Purpose_Work
	Trivial_Daily_Activities Enjoy_Future_Workplans Rely_Management
	Colleagues_Trust_Me Enough_Time Too_Much_Work
	Meet_Expectations Time_For_Breaks noTime_Personal
/selection = backward CTABLE pprob=(.18 to .2 by .0005)
 LACKFIT RISKLIMITS;
output out = output p = predicted;
score data=valid out=score;
Run;

*fully reduced model;
Proc Logistic data = train desc outest = betas outmodel=scoringdata
plots(maxpoints = none)=(roc);
model Consider_Leaving = 
	Years_Continue_toWork Distracted
	Calm_Relaxed Job_Useless Purpose_Work
	Enough_Time	noTime_Personal
/selection = backward CTABLE pprob=(.18 to .2 by .0005)
 LACKFIT RISKLIMITS;
output out = output p = predicted;
score data=valid out=score;
Run;


proc freq data=train;
table Consider_Leaving;

proc freq data=score;
tables F_Consider_Leaving*I_Consider_Leaving;
run;

proc univariate data=train noprint;
var Consider_Leaving;
histogram;
run;

proc logistic inmodel=scoringdata;
      score data=valid  out=score;
   run;



data score;
set score;
if p_Yes = . then delete;
run;


Proc Print data = score (obs=50);
var Consider_Leaving P_Yes;
run;

ods graphics on;
proc sgplot data=score;
    /* Overlay density or histograms of P_Yes split by Consider_Leaving */
    density P_Yes / type=kernel group=Consider_Leaving lineattrs=(thickness=2);
    xaxis label="Predicted Probability (P_Yes)";
    yaxis label="Density";
    title "Probability Separation by Actual Outcome (Consider Leaving)";
run;
ods graphics off;
****Print the variables p_1 and p_0 that were created by the score option;

proc contents data=score;
Run;

proc print data=score (obs=50);
var Consider_Leaving p_No p_Yes;
where Consider_Leaving = 1;
run;

****Set cutoff point at x;
data test;
set score;
*from the table in log regression is prob of 1;
if P_Yes ge .19 then preds = 1;
else preds = 0;
run;
/*proc sort data=probs;*/
/*by Consider_Leaving;*/
/*RUN;*/
/*******Create table with ^ pred values, no relation to profit but interesting;*/
/**/
proc freq data=test;
table Consider_Leaving*preds/norow nocol;
run;


/***************************
********Random Forest*******
***************************/
proc hpforest data = train maxtrees = 100 trainfraction = 0.6;
    /* Define categorical/binary vs continuous variables */
    target Consider_Leaving / level = binary;
    
    input sex Years_Continue_toWork NotThinking_Clearly 
          Distracted Easy_Concentrate Felt_Focused Cheerful Calm_Relaxed 
          Active_Rigorous Fresh_Rested Interested_Daily_Activities 
          Hard_Think_Complicated Think_Slower Done_All_atWork Job_Useless
          Purpose_Work Trivial_Daily_Activities Enjoy_Future_Workplans 
          Rely_Management Principal_Confidence Colleagues_Trust_Me Teacher_Rely_Others
          Trust_Colleagues Enough_Time Too_Much_Work Meet_Expectations Time_For_Breaks 
          noTime_Personal Tasks_Affect_Teach odseqYears_Continue_toWork
          ordYears_Continue_toWork oddsYears_Continue_toWork 
          / level = nominal; /* Change to 'nominal' for categorical predictors */

    /* Save model information for scoring new data */
    save file = "/home/u64123092/nonpara/glmfullrf.sas";
run;

/* Score Validation Data */
proc hp4score data = valid;
    score file = "/home/u64123092/nonpara/glmfullrf.sas" out=scores;
run;
proc contents data = scores;run;

/* CTABLE */
proc logistic data = scores;
    model Consider_Leaving(event='Yes') = P_Consider_LeavingYes P_Consider_LeavingNo /
    ctable pprob = (0 to 1 by 0.05);
run;


/*output the ROC data*/
proc logistic data = scores plots=none;
    model Consider_Leaving(event='Yes') = P_Consider_LeavingYes/outroc = roc_data;
    roc 'HPFOREST Model' P_Consider_LeavingYes; 
run;

/*ROC Curve */
proc sgplot data = roc_data aspect=1;
    /* Reference line*/
    lineparm x=0 y=0 slope=1 / lineattrs=(pattern=dash color=gray);

    /*plot the models ROC curve*/
    series x=_1mspec_ y=_sensit_ / 
        lineattrs=(thickness=2 color=navy) 
        legendlabel="HPFOREST ROC Curve";
	/*axis labels*/
    xaxis label="False Positive Rate (1 - Specificity)" values=(0 to 1 by 0.2) grid;
    yaxis label="True Positive Rate (Sensitivity)" values=(0 to 1 by 0.2) grid;
    title "ROC Curve for HPFOREST Model";
run;
