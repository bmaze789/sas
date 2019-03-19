data people;
input name $ @@;
datalines;
jim bob angie cal cal cal harriet oswald marty
;

data out;
input name $ @@;
datalines;
cal cal harry
;

proc sql;
	select name from out except select name from people ;
	select name from people except all select name from out;

	select name from people intersect select name from out;
	select name from people intersect all select name from out;
	
quit;

data people2;
	input name $ id @@;
	datalines;
	bob 1 jim 2 harriet 3
	;

proc sql;
	select * from people union all corr select * from people2;
	select * from people outer union corr select * from people2;

quit;
