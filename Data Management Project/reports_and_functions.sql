query1:
SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the monthly donation trends per shelter and donor.
PROMPT
PROMPT Shelter Donation Report
PROMPT -----------------------------------------------

ACCEPT v_Month CHAR PROMPT 'Enter Month (e.g., 2023-08): '

COLUMN shelter_name FORMAT A25
COLUMN donor_firstname FORMAT A20
COLUMN donor_lastname FORMAT A20
COLUMN month FORMAT A10
COLUMN total_donations FORMAT $999999.99

COLUMN shelter_name HEADING 'Shelter Name'
COLUMN donor_firstname HEADING 'Donor First Name'
COLUMN donor_lastname HEADING 'Donor Last Name'
COLUMN month HEADING 'Month'
COLUMN total_donations HEADING 'Total Donations'

TTITLE SKIP COL 25 'Monthly Donation Report for Month: '&v_Month SKIP - 
COL 25 '_____________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF total_donations ON REPORT;

SELECT 
    s.shelter_name,
    d.donor_firstname,
    d.donor_lastname,
    TO_CHAR(dn.donate_date, 'YYYY-MM') AS month,
    SUM(dn.donate_amount) AS total_donations
FROM 
    Shelter s
JOIN 
    Donation dn ON s.shelter_id = dn.shelter_id
JOIN 
    Donor d ON dn.donor_id = d.donor_id
WHERE 
    TO_CHAR(dn.donate_date, 'YYYY-MM') = '&v_Month'
GROUP BY 
    s.shelter_name, d.donor_firstname, d.donor_lastname, TO_CHAR(dn.donate_date, 'YYYY-MM')
ORDER BY 
    month;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF

query2:
CREATE OR REPLACE FUNCTION Get_Shelter_Donation_Report(v_Month CHAR)
RETURN SYS_REFCURSOR
IS
    shelter_donation_cursor SYS_REFCURSOR;
BEGIN
    OPEN shelter_donation_cursor FOR
        SELECT 
            s.shelter_name AS "Shelter Name",
            d.donor_firstname AS "Donor First Name",
            d.donor_lastname AS "Donor Last Name",
            TO_CHAR(dn.donate_date, 'YYYY-MM') AS "Month",
            SUM(dn.donate_amount) AS "Total Donations"
        FROM 
            Shelter s
        JOIN 
            Donation dn ON s.shelter_id = dn.shelter_id
        JOIN 
            Donor d ON dn.donor_id = d.donor_id
        WHERE 
            TO_CHAR(dn.donate_date, 'YYYY-MM') = v_Month
        GROUP BY 
            s.shelter_name, d.donor_firstname, d.donor_lastname, TO_CHAR(dn.donate_date, 'YYYY-MM')
        ORDER BY 
            SUM(dn.donate_amount) DESC;

    RETURN shelter_donation_cursor;
END Get_Shelter_Donation_Report;
/


SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the monthly donation trends per shelter and donor.
PROMPT
PROMPT Shelter Donation Report
PROMPT -----------------------------------------------

ACCEPT v_Month CHAR PROMPT 'Enter Month (e.g., 2023-08): '

COLUMN shelter_name FORMAT A25
COLUMN donor_firstname FORMAT A20
COLUMN donor_lastname FORMAT A20
COLUMN month FORMAT A10
COLUMN total_donations FORMAT $999999.99

COLUMN shelter_name HEADING 'Shelter Name'
COLUMN donor_firstname HEADING 'Donor First Name'
COLUMN donor_lastname HEADING 'Donor Last Name'
COLUMN month HEADING 'Month'
COLUMN total_donations HEADING 'Total Donations'

TTITLE SKIP COL 25 'Monthly Donation Report for Month: '&v_Month SKIP - 
COL 25 '___________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF total_donations ON REPORT;

SELECT 
    s.shelter_name,
    d.donor_firstname,
    d.donor_lastname,
    TO_CHAR(dn.donate_date, 'YYYY-MM') AS month,
    SUM(dn.donate_amount) AS total_donations
FROM 
    Shelter s
JOIN 
    Donation dn ON s.shelter_id = dn.shelter_id
JOIN 
    Donor d ON dn.donor_id = d.donor_id
WHERE 
    TO_CHAR(dn.donate_date, 'YYYY-MM') = '&v_Month'
GROUP BY 
    s.shelter_name, d.donor_firstname, d.donor_lastname, TO_CHAR(dn.donate_date, 'YYYY-MM')
ORDER BY 
    month;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF;

query3:
SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the average medical fee per breed based on adoption status.
PROMPT
PROMPT Medical Fee and Adoption Status Report
PROMPT -----------------------------------------------

ACCEPT v_AdoptStatus CHAR FORMAT 'A10' PROMPT 'Enter Adoption Status (e.g., Approved): '

COLUMN anm_breeds FORMAT A25
COLUMN adopt_status FORMAT A15
COLUMN avg_medical_fee FORMAT $99999.99

COLUMN anm_breeds HEADING 'Breed'
COLUMN adopt_status HEADING 'Adoption Status'
COLUMN avg_medical_fee HEADING 'Average Medical Fee'

TTITLE SKIP COL 25 'Average Medical Fee Report for Status: '&v_AdoptStatus SKIP - 
COL 25 '_________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF avg_medical_fee ON REPORT;

SELECT 
    a.anm_breeds,
    ad.adopt_status,
    AVG(mt.medic_fee) AS avg_medical_fee
FROM 
    Animal a
JOIN 
    Medical_Exam me ON a.anm_id = me.anm_id
JOIN 
    Medical_Type mt ON me.medic_type = mt.medic_type
JOIN 
    Adoption ad ON a.adopt_id = ad.adopt_id
WHERE 
    ad.adopt_status = '&v_AdoptStatus'
GROUP BY 
    a.anm_breeds, ad.adopt_status
ORDER BY 
    avg_medical_fee DESC;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF


query4:
SET LINESIZE 120
SET PAGESIZE 60
SET RECSEP EACH

PROMPT
PROMPT Purpose: Generate a report showing the average work experience of a trainer by training type based on a specified Trainer ID.
PROMPT
PROMPT Trainer Work Experience Report
PROMPT ----------------------------------------------

-- Define the trainer_id variable to avoid multiple prompts
ACCEPT trainer_id_prompt PROMPT 'Enter Trainer ID (TR001): '
DEFINE trainer_id_prompt = '&trainer_id_prompt'

-- Format the columns for better display
COLUMN trainer_firstname FORMAT A30
COLUMN trainer_lastname FORMAT A16
COLUMN train_type FORMAT A35
COLUMN avg_work_experience FORMAT 999

TTITLE SKIP COL 25 'Average Work Experience of Trainer '&trainer_id_prompt' by Training Type' SKIP - 
COL 25 '__________________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

-- Define break and compute
BREAK ON trainer_firstname ON trainer_lastname 
COMPUTE AVG LABEL 'Overall Average Experience: ' OF avg_work_experience ON trainer_firstname

-- Main SQL query
SELECT TR.trainer_firstname, TR.trainer_lastname, TT.train_type,
       AVG(TR.trainer_work_experience) AS avg_work_experience
FROM Training T
JOIN Trainer TR ON T.trainer_id = TR.trainer_id
JOIN Training_Type TT ON T.train_type = TT.train_type
WHERE TR.trainer_id = '&trainer_id_prompt'
GROUP BY TR.trainer_firstname, TR.trainer_lastname, TT.train_type
ORDER BY avg_work_experience DESC;

-- Clear columns formatting after the query
CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF;


query5:
SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the total adoption applications and consultations for multiple customers.
PROMPT
PROMPT Customer Adoption and Consultation Report
PROMPT -----------------------------------------------

ACCEPT v_CustIDStart CHAR FORMAT 'A10' PROMPT 'Enter Starting Customer ID (e.g., CT001): '
ACCEPT v_CustIDEnd CHAR FORMAT 'A10' PROMPT 'Enter Ending Customer ID (e.g., CT010): '

COLUMN cust_firstname FORMAT A20
COLUMN cust_lastname FORMAT A20
COLUMN total_applications FORMAT 9999
COLUMN total_consultations FORMAT 9999

COLUMN cust_firstname HEADING 'Customer First Name'
COLUMN cust_lastname HEADING 'Customer Last Name'
COLUMN total_applications HEADING 'Total Applications'
COLUMN total_consultations HEADING 'Total Consultations'

TTITLE SKIP COL 25 'Customer Adoption and Consultation Report for Customer IDs: '&v_CustIDStart' to '&v_CustIDEnd SKIP - 
COL 25 '___________________________________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF total_applications ON REPORT;
COMPUTE SUM LABEL 'Grand Total : ' OF total_consultations ON REPORT;

SELECT 
    c.cust_firstname,
    c.cust_lastname,
    COUNT(ap.appli_id) AS total_applications,
    COUNT(con.consul_id) AS total_consultations
FROM 
    Customer c
JOIN 
    Application ap ON c.cust_id = ap.cust_id
LEFT JOIN 
    Consultation con ON ap.appli_id = con.appli_id
WHERE 
    c.cust_id BETWEEN '&v_CustIDStart' AND '&v_CustIDEnd'
GROUP BY 
    c.cust_firstname, c.cust_lastname
ORDER BY 
    total_applications DESC, total_consultations DESC;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF


query6:
CREATE OR REPLACE FUNCTION Get_Avg_Delivery_Fee_By_Status (p_AdoptStatus IN VARCHAR2)
RETURN SYS_REFCURSOR
IS
    v_Cursor SYS_REFCURSOR;
BEGIN
    OPEN v_Cursor FOR
    SELECT 
        c.cust_firstname AS Customer_FirstName,
        c.cust_lastname AS Customer_LastName,
        ad.adopt_status AS Adoption_Status,
        AVG(ad.delivery_fee) AS Avg_Delivery_Fee
    FROM 
        Customer c
    JOIN 
        Adoption ad ON c.cust_id = ad.cust_id
    JOIN 
        Application ap ON ad.appli_id = ap.appli_id
    WHERE 
        ad.adopt_status = p_AdoptStatus
    GROUP BY 
        c.cust_firstname, c.cust_lastname, ad.adopt_status
    ORDER BY 
        Avg_Delivery_Fee DESC;
    
    RETURN v_Cursor;
END;
/


SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the average delivery fee per customer based on adoption status.
PROMPT
PROMPT Customer Delivery Fee Report
PROMPT -----------------------------------------------

ACCEPT v_AdoptStatus CHAR FORMAT 'A10' PROMPT 'Enter Adoption Status (e.g., Approved): '

COLUMN cust_firstname FORMAT A20
COLUMN cust_lastname FORMAT A20
COLUMN adopt_status FORMAT A15
COLUMN avg_delivery_fee FORMAT $99999.99

COLUMN cust_firstname HEADING 'Customer First Name'
COLUMN cust_lastname HEADING 'Customer Last Name'
COLUMN adopt_status HEADING 'Adoption Status'
COLUMN avg_delivery_fee HEADING 'Average Delivery Fee'

TTITLE SKIP COL 25 'Customer Delivery Fee Report for Adoption Status: '&v_AdoptStatus SKIP - 
COL 25 '___________________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF avg_delivery_fee ON REPORT;

SELECT 
    c.cust_firstname,
    c.cust_lastname,
    ad.adopt_status,
    AVG(ad.delivery_fee) AS avg_delivery_fee
FROM 
    Customer c
JOIN 
    Adoption ad ON c.cust_id = ad.cust_id
JOIN 
    Application ap ON ad.appli_id = ap.appli_id
WHERE 
    ad.adopt_status = '&v_AdoptStatus'
GROUP BY 
    c.cust_firstname, c.cust_lastname, ad.adopt_status
ORDER BY 
    avg_delivery_fee DESC;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF

query7:
CREATE OR REPLACE FUNCTION Get_Medical_Treatments(p_MedicType IN VARCHAR2)
RETURN SYS_REFCURSOR
IS
    v_Cursor SYS_REFCURSOR;  -- Declare a cursor variable
BEGIN
    OPEN v_Cursor FOR
        SELECT 
            mt.medic_type AS Medical_Type,
            COUNT(me.medic_id) AS Total_Treatments,
            COUNT(DISTINCT a.anm_id) AS Total_Animals
        FROM 
            Medical_Type mt
        JOIN 
            Medical_Exam me ON mt.medic_type = me.medic_type
        JOIN 
            Animal a ON me.anm_id = a.anm_id
        JOIN 
            Adoption ad ON a.adopt_id = ad.adopt_id
        WHERE 
            mt.medic_type = p_MedicType
        GROUP BY 
            mt.medic_type
        ORDER BY 
            Total_Treatments DESC;

    RETURN v_Cursor;  -- Return the cursor
END Get_Medical_Treatments;
/


SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the total medical treatments and distinct animals per medical type.
PROMPT
PROMPT Medical Treatments Report
PROMPT ---------------------------------------

PROMPT Available Medical Types:

PROMPT 1. Blood Test
PROMPT 2. Dental Cleaning
PROMPT 3. Deworming
PROMPT 4. Euthanasia
PROMPT 5. Neutering
PROMPT 6. Surgery (Major)
PROMPT 7. Surgery (Minor)
PROMPT 8. Ultrasound
PROMPT 9. Vaccination
PROMPT 10. X-Ray
PROMPT ---------------------------------------

ACCEPT p_MedicType CHAR FORMAT 'A25' PROMPT 'Enter Medical Type (e.g., Vaccination): '

COLUMN medic_type FORMAT A25
COLUMN total_treatments FORMAT 9999
COLUMN total_animals FORMAT 9999
COLUMN anm_name FORMAT A20
COLUMN anm_breeds FORMAT A25
COLUMN adoption_date FORMAT A15

COLUMN medic_type HEADING 'Medical Type'
COLUMN total_treatments HEADING 'Total Treatments'
COLUMN total_animals HEADING 'Total Animals'
COLUMN anm_name HEADING 'Animal Name'
COLUMN anm_breeds HEADING 'Breeds'
COLUMN adoption_date HEADING 'Adoption Date'

TTITLE SKIP COL 25 'Medical Treatments Report for Medical Type: '&p_MedicType SKIP - 
COL 25 '___________________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 - 

PROMPT
PROMPT Medical Treatments Report for &p_MedicType
PROMPT ----------------------------------------

BREAK ON medic_type 
COMPUTE SUM LABEL 'Grand Total: ' OF total_treatments ON medic_type;

SELECT 
    mt.medic_type,
    COUNT(me.medic_id) AS total_treatments,
    COUNT(DISTINCT a.anm_id) AS total_animals,
    a.anm_name,
    a.anm_breeds,
    TO_CHAR(ad.adopt_date, 'YYYY-MM-DD') AS adoption_date
FROM 
    Medical_Type mt
JOIN 
    Medical_Exam me ON mt.medic_type = me.medic_type
JOIN 
    Animal a ON me.anm_id = a.anm_id
JOIN 
    Adoption ad ON a.adopt_id = ad.adopt_id
WHERE 
    mt.medic_type = '&p_MedicType'
GROUP BY 
    mt.medic_type, a.anm_name, a.anm_breeds, ad.adopt_date
ORDER BY 
    total_treatments DESC, a.anm_name;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF;

query8:
SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the correlation between adoption and training for multiple customers.
PROMPT
PROMPT Adoption and Training Correlation Report
PROMPT -----------------------------------------------

ACCEPT v_CustIDStart CHAR FORMAT 'A10' PROMPT 'Enter Starting Customer ID (e.g., CT001): '
ACCEPT v_CustIDEnd CHAR FORMAT 'A10' PROMPT 'Enter Ending Customer ID (e.g., CT010): '

COLUMN cust_firstname FORMAT A20
COLUMN cust_lastname FORMAT A20
COLUMN total_adoptions FORMAT 9999
COLUMN total_trainings FORMAT 9999

COLUMN cust_firstname HEADING 'Customer First Name'
COLUMN cust_lastname HEADING 'Customer Last Name'
COLUMN total_adoptions HEADING 'Total Adoptions'
COLUMN total_trainings HEADING 'Total Trainings'

TTITLE SKIP COL 25 'Adoption and Training Correlation Report for Customer IDs: '&v_CustIDStart' to '&v_CustIDEnd SKIP - 
COL 25 '____________________________________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF total_adoptions ON REPORT;

SELECT 
    c.cust_firstname,
    c.cust_lastname,
    COUNT(DISTINCT ad.adopt_id) AS total_adoptions,
    COUNT(DISTINCT tr.train_id) AS total_trainings
FROM 
    Customer c
JOIN 
    Adoption ad ON c.cust_id = ad.cust_id
JOIN 
    Booking b ON ad.cust_id = b.cust_id
JOIN 
    Training tr ON b.book_id = tr.book_id
WHERE 
    c.cust_id BETWEEN '&v_CustIDStart' AND '&v_CustIDEnd'
GROUP BY 
    c.cust_firstname, c.cust_lastname
ORDER BY 
    total_adoptions DESC, total_trainings DESC;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF


query9:
SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the total revenue generated by a trainer based on training fees.
PROMPT
PROMPT Trainer Revenue Report
PROMPT -----------------------------------------------

-- Accepting trainer ID input
ACCEPT v_TrainerID CHAR FORMAT 'A10' PROMPT 'Enter Trainer ID (e.g., TR001): '

-- Formatting columns for readability
COLUMN trainer_id FORMAT A35
COLUMN train_type FORMAT A35
COLUMN train_fee FORMAT $99999.99

-- Column headings
COLUMN trainer_id HEADING 'Trainer ID'
COLUMN train_type HEADING 'Training Type'
COLUMN train_fee HEADING 'Training Fee'

-- Title for the report
TTITLE SKIP COL 25 'Trainer Revenue Report for Trainer ID: '&v_TrainerID SKIP - 
COL 25 '_______________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

-- Break and compute for total revenue
BREAK ON trainer_id
COMPUTE SUM LABEL 'Total Revenue for Trainer &v_TrainerID: ' OF train_fee ON trainer_id

-- Main query
SELECT 
    t.trainer_id,
    tt.train_type,
    tt.train_fee
FROM 
    Trainer t
JOIN 
    Training tr ON t.trainer_id = tr.trainer_id
JOIN 
    Training_Type tt ON tr.train_type = tt.train_type
WHERE 
    t.trainer_id = '&v_TrainerID'
ORDER BY 
    train_fee DESC;

-- Clear formatting and titles
CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF;

query10:
SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the correlation between medical expenses and adoption by breed and date range.
PROMPT
PROMPT Medical Expenses and Adoption Report
PROMPT -----------------------------------------------

-- Input start and end dates
ACCEPT v_StartDate DATE FORMAT 'YYYY-MM-DD' PROMPT 'Enter Start Date (YYYY-MM-DD): '
ACCEPT v_EndDate DATE FORMAT 'YYYY-MM-DD' PROMPT 'Enter End Date (YYYY-MM-DD): '

-- Format columns for better readability
COLUMN anm_breeds FORMAT A30
COLUMN medic_type FORMAT A20
COLUMN medic_fee FORMAT $99999.99
COLUMN total_adoptions FORMAT 9999

-- Column headings
COLUMN anm_breeds HEADING 'Breed'
COLUMN medic_type HEADING 'Medical Type'
COLUMN medic_fee HEADING 'Medical Fee'
COLUMN total_adoptions HEADING 'Total Adoptions'

-- Title for the report
TTITLE SKIP COL 25 'Medical Expenses and Adoption Report from '&v_StartDate' to '&v_EndDate SKIP - 
COL 25 '___________________________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

-- Break on breed for proper grand total calculation
BREAK ON anm_breeds SKIP 1

-- Compute grand total for medical fees
COMPUTE SUM LABEL 'Grand Total for Medical Fees: ' OF medic_fee ON anm_breeds

-- Main SQL query
SELECT 
    a.anm_breeds,
    mt.medic_type,
    SUM(mt.medic_fee) AS medic_fee,
    COUNT(DISTINCT ad.adopt_id) AS total_adoptions
FROM 
    Animal a
JOIN 
    Adoption ad ON a.adopt_id = ad.adopt_id
JOIN 
    Medical_Exam me ON a.anm_id = me.anm_id
JOIN 
    Medical_Type mt ON me.medic_type = mt.medic_type
WHERE 
    me.medic_date BETWEEN TO_DATE('&v_StartDate', 'YYYY-MM-DD') AND TO_DATE('&v_EndDate', 'YYYY-MM-DD')
GROUP BY 
    a.anm_breeds, mt.medic_type
ORDER BY 
    total_adoptions DESC, medic_fee DESC;

-- Clear settings and titles
CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF;


query11:
CREATE OR REPLACE FUNCTION Get_Donations_By_Date(
    p_start_date IN DATE,
    p_end_date IN DATE
) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    -- Open a cursor to select the donation data between the specified dates
    OPEN v_cursor FOR
    SELECT 
        d.Donor_ID,
        d.Donor_FirstName,
        d.Donor_LastName,
        s.Shelter_Name,
        SUM(do.donate_amount) AS Total_Donate_Amount
    FROM 
        Donor d
    JOIN 
        Donation do ON d.Donor_ID = do.Donor_ID
    JOIN 
        Shelter s ON do.Shelter_ID = s.Shelter_ID
    WHERE 
        do.donate_date BETWEEN p_start_date AND p_end_date
    GROUP BY
        d.Donor_ID, d.Donor_FirstName, d.Donor_LastName, s.Shelter_Name
    ORDER BY 
        d.Donor_ID;

    RETURN v_cursor;
END Get_Donations_By_Date;
/


SET LINESIZE 120
SET PAGESIZE 60
SET RECSEP EACH

PROMPT
PROMPT Purpose: Generate a report showing donations between a specified start and end date
PROMPT
PROMPT Donations Report
PROMPT ----------------------------------------------

ACCEPT v_start_date DATE FORMAT 'YYYY-MM-DD' PROMPT 'Enter start date (YYYY-MM-DD): '
ACCEPT v_end_date DATE FORMAT 'YYYY-MM-DD' PROMPT 'Enter end date (YYYY-MM-DD): '

COLUMN donor_id FORMAT A15
COLUMN donor_firstname FORMAT A20
COLUMN donor_lastname FORMAT A20
COLUMN shelter_name FORMAT A30
COLUMN donate_amount FORMAT $999,999.99

TTITLE SKIP COL 25 'Donations Report from '&&v_start_date' to '&&v_end_date SKIP - 
COL 25 '___________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2

-- Compute the grand total of donations
BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF donate_amount ON REPORT;

-- Display detailed report
SELECT 
    d.donor_id,
    d.donor_firstname,
    d.donor_lastname,
    s.shelter_name,
    do.donate_amount
FROM 
    Donor d
    JOIN Donation do ON d.donor_id = do.donor_id
    JOIN Shelter s ON do.shelter_id = s.shelter_id
WHERE 
    do.donate_date BETWEEN TO_DATE('&&v_start_date', 'YYYY-MM-DD') AND TO_DATE('&&v_end_date', 'YYYY-MM-DD')
ORDER BY 
    d.donor_id;


CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF;

query12:
SET LINESIZE 120
SET PAGESIZE 30

PROMPT
PROMPT Purpose: Display the total training fees per trainer based on booking status.
PROMPT
PROMPT Trainer and Training Fees Report
PROMPT -----------------------------------------------

ACCEPT v_BookStatus CHAR FORMAT 'A10' PROMPT 'Enter Booking Status (e.g., Approved): '

COLUMN trainer_firstname FORMAT A20
COLUMN trainer_lastname FORMAT A20
COLUMN train_type FORMAT A35
COLUMN book_status FORMAT A15
COLUMN total_training_fee FORMAT $99999.99

COLUMN trainer_firstname HEADING 'Trainer First Name'
COLUMN trainer_lastname HEADING 'Trainer Last Name'
COLUMN train_type HEADING 'Training Type'
COLUMN book_status HEADING 'Booking Status'
COLUMN total_training_fee HEADING 'Total Training Fee'

TTITLE SKIP COL 25 'Training Fees Report for Booking Status: '&v_BookStatus SKIP - 
COL 25 '___________________________________________________' SKIP 1 - 
RIGHT 'Page:' FORMAT 999 SQL.PNO SKIP 2 -

BREAK ON REPORT
COMPUTE SUM LABEL 'Grand Total : ' OF total_training_fee ON REPORT;

SELECT 
    t.trainer_firstname,
    t.trainer_lastname,
    tt.train_type,
    b.book_status,
    SUM(tt.train_fee) AS total_training_fee
FROM 
    Trainer t
JOIN 
    Training tr ON t.trainer_id = tr.trainer_id
JOIN 
    Training_Type tt ON tr.train_type = tt.train_type
JOIN 
    Booking b ON tr.book_id = b.book_id
WHERE 
    b.book_status = '&v_BookStatus'
GROUP BY 
    t.trainer_firstname, t.trainer_lastname, tt.train_type, b.book_status
ORDER BY 
    total_training_fee DESC;

CLEAR COLUMNS
TTITLE OFF
SET RECSEP OFF
