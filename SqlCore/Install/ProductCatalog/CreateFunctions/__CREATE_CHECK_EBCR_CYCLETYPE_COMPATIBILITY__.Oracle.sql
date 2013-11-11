CREATE OR REPLACE
  FUNCTION CheckEBCRCycleTypeCompat ( EBCRCycleType INT,OtherCycleType INT )  RETURN INT
  AS
  BEGIN
    -- checks weekly based cycle types
    IF (((EBCRCycleType = 4) OR (EBCRCycleType = 5)) AND
      ((OtherCycleType = 4) OR (OtherCycleType = 5))) THEN
        RETURN 1;   -- success
    END IF;
    -- checks monthly based cycle types
    IF ((EBCRCycleType in (1,7,8,9)) AND
      (OtherCycleType  in (1,7,8,9))) THEN
        RETURN 1;   -- success
    END IF;

    RETURN 0;
  END;		