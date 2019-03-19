*C:\Users\ward32\Downloads\Form A1.csv;

%macro readdata(form);
data student (keep=ID i StudentAns) answers (keep=ID i CorrectAns);
	infile "C:\Users\ward32\Downloads\Form &form.1.csv" dlm="," dsd missover;
	input ID $ blank (q1-q150) ($);
	array k{150} $ q1-q150;
	if ID = "&form.&form.&form.&form.KEY" then 
		do i = 1 to 150;
			CorrectAns=k{i};
			output answers;
		end;
	else 
		do i = 1 to 150;
			StudentAns = k{i};
			output student;
		end;
run; 

proc sql;
	create table summary&form. as
	select student.ID, 
		sum(case when CorrectAns=StudentAns then 1 else 0 end) as score
	from student, answers 
	where answers.i=student.i
	group by student.ID
	order by student.ID
	;
quit;

proc print data=summary&form.;
run;
%mend;
%readdata(A);
%readdata(B);


*******************DATA STEP Alternative****************;
data jared1;
	set jared;
	retain score 0;
	if CorrectAns=StudentAns then score+1;
run;

proc print data=jared1 (obs=200);
run;
*******************************************************;

*This is where we got to in class. I include the below to use if it is helpful;

*combine into one table;

proc sql;
	create table AllForms as
	select *
	from summaryA 
	union 
	select * 
	from summaryB
	;
quit;

*alternatively;

data AllFormsDataStep;
	set tableA tableB;
run;

proc sql;
	select * 
	from AllForms
	;
quit;
