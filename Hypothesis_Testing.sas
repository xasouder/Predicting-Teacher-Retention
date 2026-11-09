/***********ASSUMPTION CHECKIN*************/
proc univariate data=reteacher normal ;
      var Age;
      histogram Age;
run;

*check VIF amount - all within acceptable limits (<10);
proc reg data=reteacher;
    model age = Purpose_Work /*Trivial_Daily_Activities Enjoy_Future_Workplans 
    Done_All_atWork Job_Useless*// vif;
run;

* reject the assumption of equality of variance;
/*proc glm data = reteacher;
    class Purpose_Work Trivial_Daily_Activities Enjoy_Future_Workplans Done_All_atWork Job_Useless;
    model age = Purpose_Work Trivial_Daily_Activities Enjoy_Future_Workplans Done_All_atWork Job_Useless;
    means Purpose_Work Trivial_Daily_Activities Enjoy_Future_Workplans Done_All_atWork Job_Useless/ hovtest=levene(type=abs);
run;*/
proc glm data = reteacher;
    class Trivial_Daily_Activities;
    model age = Trivial_Daily_Activities;
    means  Trivial_Daily_Activities / hovtest=levene(type=abs);
run;

proc glm data = reteacher;
    class Enjoy_Future_Workplans;
    model age = Enjoy_Future_Workplans;
    means  Enjoy_Future_Workplans / hovtest=levene(type=abs);
run;

proc glm data = reteacher;
    class Done_All_atWork;
    model age = Done_All_atWork;
    means  Done_All_atWork / hovtest=levene(type=abs);
run;

proc glm data = reteacher;
    class Job_Useless;
    model age = Job_Useless;
    means  Job_Useless / hovtest=levene(type=abs);
run;
/*********************one sample ttest**************************/
proc univariate data = reteacher plots normal;
var Years_atSchool Years_Worked;run;
/*Years worked compared to national average*/
proc univariate data=yearreteacher mu0=14.5 normal plots;
      var Years_Worked;
      histogram Years_Worked;
run;

ods graphics on;
proc ttest data = yearreteacher h0=14.5 plots(showh0) sides=2 alpha=0.05;
   var Years_Worked;
run;
ods graphics off;

/*Years at School compared to national average*/
proc univariate data=yearreteacher mu0=8.2 normal plots;
      var Years_atSchool;
      histogram Years_atSchool;
run;

ods graphics on;
proc ttest data = yearreteacher h0=8.2 plots(showh0) sides=2 alpha=0.05;
   var Years_atSchool;
run;
ods graphics off;

*histogram;
proc univariate data=yearreteacher normal plots;
    class Consider_Leaving;
    var Years_Continue_toWork;
    histogram Years_Continue_toWork / overlay;
run;
proc ttest data = yearreteacher;
	class Consider_Leaving;
    var Years_Continue_toWork;run;
/*Wilcoxon test*/
proc npar1way data=yearreteacher wilcoxon dscf plots=all;
    class Consider_Leaving;
    var Years_Continue_toWork;
run;

/* Difference for age worked and sex*/
*Males are slightly younger than females;
proc univariate data=yearreteacher normal plots cibasic;
    class Sex;
    var age;
    histogram age / overlay;
run;
proc ttest data = yearreteacher ;
	class Sex;
    var Age;run;
/* Difference between years worked*/
proc corr data=yearreteacher;
	var Years_Continue_toWork Years_atSchool Years_Worked;
run;
/********************hypothesis one - ANOVA or KRUSKALL WalliS********************/

proc ANOVA data=reteacher;
class Purpose_Work;
model age = Purpose_Work;
means Purpose_Work / tukey bon  cldiff;
run;

*Kruskal Wallis Test;
proc npar1way data=reteacher wilcoxon dscf;
    class Purpose_Work;
    var age;
run;
proc sgplot data=reteacher;
	where Purpose_Work is not missing;
   vbox age / group=Purpose_Work grouporder=descending;
   keylegend / title="Boxplot for Age of Teachers by Feelings of Purpose at Work";
run;

/*****************Hypothesis two - Correlation and ANOVA/KRUSKALL WALLIS/Regression***********/
proc univariate data=reteacher;
      var Age Life_Satisfaction Job_Satisfaction Student_Count;
      histogram Age Life_Satisfaction Job_Satisfaction Student_Count;
run;

*Kruskal Wallis Test;
proc npar1way data=reteacher wilcoxon dscf plots=all;
    class Trivial_Daily_Activities;
    var age;
run;
proc sgplot data=reteacher;
	where Trivial_Daily_Activities is not missing;
   vbox age / group=Trivial_Daily_Activities grouporder=descending;
   keylegend / title="Boxplot for Age of Teachers by Feelings of Having Trivial Daily Activities";
run;

proc npar1way data=reteacher wilcoxon dscf;
    class Enjoy_Future_Workplans;
    var age;
run;
proc sgplot data=reteacher;
	where Enjoy_Future_Workplans is not missing;
   vbox age / group=Enjoy_Future_Workplans grouporder=descending;
   keylegend / title="Boxplot for Age of Teachers by Enjoying Future Workplans";
run;


proc npar1way data=reteacher wilcoxon dscf;
    class Done_All_atWork;
    var age;
run;
proc sgplot data=reteacher;
	where Done_All_atWork is not missing;
   vbox age / group=Done_All_atWork grouporder=descending;
   keylegend / title="Boxplot for Age of Teachers by Feelings of Having Done all They can at Work";
run;
proc npar1way data=reteacher wilcoxon dscf;
    class Job_Useless;
    var age;
run;
proc sgplot data=reteacher;
	where Job_Useless is not missing;
   vbox age / group=Job_Useless grouporder=descending;
   keylegend / title="Boxplot for Age of Teachers by Feelings of Their Job being Useless";
run;
/**************CHI-SQ***************/
proc freq data = reteacher;tables sex*consider_leaving/all;run;

/***************************CORRELATIONS************************************/
proc corr data=reteacher;
	var Job_Useless Done_All_atWork Enjoy_Future_Workplans Trivial_Daily_Activities Purpose_Work;
run;

/* Difference between years worked*/
proc corr data=reteacher;
	var Years_Continue_toWork Years_atSchool Years_Worked Consider_Leaving Sex Age;
run;

*correlational analysis;
proc corr data = yearreteacher;
	var Years_Continue_toWork Years_atSchool Years_Worked Consider_Leaving 
	age Sex NotThinking_Clearly Distracted Easy_Concentrate 
	Felt_Focused Cheerful Calm_Relaxed Active_Rigorous Fresh_Rested
	Interested_Daily_Activities Hard_Think_Complicated Think_Slower
	Done_All_atWork Job_Useless Purpose_Work Trivial_Daily_Activities
	Enjoy_Future_Workplans Rely_Management Principal_Confidence 
	Colleagues_Trust_Me Teacher_Rely_Others Trust_Colleagues Enough_Time 
	Too_Much_Work Meet_Expectations Time_For_Breaks noTime_Personal Tasks_Affect_Teach;run;