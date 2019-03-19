%macro GPA(letter, number);
	if Grade = "&letter" then GPAgrade = &number;
%mend GPA;

data GPAFinal;
	infile "/home/bmaze180/stat224/file_data/*.txt" dlm= "@" dsd missover;
	length ID $ 5 Course $ 10;
	input ID $ Date Course $ Credit Grade $;
	*if Grade = "A" then GPAgrade = 4.0;
	%GPA(A,4.0);
	%GPA(A-,3.7);
	%GPA(B+,3.4);
	%GPA(B,3.0);
	%GPA(B-,2.7);
	%GPA(C+,2.4);
	%GPA(C,2.0);
	%GPA(C-,1.7);
	%GPA(D+,1.4);
	%GPA(D,1.0);
	%GPA(D-,0.7);
	%GPA(other,0);
	
if GPAgrade=. then GPAgrade=0;

	if substr(Grade,1,1) = "P" then 
		CreditEarned=0;
	else CreditEarned= Credit;
run;

data math;
	set GPAFinal;
	where Course =:"STAT" or Course=:"MATH";
run;
proc sort data=math ;
	by ID;
run;

%macro calcGPA(value,tab);
proc sql;
	create table rep1&value as
	select ID, Date, sum(GPAgrade*CreditEarned) as weight,
		sum(GPAgrade*CreditEarned)/sum(CreditEarned) as Semester_GPA,
		sum(CreditEarned) as GradedCredits,
		sum(Credit) as Credits
		
	from &value
	group by ID, Date	
	;
quit;

proc sql;
	create table Gsum&value as
	select ID, sum(count(Grade,"A")) as A,
	sum(count(Grade,"B")) as B,
	sum(count(Grade,"C")) as C,
	sum(count(Grade,"D")) as D,
	sum(count(Grade,"E")) as E,
	sum(count(Grade,"W")) as W,
	sum(count(Grade,"P")) as P_s,
	sum(GPAgrade*CreditEarned)/sum(CreditEarned) as OverallGPA,
	sum(Credit) as OverallCredits,
	sum(CreditEarned) as OverallGraded
	from &value
	group by ID
	;
quit;

proc sql;
	create table var&value as
	select ID, count(distinct Course) as DisCour,
		count(Course) as Courses,
		calculated Courses- calculated DisCour as Repeats&tab
		
		from &value
		group by ID
		;
quit;

data tabs1&value;
	set rep1&value;
	length Class_Standing $ 9;
	by ID Date;	
	retain CWeight 0;
	
	if first.ID then CWeight=0;
		CWeight=CWeight+weight;
		retain Graded_Credits 0;
	if first.ID then Graded_Credits=0;
		Graded_Credits= (Graded_Credits+GradedCredits);
		Cumulative_GPA= (CWeight/Graded_Credits);
		retain Cumulative_Credits 0;
		
	if first.ID then Cumulative_Credits=0;
		Cumulative_Credits= (Cumulative_Credits+Credits);
		
	if Cumulative_Credits le 29.9 then Class_Standing = "Freshman";
	else if Cumulative_Credits le 59.9 then Class_Standing= "Sophomore";
	else if Cumulative_Credits le 89.9 then Class_Standing= "Junior";
	else Class_Standing= "Senior";	
run;

	
proc sql;
	create table report1a&value as
	select ID, Date, Semester_GPA, Cumulative_GPA, Cumulative_Credits, Graded_Credits, Class_Standing
	from tabs1&value;
quit;

data report&value (drop=Courses DisCour);
	merge report1a&value var&value Gsum&value;
	by ID;
run;

%mend calcGPA;
%calcGPA(GPAFinal,F)
%calcGPA(math,M)

proc sql;
	create table report2a as
	select ID,OverallGPA, OverallCredits, OverallGraded,  
	A, B, C, D, E, W
	
	from GsumGPAFinal;
quit;
proc sql;
	create table report2b as
	select ID,OverallGPA as mathGPA, OverallCredits as mathCredits,
	OverallGraded as mathGradCredits, 
	A as MathAs, B as MathBs, C as MathCs, D as MathDs, E as
	MathEs, W as MathWs
	
	from Gsummath
	order by ID;
quit;

data report2 (drop= DisCour Courses);
	merge report2a (rename=(A=As B=Bs C=Cs D=Ds E=Es W=Ws)) varGPAFinal (rename=(RepeatsF=Repeats)) 
	  report2b  varmath(rename=(RepeatsM=MSRepeats)) ;
	by ID ;
run;


data report3;
	set report2;
	where OverallCredits <130 and OverallCredits > 60;	
run;

proc sort data=report3;
	by descending OverallGPA;
run;

data report4;
	set report2;
	where mathGradCredits gt 20;
run;

proc sort data=report4;
	by descending OverallGPA;
run;

proc sql;
	select round(count(ID)/10) into :repo3
	from report3
	;
quit;
proc sql;
	select round(count(ID)/10) into :repo4
	from report4
	;
quit;

ods html file="/home/bmaze180/stat224/FinalReport.html";

title "Report 1";
proc print data= reportGPAFinal;
	var ID Semester_GPA Cumulative_GPA Cumulative_Credits Graded_Credits Class_Standing RepeatsF
	A B C D E W;
run;

title "Report 2";
proc report data= report2;
run;

title "Report 3";
proc print data=report3 (obs=&repo3);
	var ID OverallGPA;
run;

title "Report 4";
proc print data=report4(obs= &repo4);
	var ID OverallGPA;
run;

ods html close;