-- EMPLOYEE ANALYSIS FROM ADVENTUREWORKS

-----------------Employee Demographics------------------
--1---How many employees do we have ???
select count(BusinessEntityID) [number of employee]
from
   HumanResources.Employee
--we have 290 employee in different field


--2---compare between employee in terms of gender???
select gender,count(BusinessEntityID) [number of employees],
CAST(count(BusinessEntityID)  AS FLOAT) / (select count(BusinessEntityID) from HumanResources.Employee) * 100 AS Percentage
from 
   HumanResources.Employee
group by gender
-- from this we concluded that number of male more than twice as much as female


--3---compare between employee in terms of maritalstatus???
select MaritalStatus,count(BusinessEntityID) [number of employees],
CAST(count(BusinessEntityID)  AS FLOAT) / (select count(BusinessEntityID) from HumanResources.Employee) * 100 AS Percentage
from 
   HumanResources.Employee
group by MaritalStatus
-- from this we concluded that the maritalstatus is almost equal


--4---Does maritalstatus affect the number of employees???
select gender,MaritalStatus,count(BusinessEntityID) [number of employees],
CAST(count(BusinessEntityID)  AS FLOAT) / (select count(BusinessEntityID) from HumanResources.Employee) * 100 AS Percentage
from
   HumanResources.Employee
group by MaritalStatus,gender
-- there is a very slight effect


--5---the age of each employee???
WITH Avgage
AS(
select concat(FirstName,' ',MiddleName,' ',LastName) fullname,Gender,MaritalStatus
,DATEDIFF(year,BirthDate,GETDATE()) age
from 
   HumanResources.Employee as e 
join
   Person.Person as p
on 
   e.BusinessEntityID=p.BusinessEntityID
)
select *,case when age <=45 then 'young employee'
when age between 46 and 60 then 'middle'
else 'old employee'
end division,(select avg(DATEDIFF(year,BirthDate,GETDATE()))
from HumanResources.Employee) [average age]
from Avgage
order by age
/*age range between 30 and 70 and 
we can concluded that average age is 45*/


------------------Basic Employee Information------------------

--6---how many employees in each jobtitle???
select JobTitle,count(BusinessEntityID) [number of employees]
from 
   HumanResources.Employee
group by JobTitle
order by [number of employees] desc
-- from this we concluded that we have 67 jobtitles


--7---How many employees in each department???
select d.DepartmentID,JobTitle,count(e.BusinessEntityID) [number of employees],
sum(count(e.BusinessEntityID)) over (partition by d.DepartmentID order by jobtitle) running
from HumanResources.Employee as e 
join HumanResources.EmployeeDepartmentHistory as em
on e.BusinessEntityID=em.BusinessEntityID
join HumanResources.Department as d
on d.DepartmentID=em.DepartmentID
group by d.DepartmentID,JobTitle 



--8---hiredate of each employee???
SELECT YEAR(HireDate) AS HireYear,COUNT(BusinessEntityID) AS [Number Of employee]
FROM 
   HumanResources.Employee
GROUP BY YEAR(HireDate)
ORDER BY HireYear;
-- the largest number has been employed in 2009 and the smallest in 2006


--9---shift of each employees???
select s.ShiftID,StartTime,EndTime,count(*) [number of employee]
from 
   HumanResources.Employee as e 
join 
   HumanResources.EmployeeDepartmentHistory as ed
on 
   e.BusinessEntityID=ed.BusinessEntityID
join
   HumanResources.Shift as s
on s.ShiftID=ed.ShiftID
group by s.ShiftID,StartTime,EndTime
--shift 1 has most number of employee


--10---vacation and sickleave hours
select concat(FirstName,' ',MiddleName,' ',LastName) fullname,VacationHours+SickLeaveHours as vacationhours
from HumanResources.Employee as e 
join Person.Person as p
on e.BusinessEntityID=p.BusinessEntityID
order by VacationHours+SickLeaveHours
 
 --ten most commited employees
WITH Commited_Employee
AS(select concat(FirstName,' ',MiddleName,' ',LastName) fullname,
 VacationHours+SickLeaveHours as vacationhours,
row_number() over(order by VacationHours+SickLeaveHours ) rank
from HumanResources.Employee as e 
join Person.Person as p
on e.BusinessEntityID=p.BusinessEntityID)
select top 10 c.fullname
from Commited_Employee as c


 --ten not commited employees
WITH Notcommited
AS(
select concat(FirstName,' ',MiddleName,' ',LastName) fullname,
 VacationHours+SickLeaveHours as vacationhours,
row_number() over(order by VacationHours+SickLeaveHours ) rank
from HumanResources.Employee as e 
join Person.Person as p
on e.BusinessEntityID=p.BusinessEntityID
)
select nc.fullname
from Notcommited as nc
where rank between 281 and 290
/* oldest person was very commited so we must rewared them */


--------------------information about sales person----------------------

--11-- number of orders that each saler sales
select concat(FirstName,' ',MiddleName,' ',LastName) as fullname
,count(soh.SalesOrderID) productionnumber
from Person.Person as p 
join Sales.SalesOrderHeader as soh
on p.BusinessEntityID=soh.SalesPersonID
group by concat(FirstName,' ',MiddleName,' ',LastName)
order by productionnumber
--(Jillian  Carson) sales the most orders


--12--sales of each sales 
select concat(FirstName,' ',MiddleName,' ',LastName) fullname,sum(TotalDue) sales
from 
   HumanResources.Employee as e
join 
   Person.Person as p
on 
   p.BusinessEntityID=e.BusinessEntityID
join 
   Sales.SalesOrderHeader as soh
on 
   p.BusinessEntityID=soh.SalesPersonID
group by concat(FirstName,' ',MiddleName,' ',LastName) 
order by sales desc

--who is the best 3 saler
WITH best_saler
AS(select concat(FirstName,' ',MiddleName,' ',LastName) fullname,sum(TotalDue) sales,
ROW_NUMBER() over(order by sum(TotalDue) desc) rank
from 
   HumanResources.Employee as e
join 
   Person.Person as p
on 
   p.BusinessEntityID=e.BusinessEntityID
join 
   Sales.SalesOrderHeader as soh
on 
   p.BusinessEntityID=soh.SalesPersonID
group by concat(FirstName,' ',MiddleName,' ',LastName) 
)
select fullname
from best_saler
where rank between 1 and 3


--13-- what is the relation between payfreq and performance of employee
select distinct PayFrequency,CONCAT(FirstName,' ',MiddleName,' ',LastName) fullname,
count(CONCAT(FirstName,' ',MiddleName,' ',LastName)) over(partition by PayFrequency order by CONCAT(FirstName,' ',MiddleName,' ',LastName))
from HumanResources.EmployeePayHistory as ep
join Person.Person as p
on ep.BusinessEntityID=p.BusinessEntityID
order by PayFrequency
--most employees have 1 payfreq. so this reduce there performance 


--14--compare between sales of each gender
select gender,concat(FirstName,' ',MiddleName,' ',LastName) as fullname ,sum(TotalDue) totalseles
,sum(sum(TotalDue)) over(partition by gender order by sum(TotalDue) ) runningsales
from HumanResources.Employee as e join Person.Person as p
on e.BusinessEntityID=p.BusinessEntityID
join Sales.SalesOrderHeader as soh
on soh.SalesPersonID=p.BusinessEntityID
group by gender,concat(FirstName,' ',MiddleName,' ',LastName)
-- performance of females is great so we should increace the number of female employees


--15--the most effective months
select year(OrderDate) year,MONTH(OrderDate) month,sum(TotalDue) sales
from Person.Person as p join Sales.SalesOrderHeader as soh
on p.BusinessEntityID=soh.SalesPersonID
where p.FirstName='Linda ' and p.LastName='Mitchell'
group by year(OrderDate) ,MONTH(OrderDate)
order by sales desc
--most sales for Linda C Mitchell was in 3/2014,6/2013,6/2012,10/2011

select year(OrderDate) year,MONTH(OrderDate) month,sum(TotalDue) sales
from Person.Person as p join Sales.SalesOrderHeader as soh
on p.BusinessEntityID=soh.SalesPersonID
where p.FirstName='Michael ' and p.LastName='Blythe'
group by year(OrderDate) ,MONTH(OrderDate)
order by sales desc
--most sales for Linda C Mitchell was in 3/2014,7/2013,6/2012,10/2011

select year(OrderDate) year,MONTH(OrderDate) month,sum(TotalDue) sales
from Person.Person as p join Sales.SalesOrderHeader as soh
on p.BusinessEntityID=soh.SalesPersonID
where p.FirstName='Jillian ' 
group by year(OrderDate) ,MONTH(OrderDate)
order by sales desc
--most sales for Linda C Mitchell was in 3/2014,7/2013,1/2012,10/2011
/* from  last three quary i concluded that 3/2014,10/2011 have the most sales*/