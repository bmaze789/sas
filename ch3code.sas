/* Cartesian Products */ 
data table1;
	input A B $;
datalines;
1 a
2 b
3 c
4 d
5 b
6 g
;

data table2;
	input A C $;
datalines;
1 d
2 e
3 g
4 f
5 d
6 g
;


proc sql;
	select * from table1, table2;
		/*This will result in a Cartesian product of the two talbes: not interesting!*/
	/*Inner Products */
	select table1.A, B, C from table1, table2 where table1.A = table2.A;
		/*It just will stick the two tables together */
	select * from table1, table2 where table1.A = table2.A;
	select * from table1, table2 where table1.B = table2.C;
quit;

/* Notice that in the output there are multiple values that match
	an Inner join will display all combinations of mergres between
	the two datasets */
data table3;
input A B $;
datalines;
1 a
2 b
2 c
4 a
;
data table4;
input A C $;
datalines;
1 g
1 f
2 d
2 s
3 a
;
proc sql;
select table3.*, C
from table3,table4
where table3.A=table4.A;
quit;


/* Left Join */
proc sql;
select *
from table3
Left join
table4
on table3.A=table4.A;

select *
from table3
Right join
table4
on table3.A=table4.A;

select table3.A,b,c
from table3
Full join
table4
on table3.A=table4.A;

quit;


