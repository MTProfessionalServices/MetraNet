
CREATE OR REPLACE PROCEDURE adjustgsubmemberdates (
   p_id_sub                t_sub.id_sub%TYPE,
   p_startdate             DATE,
   p_enddate               DATE,
   p_adjustedstart   OUT   DATE,
   p_adjustedend     OUT   DATE,
   p_datemodified    OUT   VARCHAR2,
   p_status          OUT   NUMBER
)
AS
BEGIN
   p_datemodified := 'N';

   BEGIN
      SELECT dbo.mtmaxoftwodates (p_startdate, vt_start),
             dbo.mtminoftwodates (p_enddate, vt_end)
        INTO p_adjustedstart,
             p_adjustedend
        FROM t_sub
       WHERE id_sub = p_id_sub;
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
   THEN /* hmm.... looks like we are outside the effective date of the group subscription */       
   /* MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE */
      p_status := -486604789;
      RETURN;
   END IF;

   p_status := 1;
   RETURN;
END;
		