CREATE OR REPLACE FUNCTION metratime (utc number := 0, app_name varchar2 := NULL) RETURN DATE
IS
result_date DATE;
now DATE;
add_seconds INT;
BEGIN
  IF (utc IS NULL OR utc = 0) THEN
    now := SYSDATE;
  ELSE
    now := dbo.getutcdate;
  END IF;
                SELECT frozen_date, add_seconds
  INTO result_date, add_seconds
                FROM   t_metratime
  WHERE NVL(application_name, 'Default') = NVL(app_name, 'Default') AND ROWNUM <= 1;
                -- If no rows, return getdate(). This is default behavior for production systems
                IF (result_date IS NULL AND add_seconds IS NULL) THEN
    return now;
  END IF;
                -- If the frozen date was not set, start with getdate()
                IF (result_date IS NULL) THEN
                                result_date := now;
  END IF;
                -- If add seconds was specified add them now
                IF (add_seconds IS NOT NULL) THEN
                                result_date := result_date + (add_seconds / 86400); /* 86400 is 1 day in seconds */
  END IF;
                RETURN result_date;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN now;
END;
