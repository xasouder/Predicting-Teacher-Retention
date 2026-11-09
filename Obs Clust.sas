Proc contents data = yearreteacher;
run;

/*identify vars to be used*/
%let inputs = Distracted Calm_Relaxed Job_Useless Purpose_Work
	 Enough_Time noTime_Personal
	odseqYears_Continue_toWork oddsYears_Continue_toWork;

/*standardize the dataset and variables in a temp dataset*/
Proc stdize data = yearreteacher method = range out = temp;
var &inputs;
run;

/*#1 (best for fewer data)
Proc cluster data = temp method=ward ccc pseudo outtree=tree;
var &inputs;
*CCC we want the peak, pseudo we want the maximum, T we want minimum;
run;
Proc tree data = tree level = .01;
run;*/

/*#2(What we will be using)*/proc fastclus data=temp maxc=4 maxiter=10 out=clus;
var Distracted Calm_Relaxed Job_Useless Purpose_Work
	 Enough_Time noTime_Personal
	odseqYears_Continue_toWork oddsYears_Continue_toWork;
*input maxc for how many clusters we want;
run;

proc freq data = clus;
tables cluster*Consider_Leaving;
run;
/*how clusters overlap*/
proc candisc data = clus anova out=can;
class cluster;
var  Distracted Calm_Relaxed Job_Useless Purpose_Work
	 Enough_Time noTime_Personal
	odseqYears_Continue_toWork oddsYears_Continue_toWork;
title2 ’Canonical Discriminant Analysis of Teacher Retention Clusters’;
run;

legend1 frame cframe=white label=none cborder=black
position=center value=(justify=center);
axis1 label=(angle=90 rotate=0) minor=none;
axis2 minor=none;
proc gplot data=Can;
plot Can2*Can1=Cluster/frame cframe=white
legend=legend1 vaxis=axis1 haxis=axis2;
title2 ’Plot of Canonical Variables Identified by Cluster’;
run;

*look for those with a profit margin greater than normal and narrow in;