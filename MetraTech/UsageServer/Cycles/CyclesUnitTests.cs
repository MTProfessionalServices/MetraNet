using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using MetraTech.UsageServer;

namespace UsageServerUnitTests
{
    /// <summary>
    /// Unit tests to verify customized usage server functionality
    /// </summary>
    [TestFixture]
    static public class UsageServerUnitTests
    {
        /// <summary>
        /// Verifies that a Monthly Cycle can be created
        /// </summary>
        [Test]
        static public void TestMonthlyCycleCreation()
        {
            MonthlyCycleType newMonthlyCycleType = new MonthlyCycleType();
        }

        /// <summary>
        /// Verifies that basic functionality to Move Date works
        /// </summary>
        [Test]
        static public void MoveDateBasic()
        {
            DateTime date = new DateTime(2010, 1, 15);
            DateTime movedDate = CycleUtils.MoveToDay(date, 30);
            Assert.That(movedDate, Is.EqualTo(new DateTime(2010, 1, 30)), "Moved Date");
        }

        /// <summary>
        /// Verifies that Move Date works correctly when moving to day 30 in the month of February
        /// </summary>
        [Test]
        static public void MoveDateFebruary30()
        {
            DateTime date = new DateTime(2010, 2, 15);
            DateTime movedDate = CycleUtils.MoveToDay(date, 30);
            Assert.That(movedDate, Is.EqualTo(new DateTime(2010, 2, 28)), "Moved Date");
        }

        /// <summary>
        /// Verifies that a Monthly interval ending on the 31st starts on the 1st of the month
        /// </summary>
        [Test]
        static public void CreateCycleMonthly_2010_01_31()
        {
            DateTime referenceDate = new DateTime(2010, 1, 15);
            DateTime startDate;
            DateTime endDate;
            MonthlyCycleType newMonthlyCycleType = new MonthlyCycleType();
            Cycle cycle = new Cycle();
            cycle.DayOfMonth = 31;
            newMonthlyCycleType.ComputeStartAndEndDate(referenceDate, cycle, out startDate, out endDate);
            Assert.That(startDate, Is.EqualTo(new DateTime(2010, 1, 1)), "Start Date");
            Assert.That(endDate, Is.EqualTo(new DateTime(2010, 1, 31)), "End Date");
        }

        /// <summary>
        /// Verifies that a Monthly interval ending on the 31st starts on the 1st of the month
        /// </summary>
        [Test]
        static public void CreateCycleMonthly_2010_01_03()
        {
            DateTime referenceDate = new DateTime(2010, 1, 15);
            DateTime startDate;
            DateTime endDate;
            MonthlyCycleType newMonthlyCycleType = new MonthlyCycleType();
            Cycle cycle = new Cycle();
            cycle.DayOfMonth = 3;
            newMonthlyCycleType.ComputeStartAndEndDate(referenceDate, cycle, out startDate, out endDate);
            Assert.That(startDate, Is.EqualTo(new DateTime(2010, 1, 4)), "Start Date");
            Assert.That(endDate, Is.EqualTo(new DateTime(2010, 2, 3)), "End Date");
        }

        /// <summary>
        /// Verifies that a Monthly interval ending on March 30 (after February, which is a short month)
        /// starts on March 1
        /// </summary>
        [Test]
        static public void CreateCycleMonthly_2010_03_30()
        {
            DateTime referenceDate = new DateTime(2010, 3, 15);
            DateTime startDate;
            DateTime endDate;
            MonthlyCycleType newMonthlyCycleType = new MonthlyCycleType();
            Cycle cycle = new Cycle();
            cycle.DayOfMonth = 30;
            newMonthlyCycleType.ComputeStartAndEndDate(referenceDate, cycle, out startDate, out endDate);
            Assert.That(startDate, Is.EqualTo(new DateTime(2010, 3, 1)), "Start Date");
            Assert.That(endDate, Is.EqualTo(new DateTime(2010, 3, 30)), "End Date");
        }

        /// <summary>
        /// Verifies that a Monthly interval ending on April 30 (after February, which is a short month)
        /// starts on March 1
        /// </summary>
        [Test]
        static public void CreateCycleMonthly_2010_04_30()
        {
            DateTime referenceDate = new DateTime(2010, 3, 31);
            DateTime startDate;
            DateTime endDate;
            MonthlyCycleType newMonthlyCycleType = new MonthlyCycleType();
            Cycle cycle = new Cycle();
            cycle.DayOfMonth = 30;
            newMonthlyCycleType.ComputeStartAndEndDate(referenceDate, cycle, out startDate, out endDate);
            Assert.That(startDate, Is.EqualTo(new DateTime(2010, 3, 31)), "Start Date");
            Assert.That(endDate, Is.EqualTo(new DateTime(2010, 4, 30)), "End Date");
        }

        /// <summary>
        /// Verifies that a Monthly interval ending on January 1 (why?)
        /// starts on December 2
        /// </summary>
        [Test]
        static public void CreateCycleMonthly_2010_01_01()
        {
            DateTime referenceDate = new DateTime(2010, 1, 1);
            DateTime startDate;
            DateTime endDate;
            MonthlyCycleType newMonthlyCycleType = new MonthlyCycleType();
            Cycle cycle = new Cycle();
            cycle.DayOfMonth = 1;
            newMonthlyCycleType.ComputeStartAndEndDate(referenceDate, cycle, out startDate, out endDate);
            Assert.That(startDate, Is.EqualTo(new DateTime(2009, 12, 2)), "Start Date");
            Assert.That(endDate, Is.EqualTo(new DateTime(2010, 1, 1)), "End Date");
        }
    }
}
