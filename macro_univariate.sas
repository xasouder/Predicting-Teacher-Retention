%macro generate_barcharts(dataset);

    /* Get the list of all variables in the dataset */
    proc contents data=&dataset out=var_list(keep=name type) noprint;
    run;
	
    /* Count the number of variables */
    data _null_;
        set var_list end=eof;
        retain count 0;
        count + 1;
        if eof then call symputx('num_vars', count);
    run;

    /* Loop through each variable */
    %do i = 1 %to &num_vars;
        /* Get the i-th variable name */
        data _null_;
            set var_list;
            if _N_ = &i then call symputx('var', name);
        run;

        /* Create a bar chart for the variable */
        proc sgplot data=&dataset;
            vbar &var;
            title "Bar Chart of &var";
        run;
    %end;
%mend generate_barcharts;
