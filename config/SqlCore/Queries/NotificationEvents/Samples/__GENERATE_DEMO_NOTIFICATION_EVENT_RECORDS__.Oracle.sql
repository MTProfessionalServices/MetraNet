SELECT 
  CONCAT(
    CONCAT(
      CONCAT(
        CONCAT(
          CONCAT(
            CONCAT(
              CONCAT(TO_CHAR(CURRENT_TIMESTAMP, 'Month'), ' '), 
            (SELECT TO_CHAR(sysdate, 'DD') FROM DUAL)), ' '),
          (SELECT TO_CHAR(sysdate, 'DAY') FROM DUAL)), ' '),
        ' at '), 
      (SELECT EXTRACT(HOUR FROM CURRENT_TIMESTAMP) || ':' || EXTRACT(MINUTE FROM CURRENT_TIMESTAMP)|| ':' || EXTRACT(SECOND FROM CURRENT_TIMESTAMP) FROM DUAL)
    )
  AS EventTimestamp FROM DUAL
