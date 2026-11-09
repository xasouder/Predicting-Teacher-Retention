proc freq data = work.reteacher;table CNT;run;

proc freq data = work.reteacher;table SUBNATIO;run;



/* Call macro */
%generate_barcharts(WORK.reteacher);

proc template;
  define statgraph barchart;
    begingraph;
      entrytitle "Average Mileage by Vehicle Type";
      layout overlay;
        barchart x=tchtype  /
          stat=mean orient=horizontal;
      endlayout;
    endgraph;
  end;

proc sgrender data=work.reteacher template=barchart;
run;

/******Stratified Confidence interval********/
/* SET MAX DEC ON SPEED VARIABLE so the datalabels are not too long on graphic*/
/*
data work.seatbeltVSspeedMAXDEC;
set work.seatbeltVSspeed;
format speed 6.2;
run;*/

/* setting th ehiehgt and width makes this strified conf interval plot nicer looking*//*
ods graphics on/width  = 5in height = 2in output=svg;
title1 height=1.5 "90% Confidence Intervals of Speed (mph)" JUSTIFY = center;
title2 height = 1.25 "Stratifeid over Whether the Driver is Wearing a Seatbelt" JUSTIFY=center;
proc sgplot data = work.seatbeltVSspeedMAXDEC noautolegend;
		dot beltVSno/response = speed stat = mean limitstat = clm alpha=.10 datalabel
	datalabelattrs=(size=12 color = "#13478C");
		yaxis label=
*/