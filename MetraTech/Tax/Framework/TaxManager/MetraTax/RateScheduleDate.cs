using System;

namespace MetraTech.Tax.Framework
{

    /// <summary>
    /// Holds a rate schedule date.  Rates schedules have a beginning date
    /// and an ending date, but there are different kinds of dates:
    /// an no-beginning/no-end date, an absolute date, a relative date.
    /// </summary>
    public class RateScheduleDate
    {
        /// <summary>
        /// The kind of date indicating is it an absolute, relative,
        /// or forever (no beginning or no ending date).
        /// </summary>
        public int Kind { set; get; }

        /// <summary>
        /// True if the kind of date had a non-null value stored in the DB.
        /// </summary>
        public Boolean IsKindNull { set; get; }

        /// <summary>
        /// The date as stored in the DB.  In the case of an absolute date,
        /// this is the actual date.  In the case of a forever-date, this 
        /// value is undefined.
        /// </summary>
        public DateTime ScheduleDate { set; get; }

        /// <summary>
        /// True if the schedule had a non-null value stored in the DB.
        /// </summary>
        public Boolean IsScheduleDateNull { set; get; }

        /// <summary>
        /// True if the given kind indicates an absolute date.
        /// </summary>
        /// <returns></returns>
        public Boolean isAbsolute()
        {
            return (Kind == 1);
        }

        /// <summary>
        /// True if the given kind indicates a forever date.
        /// </summary>
        /// <returns></returns>
        public Boolean isForever()
        {
            return (Kind == 4);
        }

        public RateScheduleDate()
        {
            IsKindNull = true;
            IsScheduleDateNull = true;
        }
    }
}
