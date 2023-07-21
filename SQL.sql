select * from Mculine_updated.dbo.['140948278$'];


select count(distinct customerId) from Mculine_updated.dbo.['140948278$'];

  ---q1 monthly growth
select datename(mm,createdDate),datename(yy,createdDate),sum(total),
(sum(total)-lag(sum(total)) over (order by datename(mm,createddate)))*100/lag(total,1) over (order by datename(mm,createddate)) as growth
from Mculine_updated.dbo.['140948278$']
group by datename(mm,createdDate),datename(yy,createdDate),total;

SELECT
  datename(mm,createdDate),
  total,
  (total - LAG(total) OVER (ORDER BY (datename(mm,createdDate)))) / LAG(total) OVER (ORDER BY (datename(mm,createdDate))) * 100 AS growth_percentage
FROM
  (
    SELECT
      datename(yy,createdDate),
      datename(mm,createdDate),
      sum(Total) AS sales
    FROM
      Mculine_updated.dbo.['140948278$']
    GROUP BY
      datename(yy,createdDate),
      datename(mm,createdDate)
  ) AS monthly_sales
ORDER BY
  datename(mm,createdDate);


SELECT 
    DATEPART(YEAR, createdDate) AS Year,
    DATEPART(MONTH, createdDate) AS Month,
    SUM(Total) AS SalesAmount,
    SUM(Total) - LAG(SUM(Total)) OVER (ORDER BY DATEPART(YEAR, createdDate), DATEPART(MONTH, createdDate)) AS SalesGrowth
FROM 
    Mculine_updated.dbo.['140948278$']
GROUP BY 
    DATEPART(YEAR, createdDate), 
    DATEPART(MONTH, createdDate);


	SELECT 
    DATEPART(YEAR, createdDate) AS Year,
    DATEPART(MONTH, createdDate) AS Month,
    SUM(Total) AS SalesAmount,
    CONCAT(ROUND((SUM(Total) - LAG(SUM(Total)) OVER (ORDER BY DATEPART(YEAR, createdDate), DATEPART(MONTH, createdDate))) / LAG(SUM(Total)) OVER (ORDER BY DATEPART(YEAR, createdDate), DATEPART(MONTH, createdDate)) * 100, 2), '%') AS SalesGrowth
FROM 
    Mculine_updated.dbo.['140948278$']
GROUP BY 
    DATEPART(YEAR, createdDate), 
    DATEPART(MONTH, createdDate)



select month(createdDate) as Months,year(createddate) as years,sum(total) as monthly_sales,((sum(total)-(select sum(total) 
from Mculine_updated.dbo.['140948278$']
where month(createddate)=month(createddate)-1))/(select sum(total)
from Mculine_updated.dbo.['140948278$']
where month(createddate)=month(createddate)-1))*100/sum(total) as monthly_growth_percent
from Mculine_updated.dbo.['140948278$']
group by month(createdDate),year(createddate)
order by month(createddate),year(createdDate);

---- q2 display the repeat customer with avaerage cart value
select shippingFirstname,avg(total) as avg_cart_value,sum(total) as total_cart_value, count(shippingFirstname) as repeat_count
from Mculine_updated.dbo.['140948278$']
group by shippingFirstname having count(*)>1
order by repeat_count desc;

---q3 month wise returning customer

with first_visit as (
select shippingFirstname,min(createdDate) as first_visit_date
from Mculine_updated.dbo.['140948278$']
group by shippingFirstname)
select datename(mm,VE.createdDate) as months,datename(yy,createdDate) as years,count(VE.shippingfirstname) as total_count
, sum(case when VE.createdDate=FV.first_visit_date then 1 else 0 end) as first_visit_flag
, sum(case when VE.createdDate!=first_visit_date then 1 else 0 end) as Repeat_visit_flag
from Mculine_updated.dbo.['140948278$'] as VE
inner join first_visit as FV on VE.shippingFirstname=FV.shippingFirstname
group by datename(mm,VE.createdDate),datename(yy,createdDate)
order by datename(yy,createdDate),datename(mm,VE.createdDate);



---q4 display the payment mode for returning customer
with first_visit as (
select shippingFirstname,min(createdDate) as first_visit_date
from Mculine_updated.dbo.['140948278$']
group by shippingFirstname)
select VE.paymentMethod,count(VE.paymentMethod) as total_count
, sum(case when VE.createdDate!=first_visit_date then 1 else 0 end) as Repeat_visit_flag
from Mculine_updated.dbo.['140948278$'] as VE
inner join first_visit as FV on VE.shippingFirstname=FV.shippingFirstname
group by VE.paymentMethod;


---q5 state wise returing customer
with first_visit as (
select shippingFirstname,min(createdDate) as first_visit_date
from Mculine_updated.dbo.['140948278$']
group by shippingFirstname)
select VE.shippingZone,count(VE.paymentMethod) as total_count
, sum(case when VE.createdDate!=first_visit_date then 1 else 0 end) as Repeat_visit_flag
from Mculine_updated.dbo.['140948278$'] as VE
inner join first_visit as FV on VE.shippingFirstname=FV.shippingFirstname
group by VE.shippingZone;

---q6 product wise returning customer
with first_visit as (
select shippingFirstname,min(createdDate) as first_visit_date
from Mculine_updated.dbo.['140948278$']
group by shippingFirstname)
select VE.products,count(ve.products) as total_customer
, sum(case when VE.createdDate!=first_visit_date then 1 else 0 end) as Repeat_visit_flag
from Mculine_updated.dbo.['140948278$'] as VE
inner join first_visit as FV on VE.shippingFirstname=FV.shippingFirstname 
group by VE.products
order by Repeat_visit_flag desc;


---q7 last buying month of returning customer
with first_visit as (
select shippingFirstname,min(createdDate) as first_visit_date
from Mculine_updated.dbo.['140948278$']
group by shippingFirstname)
select VE.shippingFirstname, max(VE.createdDate) as last_purchase
, sum(case when VE.createdDate!=first_visit_date then 1 else 0 end) as Repeat_visit_flag
from Mculine_updated.dbo.['140948278$'] as VE
inner join first_visit as FV on VE.shippingFirstname=FV.shippingFirstname
group by VE.shippingFirstname
order by Repeat_visit_flag desc;

---q8 turnaround time of repeating customer
alter table Mculine_updated.dbo.['140948278$']
add  Purchase_times time;

alter table Mculine_updated.dbo.['140948278$']
add  Purchase_date date;

update Mculine_updated.dbo.['140948278$']
set Purchase_date= substring(createdDate,1,10);

select customerId,shippingfirstname, count(*) as total_count
,(case when count(*)>1 then datediff(day,min(Purchase_date),max(Purchase_date)) end) as avg_time_diff
from Mculine_updated.dbo.['140948278$']
group by customerid,shippingfirstname
order by total_count desc;

