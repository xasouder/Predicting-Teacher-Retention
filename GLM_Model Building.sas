/************CHI_SQ test********************/
*proc freq data=reteacher;
*	tables  Purpose_Work*Trivial_Daily_Activities*Enjoy_Future_Workplans*Done_All_atWork*Job_Useless/ all;
*run;
/*************************
***SUMMARY OF DEPENDENT***
**************************/

/*proc freq data =reteacher;tables Years_Continue_toWork;run;*/
data yearreteacher;
set reteacher;if cmiss(of Years_Continue_toWork) then delete;
where Years_Continue_toWork is not null and Years_Continue_toWork<80;
run;

proc univariate data=yearreteacher normal ;
      var Years_Continue_toWork;
      histogram Years_Continue_toWork;
run;
proc freq data =yearreteacher;
	tables Years_Continue_toWork;run;


/****************************
*******MODEL BUILDING********
*****************************/
	
/*model full selection*/
proc GLMSELECT data=teachertrain;
	class NotThinking_Clearly Hard_Think_Complicated Think_Slower Distracted Easy_Concentrate
    Felt_Focused Cheerful Calm_Relaxed Active_Rigorous Fresh_Rested Interested_Daily_Activities
    Purpose_Work Trivial_Daily_Activities Enjoy_Future_Workplans Done_All_atWork Job_Useless
    Rely_Management Principal_Confidence Colleagues_Trust_Me Teacher_Rely_Others
	Trust_Colleagues Enough_Time Too_Much_Work Meet_Expectations Time_For_Breaks 
	noTime_Personal Tasks_Affect_Teach;
    
    model Years_Continue_toWork = NotThinking_Clearly Hard_Think_Complicated Think_Slower 
    Distracted Easy_Concentrate Felt_Focused Cheerful Calm_Relaxed Active_Rigorous 
    Fresh_Rested Interested_Daily_Activities Purpose_Work Trivial_Daily_Activities 
    Enjoy_Future_Workplans Done_All_atWork Job_Useless Rely_Management Principal_Confidence 
    Colleagues_Trust_Me Teacher_Rely_Others	Trust_Colleagues Enough_Time Too_Much_Work
    Meet_Expectations Time_For_Breaks noTime_Personal Tasks_Affect_Teach;
run;

/*Full model final version*/
proc glm data = teachertrain;
	class Job_Useless Enjoy_Future_Workplans noTime_Personal Done_All_atWork Cheerful 
	Principal_Confidence Purpose_Work Easy_Concentrate Meet_Expectations;
	model Years_Continue_toWork = Job_Useless Enjoy_Future_Workplans noTime_Personal
	Done_All_atWork Cheerful Principal_Confidence Purpose_Work Easy_Concentrate Meet_Expectations
	/ effectsize;
	code file = "/home/u64123092/nonpara/glmfullmodel.sas";
run;

data scored_data_full; 
set teachervalid;
%include "/home/u64123092/nonpara/glmfullmodel.sas";

proc sgplot data=scored_data;
  hbox P_years_continue_towork;
run;


/*******MODEL 1 BUILDING********/

/*model pt1 never - often*
proc GLMSELECT data=teachertrain;
	class NotThinking_Clearly Hard_Think_Complicated Think_Slower Distracted Easy_Concentrate
    Felt_Focused Cheerful Calm_Relaxed Active_Rigorous Fresh_Rested Interested_Daily_Activities;
    
    model Years_Continue_toWork = NotThinking_Clearly Hard_Think_Complicated Think_Slower 
    Distracted Easy_Concentrate Felt_Focused Cheerful Calm_Relaxed 
    Active_Rigorous Fresh_Rested Interested_Daily_Activities;
run;
proc glm data = teachertrain;
	class Cheerful Interested_Daily_Activities;
	model Years_Continue_toWork = Cheerful Interested_Daily_Activities/ effectsize;
	code file = "/home/u64123092/nonpara/glmmodel1.sas";
run;
data scored_data; 
set teachervalid;
%include "/home/u64123092/nonpara/glmmodel1.sas";

proc sgplot data=scored_data;
  hbox P_years_continue_towork;
run;


/*******MODEL 2 BUILDING********/

/*Model pt2 agree disagree*
proc glmselect data = teachertrain;
	class Rely_Management Principal_Confidence Colleagues_Trust_Me Teacher_Rely_Others
	Trust_Colleagues Enough_Time Too_Much_Work Meet_Expectations Time_For_Breaks 
	noTime_Personal Tasks_Affect_Teach Purpose_Work Trivial_Daily_Activities 
	Enjoy_Future_Workplans Done_All_atWork Job_Useless;
	
	model  Years_Continue_toWork = Rely_Management Principal_Confidence Colleagues_Trust_Me 
	Teacher_Rely_Others Trust_Colleagues Enough_Time Too_Much_Work
    Meet_Expectations Time_For_Breaks noTime_Personal Tasks_Affect_Teach
    Purpose_Work Trivial_Daily_Activities Enjoy_Future_Workplans Done_All_atWork Job_Useless;
run;

proc glm data = teachertrain;
	class Principal_Confidence noTime_Personal Meet_Expectations 
	Enough_Time Time_For_Breaks;
	model Years_Continue_toWork = Principal_Confidence noTime_Personal Meet_Expectations 
	 Enough_Time Time_For_Breaks Job_Useless Done_All_atWork Purpose_Work
	Enjoy_Future_Workplans Tasks_Affect_Teach/ effectsize;
	code file = "/home/u64123092/nonpara/glmmodel2.sas";
run;
data scored_data; 
set teachervalid;
%include "/home/u64123092/nonpara/glmmodel2.sas";

proc sgplot data=scored_data;
  hbox P_years_continue_towork;
run;
/* We have conducted these models, but there has to be a better way*/

