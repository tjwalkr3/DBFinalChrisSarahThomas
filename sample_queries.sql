-- Concessions Test 1: Show total number of each item for each seat
select cp.seat_id,
	p.concession_name, 
	p.price,
	cpp.quantity
from product p
inner join concession_purchase_product cpp 
on (p.id = cpp.product_id)
inner join concession_purchase cp 
on (cpp.concession_purchase_id = cp.id)
inner join payment p2 
on (cp.payment_id = p2.id)
group by (p.concession_name, p.price, cpp.quantity, cp.seat_id)
order by cp.seat_id asc;

-- Concessions Test 2: Get total concession cost for each seat
select cp.seat_id, sum(p.amount) as total_concession_cost
from concession_purchase cp
inner join seat s
on (cp.seat_id = s.id) 
inner join payment p
on (cp.payment_id = p.id)
group by cp.seat_id 
order by cp.seat_id asc;
