-- QUESTION 1
-- How many users does wave have?
SELECT COUNT(u_id) FROM users;

-- QUESTION 2
-- How many transfers have been sent in CFA?
SELECT COUNT(transfer_id)
FROM transfers
WHERE send_amount_currency='CFA'

-- QUESTION 3
-- How many different users have sent a transfer in CFA?
SELECT COUNT(u_id)
FROM transfers
WHERE send_amount_currency='CFA';

--QUESTION 4
-- How many agent_transaction did we have in the month of 2018?

SELECT COUNT (atx_id) 
FROM agent_transactions
WHERE EXTRACT(YEAR FROM when_created)= 2018
GROUP BY EXTRACT( MONTH FROM when_created);

--QUESTION 5
--Over the course of the last week, how many Wave agents were “net depositors” vs. “net withdrawers”?

WITH agent_withdrawers AS 
(SELECT COUNT(agent_id) AS netwithdrawers FROM agent_transactions
HAVING COUNT(amount) IN(SELECT COUNT(amount) FROM agent_transactions WHERE amount > -1
AND amount !=0 HAVING COUNT(amount)>(SELECT COUNT(amount)
FROM agent_transactions WHERE amount < 1 AND amount !=0)))
SELECT netwithdrawers FROM agent_withdrawers;

-- QUESTION 6
--Build an “atx volume city summary” table: find the volume of agent transactions created in the last week, grouped by city. You can determine the city where the agent transaction took place from the agent’s city field.

SELECT City, Volume INTO atx_volume_city_summary 
FROM ( Select agents.city AS City, count(agent_transactions.atx_id) 
AS Volume FROM agents INNER JOIN agent_transactions 
ON agents.agent_id = agent_transactions.agent_id 
where (agent_transactions.when_created > (NOW() - INTERVAL '1 week')) 
GROUP BY agents.city) as atx_volume_summary;

--QUESTION 7
--Separate the atx volume by country as well (so your columns should be country, city, volume).

SELECT City, Volume, Country INTO atx_volume_city_summary_with_Country 
FROM ( Select agents.city AS City, agents.country AS Country, count(agent_transactions.atx_id) AS Volume 
	  FROM agents INNER JOIN agent_transactions ON agents.agent_id = agent_transactions.agent_id 
	  where (agent_transactions.when_created > (NOW() - INTERVAL '1 week')) GROUP BY agents.country,agents.city) as atx_volume_summary_with_Country;
	  
	  
--QUESTION 8
--Build a “send volume by country and kind” table: find the total volume of transfers (by send_amount_scalar) sent in the past week, grouped by country and transfer kind. There are a few different kinds of Wave transfers

SELECT transfers.kind 
AS Kind, wallets.ledger_location 
AS Country, sum(transfers.send_amount_scalar) 
AS Volume FROM transfers INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id where (transfers.when_created > (NOW() - INTERVAL '1 week')) 
GROUP BY wallets.ledger_location, transfers.kind; 


--QUESTION 9
--add columns for transaction count and number of unique senders (still broken down by country and transfer kind).

 SELECT count(transfers.source_wallet_id) 
 AS Unique_Senders, count(transfer_id) 
 AS Transaction_count, transfers.kind 
 AS Transfer_Kind, wallets.ledger_location 
 AS Country, sum(transfers.send_amount_scalar) 
 AS Volume FROM transfers INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id where (transfers.when_created > (NOW() - INTERVAL '1 week')) 
 GROUP BY wallets.ledger_location, transfers.kind;
 
 
 --QUESTION 10
 --which wallets have sent more than 10,000,000 CFA in transfers in the last month (as identified by the source_wallet_id column on the transfers table), and how much did they send?

SELECT source_wallet_id, send_amount_scalar 
FROM transfers WHERE send_amount_currency = 'CFA' AND (send_amount_scalar>10000000) 
AND (transfers.when_created > (NOW() - INTERVAL '1 month'));
	 