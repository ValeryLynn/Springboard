/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM  `Facilities` 
WHERE membercost >0
LIMIT 0 , 30


name	
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( membercost ) 
FROM  `Facilities` 
WHERE membercost >0

COUNT(membercost)	
5

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE (membercost >0) AND (membercost < ( .20 * monthlymaintenance ))
LIMIT 0 , 30


facid	name	membercost	monthlymaintenance	
0	Tennis Court 1	5.0	200
1	Tennis Court 2	5.0	200
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM  `Facilities` 
WHERE facid
IN ( 1, 5 ) 
LIMIT 0 , 30

name	membercost	guestcost	facid	initialoutlay	monthlymaintenance	
Tennis Court 2	5.0	25.0	1	8000	200
Massage Room 2	9.9	80.0	5	4000	3000


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name,
       monthlymaintenance,
       CASE WHEN monthlymaintenance > 100  THEN 'expensive'
            ELSE 'cheap' END AS label
  FROM `Facilities` 
  

name	monthlymaintenance	label	
Tennis Court 1	200	expensive
Tennis Court 2	200	expensive
Badminton Court	50	cheap
Table Tennis	10	cheap
Massage Room 1	3000	expensive
Massage Room 2	3000	expensive
Squash Court	80	cheap
Snooker Table	15	cheap
Pool Table	15	cheap
  

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT surname, firstname, joindate
FROM  `Members` 
WHERE joindate = (SELECT MAX( joindate ) FROM  `Members` )

surname	firstname	joindate	
Smith	Darren	2012-09-26 18:08:45


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT name AS  "Court Name", CONCAT( surname,  ", ", firstname ) AS  "Member Name"
FROM  `Bookings` b
INNER JOIN  `Members` m ON m.memid = b.memid
INNER JOIN  `Facilities` f ON b.facid = f.facid
WHERE name
IN ("Tennis Court 1",  "Tennis Court 2") AND surname NOT LIKE  'GUEST'
GROUP BY surname, firstname
LIMIT 0 , 30

Court Name	Member Name	
Tennis Court 2	Bader, Florence
Tennis Court 1	Baker, Anne
Tennis Court 2	Baker, Timothy
Tennis Court 2	Boothe, Tim
Tennis Court 1	Butters, Gerald
Tennis Court 1	Coplin, Joan
Tennis Court 1	Crumpet, Erica
Tennis Court 2	Dare, Nancy
Tennis Court 1	Farrell, David
Tennis Court 2	Farrell, Jemima
Tennis Court 1	Genting, Matthew
Tennis Court 1	Hunt, John
Tennis Court 2	Jones, David
Tennis Court 1	Jones, Douglas
Tennis Court 1	Joplette, Janice
Tennis Court 1	Owen, Charles
Tennis Court 1	Pinker, David
Tennis Court 2	Purview, Millicent
Tennis Court 2	Rownam, Tim
Tennis Court 2	Rumney, Henrietta
Tennis Court 2	Sarwin, Ramnaresh
Tennis Court 2	Smith, Darren
Tennis Court 1	Smith, Jack
Tennis Court 1	Smith, Tracy
Tennis Court 2	Stibbons, Ponder
Tennis Court 2	Tracy, Burton

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name, CONCAT( m.surname,  ", ", m.firstname ) AS  "Member Name ", (f.guestcost * b.slots) AS cost
FROM  `Bookings` b
JOIN  `Facilities` f ON b.facid = f.facid
JOIN  `Members` m ON m.memid = b.memid
WHERE starttime LIKE  '2012-09-14%'
AND m.memid =0
UNION 
SELECT name, CONCAT( m.surname,  ", ", m.firstname ) AS  "Member Name ", SUM(f.membercost * b.slots) AS cost
FROM  `Bookings` b
JOIN  `Facilities` f ON b.facid = f.facid
JOIN  `Members` m ON m.memid = b.memid
WHERE starttime LIKE  '2012-09-14%'
AND m.memid >0
GROUP BY m.memid
HAVING cost >30
ORDER BY cost DESC 
LIMIT 0 , 30

name	Member Name	cost	
Massage Room 2	GUEST, GUEST	320.0
Massage Room 1	GUEST, GUEST	160.0
Tennis Court 2	GUEST, GUEST	150.0
Tennis Court 1	GUEST, GUEST	75.0
Tennis Court 2	GUEST, GUEST	75.0
Squash Court	GUEST, GUEST	70.0
Massage Room 1	Farrell, Jemima	59.4
Squash Court	GUEST, GUEST	35.0
Tennis Court 1	Tracy, Burton	34.8

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT sub.name, CONCAT( m.surname,  ", ", m.firstname ) AS  "Member Name ", sub. cost
FROM  `Members` m
JOIN  (
SELECT b.memid, f.name, (guestcost*slots) AS cost
FROM `Bookings` b
JOIN `Facilities` f ON b.facid = f.facid
WHERE starttime LIKE  '2012-09-14%'
AND memid=0
) sub
ON m.memid=sub.memid
WHERE cost > 30
UNION
SELECT subm.name, CONCAT( m.surname,  ", ", m.firstname ) AS  "Member Name ", subm. Cost
FROM `Members` m 
JOIN (
SELECT b.memid, f.name, SUM( f.membercost * b.slots ) AS cost
FROM  `Bookings` b
JOIN  `Facilities` f ON b.facid = f.facid
JOIN  `Members` m ON m.memid = b.memid
WHERE starttime LIKE  '2012-09-14%'
AND m.memid > 0
GROUP BY m.memid
) subm
ON m.memid=subm.memid
WHERE cost > 30
ORDER BY cost DESC
LIMIT 0, 30

name	Member Name	cost	
Massage Room 2	GUEST, GUEST	320.0
Massage Room 1	GUEST, GUEST	160.0
Tennis Court 2	GUEST, GUEST	150.0
Tennis Court 1	GUEST, GUEST	75.0
Tennis Court 2	GUEST, GUEST	75.0
Squash Court	GUEST, GUEST	70.0
Massage Room 1	Farrell, Jemima	59.4
Squash Court	GUEST, GUEST	35.0
Tennis Court 1	Tracy, Burton	34.8

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f.name, SUM( 
CASE WHEN b.memid =0
THEN f.guestcost * b.slots
ELSE f.membercost * b.slots
END ) AS revenue
FROM  `Facilities` f
JOIN  `Bookings` b ON f.facid = b.facid
GROUP BY f.name
HAVING revenue <1000
ORDER BY revenue DESC 
LIMIT 0 , 30

name	revenue	
Pool Table	270.0
Snooker Table	240.0
Table Tennis	180.0



