WITH  


SanJoseNormalized AS 
(
SELECT
  'San Jose' AS city,
  'CA' AS state,
  "Date Created" AS start_event_date,
  "Date Last Updated" AS end_event_date,
  Longitude AS longitude,
  Latitude AS latitude,
  Incident_ID AS ticket_id,
  'NULL' AS street_address,
  'NULL' AS street,
  'NULL' AS zipcode,
  Category AS description, 
  'NULL'  AS description_details,
  "Service Type"  AS category,
  Department AS activity,
  Status AS status,
  Source AS method,
  'NULL' AS outcome,
  'san jose'  AS neighborhood,
FROM sanjose
),

BostonNormalized AS 
(
SELECT
  'Boston' AS city,
  'MA' AS state,
  open_dt AS start_event_date,
  closed_dt AS end_event_date,
  longitude AS longitude,
  latitude AS latitude,
  case_enquiry_id AS ticket_id,
  location_street_name AS street_address,
  LOWER(array_slice(location_street_name, LENGTH(SPLIT(location_street_name, ' ')[1]) + 2, 100)) AS street,
  location_zipcode AS zipcode,
  reason AS description, 
  'NULL' AS description_details,
  subject AS category,
  type AS activity,
  case_status AS status,
  source AS method,
  REPLACE(closure_reason, 'Case Closed ', '') AS outcome,
  neighborhood as neighborhood
FROM boston
),



Together AS (

SELECT * FROM SanJoseNormalized
  UNION ALL 
SELECT * FROM BostonNormalized

)


SELECT
  DATE_DIFF('HOUR', start_event_date, end_event_date) AS date_diff_in_hours,
  CASE 
    WHEN LOWER(status) IN ('open', 'new', 'in progress') THEN 'Active' 
    WHEN status IN (NULL, 'NULL') THEN 'Unknown' 
    ELSE 'Closed' 
    END AS status_type,
  CAST(ticket_id AS VARCHAR) AS ticket_id,
  LOWER(category) AS category,
  * exclude(ticket_id, category)
FROM Together 
WHERE start_event_date >= '2023-01-01' 
