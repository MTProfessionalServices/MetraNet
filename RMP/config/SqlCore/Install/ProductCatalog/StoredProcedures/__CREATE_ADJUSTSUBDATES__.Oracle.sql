
			CREATE OR REPLACE procedure AdjustSubDates(
   p_id_po                 t_po.id_po%TYPE,
   p_startdate             DATE,
   p_enddate               DATE,
   p_adjustedstart   OUT   DATE,
   p_adjustedend     OUT   DATE,
   p_datemodified    OUT   CHAR,
   p_status          OUT   NUMBER
)
AS
BEGIN
   p_datemodified := 'N';

   BEGIN
      SELECT dbo.mtmaxoftwodates (p_startdate, po.dt_start),
             dbo.mtminoftwodates (p_enddate, po.dt_end)
        INTO p_adjustedstart,
             p_adjustedend
        FROM (SELECT te.dt_start,
                     CASE
                        WHEN te.dt_end IS NULL
                           THEN dbo.mtmaxdate ()
                        ELSE te.dt_end
                     END AS dt_end
                FROM t_po INNER JOIN t_effectivedate te ON te.id_eff_date =
                                                              t_po.id_eff_date
               WHERE t_po.id_po = p_id_po) po;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         NULL;
   END;

   IF (p_adjustedstart <> p_startdate OR p_adjustedend <> p_enddate)
   THEN
      p_datemodified := 'Y';
   END IF;

   IF p_adjustedend < p_adjustedstart
   THEN /* hmm.... looks like we are outside the effective date of the product offering */      /* MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE */
      p_status := -289472472;
      RETURN;
   END IF;

   p_status := 1;
   RETURN;
END;
		