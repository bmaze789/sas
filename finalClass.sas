
%macro GPA(letter, number);
	if Grade = "&letter" then GPAgrade = &number;
%mend GPA;

data final;
	infile "C:\Users\ward32\Downloads\Final_Data\*.txt" dlm="@" dsd missover; 
	length ID $ 5 Course $ 10;
	input ID $ Date Course $ Credit Grade $;
	*if Grade = "A" then GPAgrade = 4.0;
	%GPA(A,4.0);
	%GPA(A-,3.7);
	%GPA(B+,3.4);
	%GPA(B,3.0);
	%GPA(B-,2.7);
	%GPA(C+,2.4);
	*specify all GPA grades;
	if GPAgrade=. then GPAgrade=0;
	if Grade in ("A" "A-" "B+" "B" "B-" "D-" "P") then CredsEarned = Credit;
	else CredsEarned=0;
	Year = substrn(Date,2,2);
	Semester = substrn(Date,1,1);
run;

proc print data=final (obs=200);
run;

*semester GPA;
proc sql;
	create table semesterGPA as
	select ID, Year, Semester, sum(Credit*GPAgrade)/sum(Credit) as SemesterGPA
	from final
	where Grade not in ("A" "A-")
	group by ID, Year, Semester
	;
quit;

*case when Grade not in (....) then sum(Credit*GPAgrade) else 0 end / sum
*semeter Creds Earned;
proc sql;
	create table semesterCreds as
	select ID, Year, Semester, sum(CredsEarned) as SemesterCredEarned
	from final
	group by ID, Year, Semester
	;
quit;


proc sql;
	create table semester as
	select * 
	from semesterGPA as sg, semesterCreds as sc
	where sg.ID=sc.ID and sg.Year=sc.Year and sg.Semester=sc.Semester
	order by ID, Year, Semester
	;
quit;

data semester2;
	set semester;
	by ID Year Semester;
	retain cumCreds 0;
	if first.ID then cumCreds=0;
	cumCreds = cumCreds + SemesterCredEarned;
run;

proc print data=semester2 (obs=200);
run;
