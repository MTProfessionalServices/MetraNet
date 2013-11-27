-------------------------------------------------------------------------------------
-- This script changes DB columns with precision/scale (18,6) to (22,10),
-- preserving the isNullable property.
-------------------------------------------------------------------------------------

use NETMETERSTAGE


PRINT 'STARTING CONVERSION OF PRECISION/SCALE (18,6) COLUMNS TO (22,10)'
PRINT ''

-- First drop constraint from t_recur_enum so we can update type of enum_value column.
IF  EXISTS (SELECT * FROM sys.indexes 
            WHERE object_id = OBJECT_ID(N't_recur_enum') AND name = N'pk_t_recur_enum')
BEGIN
    PRINT 'Dropping pk_t_recur_enum constraint from t_recur_enum table'
    PRINT ''
    ALTER TABLE t_recur_enum DROP CONSTRAINT pk_t_recur_enum
END


DECLARE @tableName  NVARCHAR(256)  
DECLARE @columnName NVARCHAR(256)
DECLARE @xType      INT
DECLARE @xPrec      INT
DECLARE @xScale     INT
DECLARE @isNullable INT
DECLARE @numAlteredDecimal INT
DECLARE @numAlteredNumeric INT
DECLARE @numSkipped INT
DECLARE @xtypeDecimal INT = 106  -- constant
DECLARE @xtypeNumeric INT = 108  -- constant

DECLARE theCursor CURSOR FOR  
SELECT
sysobjects.name, syscolumns.name, syscolumns.xtype, syscolumns.xprec, syscolumns.xscale, syscolumns.isnullable
FROM sysobjects, syscolumns
WHERE sysobjects.id = syscolumns.id
  AND sysobjects.type = 'u'
  AND syscolumns.name IN 
    (SELECT name FROM syscolumns 
     WHERE xprec = 18 AND xscale = 6 AND (xtype = @xtypeDecimal OR xtype = @xtypeNumeric))
ORDER BY sysobjects.name, syscolumns.name

SET @numAlteredDecimal = 0
SET @numAlteredNumeric = 0
SET @numSkipped = 0


-- Loop through the (18,6) columns, converting them to DECIMAL(22,10).
OPEN theCursor
FETCH NEXT FROM theCursor INTO @tableName, @columnName, @xType, @xPrec, @xScale, @isNullable

WHILE @@FETCH_STATUS = 0  
BEGIN
    -- Double-check precision and scale here because the SELECT appears to
    -- pick up some other columns.
    IF (@xType != @xtypeDecimal AND @xType != @xtypeNumeric) OR @xPrec != 18 OR @xScale != 6
    BEGIN
        SET @numSkipped = @numSkipped + 1
        PRINT '*** SKIPPING ' + @tableName + '/' + @columnName + ' with type(precision,scale) ' + 
              CAST(@xType as varchar(5)) + '(' + CAST(@xPrec as varchar(5)) + ',' + CAST(@xScale as varchar(5)) + ') ***'
    END
    
    ELSE IF @xType = @xtypeDecimal  -- DECIMAL columns
    BEGIN
       SET @numAlteredDecimal = @numAlteredDecimal + 1

       IF @isNullable = 1
       BEGIN
           PRINT 'Altering DECIMAL ' + @tableName + '/' + @columnName
           EXEC('ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' DECIMAL(22,10)')
       END

       ELSE  -- not nullable
       BEGIN
           PRINT 'Altering DECIMAL ' + @tableName + '/' + @columnName + ' (NOT NULL)'
           EXEC('ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' DECIMAL(22,10) NOT NULL')
       END
    END
    
    ELSE  -- NUMERIC columns
    BEGIN
       SET @numAlteredNumeric = @numAlteredNumeric + 1
       
       IF @isNullable = 1
       BEGIN
           PRINT 'Altering NUMERIC ' + @tableName + '/' + @columnName
           EXEC('ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' NUMERIC(22,10)')
       END

       ELSE  -- not nullable
       BEGIN
           PRINT 'Altering NUMERIC ' + @tableName + '/' + @columnName + ' (NOT NULL)'
           EXEC('ALTER TABLE ' + @tableName + ' ALTER COLUMN ' + @columnName + ' NUMERIC(22,10) NOT NULL')
       END
    END    
    
    FETCH NEXT FROM theCursor INTO @tableName, @columnName, @xType, @xPrec, @xScale, @isNullable
END

CLOSE theCursor
DEALLOCATE theCursor


-- Finally, restore constraint to t_recur_enum table.
IF  EXISTS (SELECT * FROM sys.indexes 
            WHERE object_id = OBJECT_ID(N't_recur_enum'))
BEGIN
    PRINT ''
    PRINT 'Restoring pk_t_recur_enum constraint to t_recur_enum table'
    ALTER TABLE t_recur_enum ADD CONSTRAINT pk_t_recur_enum PRIMARY KEY CLUSTERED 
    (
          id_prop ASC,
          enum_value ASC
    )
END

PRINT ''
PRINT 'END CONVERSION OF PRECISION/SCALE (18,6) COLUMNS TO (22,10)'
PRINT 'CONVERTED ' + CAST(@numAlteredNumeric as varchar(32)) + ' NUMERIC AND ' + 
      CAST(@numAlteredDecimal as varchar(32)) +' DECIMAL COLUMNS; SKIPPED ' + 
      CAST(@numSkipped as varchar(32)) + ' COLUMNS'
