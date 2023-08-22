1. List all the contents (rows or records) of the ORDERS table. 

select * from orders;


2. Create an alias for an attribute name.

select slsrep_number as slsrep_num 
from sales_rep 
where slsrep_number='06';
  

3. List the order line number, part number, number ordered, and quoted price from the 
ORDER_LINE table in ascending order by quoted price.  

select order_number, part_number, number_ordered, quoted_price 
from order_line 
order by quoted_price asc;


4. Remove part number CB03 from the PART table.  

delete 
from part 
where part_number='cb03';


5. Modify the city, state, and zip code of sales rep number 06.

update sales_rep 
set city='Tallahassee', state='FL', zip_code='32304' 
where slsrep_number='06';


6. Add two records to the part table.

INSERT INTO part (part_number, part_description, units_on_hand, item_class, warehouse_number, unit_price) 
VALUES ('yyy', 'Widget1', '5', 'SS', 1, 9.95),
('zzz', 'Widget2','10','TT',2,10.95);

INSERT INTO part 
VALUES ('uuu','Widget1','5','SS',1,9.95), 
('ttt','Widget2','10','TT',2,10.95);


7. List all dealership names, vehicle types and makes for each dealership (use EQUI-
JOIN, aka "old-style" join).  

select dlr_name, veh_type, veh_make 
from dealership, vehicle 
where dealership.dlr_id = vehicle.dlr_id;


8. List all dealership names, as well as all sales reps first, last names, and their total 
sales for each dealership (use JOIN ON). 

select dlr_name, srp_fname, srp_lname, srp_tot_sales
from dealership
join slsrep on dealership.dlr_id = slsrep.dlr_id;


9. List how many vehicles each dealership owns (display dealer id, name, and 
*number* of vehicles for each dealership), use JOIN USING. 

select dlr_id, dlr_name, count(veh_type) 
from dealership 
join vehicle using (dlr_id) 
group by dlr_id;

10. List each dealership's total sales, include dealer's name and total sales (captured in 
dealership_history table), use NATURAL JOIN. 

select dlr_name, sum(dhs_ytd_sales) as total_sales 
from dealership 
natural join dealership_history 
group by dlr_id;


11. List the average total sales for each sales rep in each dealership, include dealer ID, 
name, sales reps' id, and first and last names, use NATURAL JOIN. 

select dlr_id, dlr_name, srp_id, srp_lname, srp_fname, avg(srp_tot_sales) 
from dealership 
natural join slsrep 
group by dlr_id, srp_id;
