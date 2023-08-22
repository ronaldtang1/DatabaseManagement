-- 1. 
-- correct
-- old style join
select p.per_id, per_fname, per_lname, per_street, per_city, per_city, emp_salary, fac_start_date 
from person as p, employee as e, faculty as f
where p.per_id = e.per_id
and e.per_id = f.per_id;

-- correct
-- join on
select p.per_id, per_fname, per_lname, per_street, per_city, per_city, emp_salary, fac_start_date 
from person p
join employee e on p.per_id = e.per_id
join faculty f on e.per_id = f.per_id;

-- join using
select p.per_id, per_fname, per_lname, per_street, per_city, per_city, emp_salary, fac_start_date 
from person 
join employee using (per_id)
join faculty using (per_id);

-- natural join
select p.per_id, per_fname, per_lname, per_street, per_city, per_city, emp_salary, fac_start_date 
from person 
natural join employee
natural join faculty;

-- 2.
-- correct
-- old style join
select p.per_id, per_fname, per_lname, per_gender, per_dob, deg_type, deg_area, deg_date
from person p, alumnus a, degree d
where p.per_id = a.per_id
and a.per_id=d.per_id
limit 10;

-- correct
-- join using
select per_id, per_fname, per_lname, per_gender, per_dob, deg_type, deg_area, deg_date
from person
join alumnus using (per_id)
join degree using (per_id)
limit 0,10;

-- 3.
-- old style
select p.per_id, per_fname, per_lname, stu_major, ugd_test, ugd_scorfe, ugd_standing
from person p, student s, undergrad u
where p.per_id = s.per_id
and s.per_id = u.per_id
order by per_id desc 
limit 0,20;

select per_id, per_fname, per_lname, stu_major, ugd_test, ugd_scorfe, ugd_standing
from person 
natural join student
 natural join undergrad
 order by per_id desc
 limit 0,20;
 
 -- 4.
 -- check staff data
 select * from staff;
  
-- delete first 10 staff members
 delete from staff
 order by per_id
 limit 10;
 
 -- recheck staff data 
 select * from staff;
 
 -- delete last three staff members
 delete from staff
 order by per_id desc limit 3;
 
  -- recheck staff data 
 select * from staff;
 
-- 5
-- check data
select * from grad;

 update grad 
 set grd_score = grd_score * 1.10
 where per_id=27 and grd_test='gmat';
 
 -- check data againto verify
select * from grad;

-- 6.
-- check alumnus data
select * from alumnus;

-- inserts two alumnus 
insert into alumnus
(per_id, alm_notes)
values
(97, "testing1"),
(98, "testing2"); 

-- check alumnus data again
select * from alumnus;






