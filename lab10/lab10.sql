--this lab was brought to you by G Leaden :)

--func1on PreReqsFor(courseNum)- Returns the immediate prerequisites for the passed-in course number. 


create or replace function get_prereqs_for_coursenum(int, REFCURSOR) returns refcursor as 
$$
declare
   coursenumber   int    := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select preReqNum
      from   Prerequisites
       where  courseNum=coursenumber;
   return resultset;
end;
$$ 
language plpgsql;
--example
select get_prereqs_for_coursenum(499, 'results');
Fetch all from results;



--func1on IsPreReqFor(courseNum)- Returns the courses for which the passed-in course number is an immediate pre-requisite


create or replace function is_prereq_for_coursenum(int, REFCURSOR) returns refcursor as 
$$
declare
   coursenumber   int    := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select courseNum
      from   Prerequisites
      where  prereqNum=coursenumber;
   return resultset;
end;
$$ 
language plpgsql;
--example
select is_prereq_for_coursenum(120, 'results');
Fetch all from results;