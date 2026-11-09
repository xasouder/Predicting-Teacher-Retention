/*proc freq data =reteacher;tables Years_Continue_toWork;run;*/
data yearreteacher;
set reteacher;if cmiss(of Years_Continue_toWork) then delete;
if cmiss(of Consider_Leaving) then delete;
where Years_Continue_toWork is not null and Consider_Leaving is not null
 and Years_Continue_toWork<80;
run;
proc means data =yearreteacher mean min Q1 median Q3 max kurtosis skew maxdec=3;
var Years_Continue_toWork;run;



/* There is no difference between teachers around the world and US teachers 
on years they wish to continue to work*/

/**************DISCRET YEARS CONTINUE TO WORK*******************/
Proc means data=yearreteacher;
Var Consider_Leaving;
output out=test mean=meangoodbad;
Run;

Proc univariate data = yearreteacher noprint;
var Years_Continue_toWork;
histogram;
run;

*go one by one to create logically equal groups;
Data syearreteacher;
set yearreteacher;
if Years_Continue_toWork <10 then ordYears_Continue_toWork = 1;
else if Years_Continue_toWork <20 then ordYears_Continue_toWork = 2;
else if Years_Continue_toWork <30 then ordYears_Continue_toWork = 3;
else if Years_Continue_toWork <40 then ordYears_Continue_toWork = 4;
else if Years_Continue_toWork <50 then ordYears_Continue_toWork = 5;
else if Years_Continue_toWork <60 then ordYears_Continue_toWork = 6;
else if Years_Continue_toWork <70 then ordYears_Continue_toWork = 7;
else ORDYears_Continue_toWork = 8;
Run;
*means for comparing against self then against Consider_Leaving;
Proc means data=syearreteacher;
var Years_Continue_toWork;
class ordYears_Continue_toWork;
run;
Proc means data=syearreteacher;
Var Consider_Leaving;
class ordYears_Continue_toWork;
output out = test mean=meanGOODBAD;
Run;

*plot of trend of data;
symbol v=square color = black i=join;
Proc gplot data = test;
plot meanGOODBAD*ordYears_Continue_toWork;
run;
quit;

%let d1 = syearreteacher;
Proc means data = &d1 nmiss;
run;

Proc Summary data=&d1 mean missing std;
class ordYears_Continue_toWork;
Var Years_Continue_toWork Consider_Leaving;*iv is BRHIC, dv is Consider_Leaving;
Output out=summary mean=avg_ind avg_dep;
Run; 

Data summary;
Set summary;
oddsYears_Continue_toWork = (avg_dep/(1-avg_dep));
loddsYears_Continue_toWork = -1*(log(avg_dep/(1-avg_dep))); *use lodds or test;
Run;*Odds ratio above choose which one we will use;
Proc Print data=summary;
Run;

*Code to merge the summary file values back into the dataset;
Proc sort data=summary;
by ordYears_Continue_toWork;
Run;

Proc sort data=&d1;
by ordYears_Continue_toWork;
Run;
*merges summary and dataset in D1;
Data modelingfile (drop = _TYPE_  _FREQ_ avg_ind avg_dep);
Merge summary &d1;
by ordYears_Continue_toWork;
Run;
Proc Print data=modelingfile (obs = 200);*check if summary was correct;
Var Years_Continue_toWork ordYears_Continue_toWork oddsYears_Continue_toWork loddsYears_Continue_toWork;
Run;


/**************DISCRET YEARS CONTINUE TO WORK*******************/

Proc freq data = modelingfile;*;
tables Years_Continue_toWork;
run;
%disc2(pval_col = 0.15,var1=Years_Continue_toWork,d1=modelingfile);*edit var name below;

/*Proc Print data=temp; Run;*temp is name of dataset from macro;*/
Proc sort data=temp;
by rank;
Run;
*gplot trends graph;
symbol1 v= square color = black i=join;
Proc gplot data = temp;
plot avg_dep*rank;
run;
quit; 
Proc Print data=temp;*temp is name of dataset from macro;
Run;

*the first ranked statement with rank 0;
Data ranked1;
Set ranked;
if rank = 0 then rank = 0;
else if rank = 1 then rank = 1;
else if rank = 2 then rank = 2;
else if rank = 3 then rank = 3;
else if rank = 4 then rank = 4;
else if rank = 5 then rank = 5;
else if rank = 6 then rank = 6;
else if rank = 7 then rank = 8;
else if rank = 8 then rank = 8;
else if rank = 9 then rank = 9;
else rank = rank;
Run;
*Proc sort statements and freq of rank to inform below;
Proc sort data=ranked1;
by rank;
Run;
Proc sort data=temp;
by rank;
Run;
Proc freq data=ranked1;
tables rank;
run;

Data modelingfile;*discret 2 and the age var;
Merge ranked1 temp;
by rank;
Run;

*****At this point, you can assign the ranks as 1, 2, 3...;
Data modelingfile1;
set modelingfile;
if rank = 0 then ordeqYears_Continue_toWork = 0;
else if rank = 1 then ordeqYears_Continue_toWork = 1;
else if rank = 2 then ordeqYears_Continue_toWork = 2;
else if rank = 3 then ordeqYears_Continue_toWork = 3;
else if rank = 4 then ordeqYears_Continue_toWork = 4;
else if rank = 5 then ordeqYears_Continue_toWork = 5;
else if rank = 6 then ordeqYears_Continue_toWork = 6;
else if rank = 8 then ordeqYears_Continue_toWork = 7;
else if rank = 9 then ordeqYears_Continue_toWork = 8;
else rank = rank;
odseqYears_Continue_toWork  = (avg_dep)/(1-avg_dep);*choose one;
lodseqYears_Continue_toWork = log ((avg_dep)/(1-avg_dep));
run;

*Note: at this point, there is ALOT of garbage in the file that needs to be removed...;
Data yearreteacher (drop = _TYPE_ avg_dep avg_indp max_dep max_indp
min_dep min_indp numobs pvalue rank std_dep std_indp v1);
set modelingfile1;
Run;

/***************************
*******DATA SAMPLING********
****************************/
proc sort data = yearreteacher;by Years_Continue_toWork;run;
Proc surveyselect data=yearreteacher samprate = .8 out=yearreteachersamp method=srs
seed = 934 outall;*outs all obs to new dataset with a new var "selected";
strata Years_Continue_toWork; *needs to be sorted,strata ensures constant prop of 0 & 1;
Run;

Proc freq data=yearreteachersamp;
Tables Years_Continue_toWork*selected;
Run;

/*if selected is equal to one it will go into the train file 
"have to say output train"*/
Data teachertrain teachervalid;
set yearreteachersamp;
if selected then output teachertrain;
else output teachervalid;
Run;


/***************************
*******DATA SAMPLING log********
****************************/
proc sort data = yearreteacher;by Consider_Leaving;run;
Proc surveyselect data=yearreteacher samprate = .8 out=moddevfile method=srs
seed = 934 outall;*outs all obs to new dataset with a new var "selected";
strata Consider_Leaving; *needs to be sorted,strata ensures constant prop of 0 & 1;
Run;

Proc freq data=moddevfile;
Tables Consider_Leaving*selected;
Run;

Proc contents data=moddevfile;
Run;

/*if selected is equal to one train file*/
Data train valid;
set moddevfile;
if selected then output train;
else output valid;
Run;


*C-stat should be around 85;
proc freq data=train;
	tables Consider_Leaving;

proc contents data = train;run;


/****** Random forest for later*****/
/*random forest
proc hpforest data = modelingfile vars_to_try=all;
input Years_Continue_toWork:/level=interval;
target Consider_Leaving/level=interval;
run;*/