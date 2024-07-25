-- Create the table for testing (if it does not exist)
CREATE TABLE HZL_Table (
    Date DATE,
    BU VARCHAR(10),
    Value INT
);

-- Insert the provided test data
INSERT INTO HZL_Table (Date, BU, Value) VALUES 
('2024-01-01', 'hzl', 3456),
('2024-02-01', 'hzl', NULL),
('2024-03-01', 'hzl', NULL),
('2024-04-01', 'hzl', NULL),
('2024-01-01', 'SC', 32456),
('2024-02-01', 'SC', NULL),
('2024-03-01', 'SC', NULL),
('2024-04-01', 'SC', NULL),
('2024-05-01', 'SC', 345),
('2024-06-01', 'SC', NULL);

-- Create a temporary table to store the updated values
SELECT 
    Date,
    BU,
    Value
INTO 
    TempHZL_Table
FROM 
    HZL_Table;

-- Iterate to fill NULL values
DECLARE @UpdatedRows INT;

SET @UpdatedRows = 1;

WHILE @UpdatedRows > 0
BEGIN
    UPDATE t
    SET t.Value = COALESCE(t.Value, p.Value)
    FROM TempHZL_Table t
    JOIN TempHZL_Table p
    ON t.BU = p.BU AND t.Date > p.Date
    WHERE t.Value IS NULL AND p.Value IS NOT NULL
        AND t.Date = (SELECT MIN(Date) FROM TempHZL_Table WHERE Date > p.Date AND BU = p.BU AND Value IS NULL);

    SET @UpdatedRows = @@ROWCOUNT;
END;

-- Update the original table with the values from the temporary table
UPDATE HZL_Table
SET Value = t.Value
FROM HZL_Table h
JOIN TempHZL_Table t
ON h.Date = t.Date AND h.BU = t.BU;

-- Drop the temporary table
DROP TABLE TempHZL_Table;

-- Select the updated records to verify the changes
SELECT * FROM HZL_Table;
