/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT *
FROM `Facilities`
WHERE membercost = 0
LIMIT 0 , 30

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( membercost ) AS zero_cost_facility
FROM `Facilities`
WHERE membercost =0
LIMIT 0 , 30

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities`
WHERE membercost <>0
AND membercost < 0.2 * monthlymaintenance
LIMIT 0 , 30

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 )
LIMIT 0 , 30

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE
WHEN monthlymaintenance >100
THEN 'expensive'
WHEN monthlymaintenance <=100
THEN 'cheap'
END AS cheap_or_expensive
FROM `Facilities`
LIMIT 0 , 30


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname, MAX( joindate ) AS most_recent_mem
FROM `Members`
WHERE firstname <> 'GUEST'

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT_WS( ' ', m.firstname, m.surname ) AS full_name, f.name
FROM `Bookings` AS b
INNER JOIN `Facilities` AS f
USING ( facid )
INNER JOIN `Members` AS m
USING ( memid )
WHERE f.name LIKE 'Tennis Court%'
GROUP BY full_name
LIMIT 0 , 30


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT CONCAT_WS( ' ', m.firstname, m.surname ) AS full_name, f.name,
CASE
WHEN CONCAT_WS( ' ', m.firstname, m.surname ) NOT LIKE 'GUEST%'
AND b.slots * f.membercost >30
THEN b.slots * f.membercost
WHEN CONCAT_WS( ' ', m.firstname, m.surname ) LIKE 'GUEST%'
AND b.slots * f.guestcost >30
THEN b.slots * f.guestcost
ELSE 0 END AS total_cost
FROM `Bookings` AS b
INNER JOIN `Facilities` AS f ON b.facid = f.facid
INNER JOIN `Members` AS m ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
ORDER BY total_cost DESC
LIMIT 0 , 30


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT sub.full_name, sub.name, sub.total_cost
FROM (
SELECT CONCAT_WS( ' ', m.firstname, m.surname ) AS full_name, f.name,
CASE
WHEN CONCAT_WS( ' ', m.firstname, m.surname ) NOT LIKE 'GUEST%'
AND b.slots * f.membercost >30
THEN b.slots * f.membercost
WHEN CONCAT_WS( ' ', m.firstname, m.surname ) LIKE 'GUEST%'
AND b.slots * f.guestcost >30
THEN b.slots * f.guestcost
ELSE 0
END AS total_cost
FROM `Bookings` AS b
INNER JOIN `Facilities` AS f ON b.facid = f.facid
INNER JOIN `Members` AS m ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
) AS sub
WHERE sub.total_cost >0
ORDER BY sub.total_cost DESC
LIMIT 0 , 30

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT sub.name, SUM( sub.total_cost ) AS revenue
FROM (
SELECT f.name,
CASE
WHEN CONCAT_WS( ' ', m.firstname, m.surname ) NOT LIKE 'GUEST%'
THEN b.slots * f.membercost
WHEN CONCAT_WS( ' ', m.firstname, m.surname ) LIKE 'GUEST%'
THEN b.slots * f.guestcost
ELSE 0
END AS total_cost
FROM `Bookings` AS b
INNER JOIN `Facilities` AS f ON b.facid = f.facid
INNER JOIN `Members` AS m ON b.memid = m.memid
) AS sub
GROUP BY sub.name
HAVING revenue <1000
ORDER BY revenue


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT DISTINCT sub.sur_first, sub.name_of_recommender
FROM (
SELECT CONCAT_WS( ' ', m.surname, m.firstname ) AS sur_first,
CASE
WHEN m.recommendedby IS NOT NULL
THEN CONCAT_WS( ' ', m2.surname, m2.firstname )
ELSE NULL
END AS name_of_recommender
FROM `Members` AS m
LEFT JOIN `Members` AS m2 ON m.recommendedby = m2.memid
WHERE m.firstname NOT LIKE 'GUEST%'
) AS sub
ORDER BY sub.name_of_recommender
LIMIT 0 , 30


/* Q12: Find the facilities with their usage by member, but not guests */
SELECT sub.member, sub.name, sub.facility_usage
FROM (
SELECT 
CONCAT_WS(' ', m.firstname, m.surname) AS member, 
f.name, 
COUNT(DISTINCT f.name) AS facility_usage
FROM `Bookings` AS b
LEFT JOIN `Facilities` AS f ON b.facid = f.facid
LEFT JOIN `Members` AS m ON b.memid = m.memid
WHERE m.firstname NOT LIKE 'GUEST%'
GROUP BY member
HAVING COUNT(DISTINCT b.facid) >= 0
) AS sub
ORDER BY sub.facility_usage DESC
LIMIT 0, 30;


/* Q13: Find the facilities usage by month, but not guests */
SELECT sub.month, sub.name, sub.facility_usage
FROM (
SELECT DATE_FORMAT( b.starttime, '%Y-%m' ) AS
MONTH , f.name, COUNT( b.facid ) AS facility_usage
FROM `Bookings` AS b
LEFT JOIN `Facilities` AS f ON b.facid = f.facid
LEFT JOIN `Members` AS m ON b.memid = m.memid
WHERE m.firstname NOT LIKE 'GUEST%'
GROUP BY month, f.name
HAVING COUNT( DISTINCT b.facid ) >=0
) AS sub
ORDER BY sub.month DESC, sub.facility_usage DESC
LIMIT 0 , 30
