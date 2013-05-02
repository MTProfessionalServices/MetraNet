namespace MetraTech.Product.Test
{
	using System;
	using System.Runtime.InteropServices;
	using NUnit.Framework;

	using MetraTech.DataAccess;
	using MetraTech.UsageServer;

	// Test Ideas:
	//  -interval alignment verification
	//  -negative tests
	//  -coverage tests

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Product.Test.EBCRTests /assembly:O:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class EBCRTests 
	{
		/// <summary>
		/// Tests cycle derivations for Weekly EBCR PIs
		/// </summary>
    [Test]
    public void T01TestWeeklyEBCRCycleDerivations()
    {
      // InitializeCoverageMap(CycleType.Weekly, CycleType.BiWeekly);

      // tests trivial BCR-reduction cases
      for (int cycle = 34; cycle <= 40; cycle++)
        AssertCycleDerivation(cycle, cycle, CycleType.Weekly);

      // tests Bi-Weekly usage cycles
      AssertCycleDerivation(39, 41, CycleType.Weekly);
      AssertCycleDerivation(40, 42, CycleType.Weekly);
      AssertCycleDerivation(34, 43, CycleType.Weekly);
      AssertCycleDerivation(35, 44, CycleType.Weekly);
      AssertCycleDerivation(36, 45, CycleType.Weekly);
      AssertCycleDerivation(37, 46, CycleType.Weekly);
      AssertCycleDerivation(38, 47, CycleType.Weekly);
      AssertCycleDerivation(39, 48, CycleType.Weekly);
      AssertCycleDerivation(40, 49, CycleType.Weekly);
      AssertCycleDerivation(34, 50, CycleType.Weekly);
      AssertCycleDerivation(35, 51, CycleType.Weekly);
      AssertCycleDerivation(36, 52, CycleType.Weekly);
      AssertCycleDerivation(37, 53, CycleType.Weekly);
      AssertCycleDerivation(38, 54, CycleType.Weekly);
    }

    /*
    private void InitializeCoverageMap(CycleType expectedCycleType, CycleType usageCycleType)
    {
      mExpectedCycleCoverageMap = new Hashtable();
			
      int startCycle, endCycle:
      switch (expectedCycleType)
      {
      case CycleType.Weekly:
        startCycle = 31;
        endCycle = 37;
        break;

      case CycleType.BiWeekly:
        startCycle = 38;
        endCycle = 37;
        break;

      case CycleType.Monthly:
        startCycle = 31;
        endCycle = 37;

        break;

      case CycleType.Quarterly:
        startCycle = 31;
        endCycle = 37;

        break;

      case CycleType.Annual:
        startCycle = 31;
        endCycle = 37;

        break;

      default:
        throw ApplicationException("Unknown cycle type!");
      }
    }
    */

    /// <summary>
    /// Tests cycle derivations for Bi-Weekly EBCR PIs
    /// </summary>
    [Test]
    public void T02TestBiWeeklyEBCRCycleDerivations()
    {
      // tests trivial BCR-reduction cases
      for (int cycle = 41; cycle <= 54; cycle++)
        AssertCycleDerivation(cycle, cycle, CycleType.BiWeekly);

      // only Weekly usage cycles need to be considered (besides the trivial cases already tested)
      AssertCycleDerivation(43, 34, CycleType.BiWeekly);
      AssertCycleDerivation(44, 35, CycleType.BiWeekly);
      AssertCycleDerivation(45, 36, CycleType.BiWeekly);
      AssertCycleDerivation(46, 37, CycleType.BiWeekly);
      AssertCycleDerivation(47, 38, CycleType.BiWeekly);
      AssertCycleDerivation(41, 39, CycleType.BiWeekly);
      AssertCycleDerivation(42, 40, CycleType.BiWeekly);
    }

    /// <summary>
    /// Tests cycle derivations for Monthly EBCR PIs
    /// </summary>
    [Test]
    public void T03TestMonthlyEBCRCycleDerivations()
    {
      // tests trivial BCR-reduction cases
      for (int cycle = 3; cycle <= 30; cycle++)
        AssertCycleDerivation(cycle, cycle, CycleType.Monthly);

      //
      // tests Quarterly usage cycles
      //
      // Quarters starting on the first day of the first month (Jan, Apr, Jul, Oct)
      AssertCycleDerivation(33, 520, CycleType.Monthly);
      AssertCycleDerivation(3, 521, CycleType.Monthly);
      AssertCycleDerivation(4, 522, CycleType.Monthly);
      AssertCycleDerivation(5, 523, CycleType.Monthly);
      AssertCycleDerivation(6, 524, CycleType.Monthly);
      AssertCycleDerivation(7, 525, CycleType.Monthly);
      AssertCycleDerivation(8, 526, CycleType.Monthly);
      AssertCycleDerivation(9, 527, CycleType.Monthly);
      AssertCycleDerivation(10, 528, CycleType.Monthly);
      AssertCycleDerivation(11, 529, CycleType.Monthly);
      AssertCycleDerivation(12, 530, CycleType.Monthly);
      AssertCycleDerivation(13, 531, CycleType.Monthly);
      AssertCycleDerivation(14, 532, CycleType.Monthly);
      AssertCycleDerivation(15, 533, CycleType.Monthly);
      AssertCycleDerivation(16, 534, CycleType.Monthly);
      AssertCycleDerivation(17, 535, CycleType.Monthly);
      AssertCycleDerivation(18, 536, CycleType.Monthly);
      AssertCycleDerivation(19, 537, CycleType.Monthly);
      AssertCycleDerivation(20, 538, CycleType.Monthly);
      AssertCycleDerivation(21, 539, CycleType.Monthly);
      AssertCycleDerivation(22, 540, CycleType.Monthly);
      AssertCycleDerivation(23, 541, CycleType.Monthly);
      AssertCycleDerivation(24, 542, CycleType.Monthly);
      AssertCycleDerivation(25, 543, CycleType.Monthly);
      AssertCycleDerivation(26, 544, CycleType.Monthly);
      AssertCycleDerivation(27, 545, CycleType.Monthly);
      AssertCycleDerivation(28, 546, CycleType.Monthly);
      AssertCycleDerivation(30, 548, CycleType.Monthly);
      AssertCycleDerivation(31, 549, CycleType.Monthly);
      AssertCycleDerivation(32, 550, CycleType.Monthly);
      AssertCycleDerivation(33, 551, CycleType.Monthly);

      // Quarters starting on the first day of the second month (Feb, May, Aug, Nov)
      AssertCycleDerivation(3, 552, CycleType.Monthly);
      AssertCycleDerivation(4, 553, CycleType.Monthly);
      AssertCycleDerivation(5, 554, CycleType.Monthly);
      AssertCycleDerivation(6, 555, CycleType.Monthly);
      AssertCycleDerivation(7, 556, CycleType.Monthly);
      AssertCycleDerivation(8, 557, CycleType.Monthly);
      AssertCycleDerivation(9, 558, CycleType.Monthly);
      AssertCycleDerivation(10, 559, CycleType.Monthly);
      AssertCycleDerivation(11, 560, CycleType.Monthly);
      AssertCycleDerivation(12, 561, CycleType.Monthly);
      AssertCycleDerivation(13, 562, CycleType.Monthly);
      AssertCycleDerivation(14, 563, CycleType.Monthly);
      AssertCycleDerivation(15, 564, CycleType.Monthly);
      AssertCycleDerivation(16, 565, CycleType.Monthly);
      AssertCycleDerivation(17, 566, CycleType.Monthly);
      AssertCycleDerivation(18, 567, CycleType.Monthly);
      AssertCycleDerivation(19, 568, CycleType.Monthly);
      AssertCycleDerivation(20, 569, CycleType.Monthly);
      AssertCycleDerivation(21, 570, CycleType.Monthly);
      AssertCycleDerivation(22, 571, CycleType.Monthly);
      AssertCycleDerivation(23, 572, CycleType.Monthly);
      AssertCycleDerivation(24, 573, CycleType.Monthly);
      AssertCycleDerivation(25, 574, CycleType.Monthly);
      AssertCycleDerivation(26, 575, CycleType.Monthly);
      AssertCycleDerivation(27, 576, CycleType.Monthly);
      AssertCycleDerivation(28, 577, CycleType.Monthly);
      AssertCycleDerivation(29, 578, CycleType.Monthly);
      AssertCycleDerivation(30, 579, CycleType.Monthly);
      AssertCycleDerivation(31, 580, CycleType.Monthly);
      AssertCycleDerivation(32, 581, CycleType.Monthly);
      AssertCycleDerivation(33, 582, CycleType.Monthly);

      // Quarters starting on the first day of the third month (Mar, Jun, Sep, Dec)
      AssertCycleDerivation(3, 583, CycleType.Monthly);
      AssertCycleDerivation(4, 584, CycleType.Monthly);
      AssertCycleDerivation(5, 585, CycleType.Monthly);
      AssertCycleDerivation(6, 586, CycleType.Monthly);
      AssertCycleDerivation(7, 587, CycleType.Monthly);
      AssertCycleDerivation(8, 588, CycleType.Monthly);
      AssertCycleDerivation(9, 589, CycleType.Monthly);
      AssertCycleDerivation(10, 590, CycleType.Monthly);
      AssertCycleDerivation(11, 591, CycleType.Monthly);
      AssertCycleDerivation(12, 592, CycleType.Monthly);
      AssertCycleDerivation(13, 593, CycleType.Monthly);
      AssertCycleDerivation(14, 594, CycleType.Monthly);
      AssertCycleDerivation(15, 595, CycleType.Monthly);
      AssertCycleDerivation(16, 596, CycleType.Monthly);
      AssertCycleDerivation(17, 597, CycleType.Monthly);
      AssertCycleDerivation(18, 598, CycleType.Monthly);
      AssertCycleDerivation(19, 599, CycleType.Monthly);
      AssertCycleDerivation(20, 600, CycleType.Monthly);
      AssertCycleDerivation(21, 601, CycleType.Monthly);
      AssertCycleDerivation(22, 602, CycleType.Monthly);
      AssertCycleDerivation(23, 603, CycleType.Monthly);
      AssertCycleDerivation(24, 604, CycleType.Monthly);
      AssertCycleDerivation(25, 605, CycleType.Monthly);
      AssertCycleDerivation(26, 606, CycleType.Monthly);
      AssertCycleDerivation(27, 607, CycleType.Monthly);
      AssertCycleDerivation(28, 608, CycleType.Monthly);
      AssertCycleDerivation(29, 609, CycleType.Monthly);
      AssertCycleDerivation(30, 610, CycleType.Monthly);
      AssertCycleDerivation(31, 611, CycleType.Monthly);
      AssertCycleDerivation(32, 612, CycleType.Monthly);
      //
      // tests Annual usage cycles
      //
      // To save anyone else the trouble, here's the script for the batch file I used to generate the next
      //  sequence of code (I'm including code for April - June.  The other months are similar, just adjust
      //  the # of days in the month).  You then need to massage it a bit, because the first day of every month should
      //  map to row 33, which this code puts at the wrong place.
      //      @echo off
      //setlocal ENABLEDELAYEDEXPANSION
      //set r=%2
      //echo //Annual starting April 1
      //for /l %%x in (0, 1, 29) do (
      //    set /a l=%%x+%1
      //  set /a r=!r!+1
      //  echo  AssertCycleDerivation(!l!, !r!, CycleType.Monthly^);
      //  )

      //echo //Annual starting May 1
      //for /l %%x in (0, 1, 30) do (
      //    set /a l=%%x+%1
      //  set /a r=!r!+1
      //  echo  AssertCycleDerivation(!l!, !r!, CycleType.Monthly^);
      //  )

      //echo //Annual starting June 1
      //for /l %%x in (0, 1, 29) do (
      //    set /a l=%%x+%1
      //  set /a r=!r!+1
      //  echo  AssertCycleDerivation(!l!, !r!, CycleType.Monthly^);
      //  )
      // Annual starting Jan 1
      AssertCycleDerivation(33, 613, CycleType.Monthly);
      AssertCycleDerivation(3, 614, CycleType.Monthly);
      AssertCycleDerivation(4, 615, CycleType.Monthly);
      AssertCycleDerivation(5, 616, CycleType.Monthly);
      AssertCycleDerivation(6, 617, CycleType.Monthly);
      AssertCycleDerivation(7, 618, CycleType.Monthly);
      AssertCycleDerivation(8, 619, CycleType.Monthly);
      AssertCycleDerivation(9, 620, CycleType.Monthly);
      AssertCycleDerivation(10, 621, CycleType.Monthly);
      AssertCycleDerivation(11, 622, CycleType.Monthly);
      AssertCycleDerivation(12, 623, CycleType.Monthly);
      AssertCycleDerivation(13, 624, CycleType.Monthly);
      AssertCycleDerivation(14, 625, CycleType.Monthly);
      AssertCycleDerivation(15, 626, CycleType.Monthly);
      AssertCycleDerivation(16, 627, CycleType.Monthly);
      AssertCycleDerivation(17, 628, CycleType.Monthly);
      AssertCycleDerivation(18, 629, CycleType.Monthly);
      AssertCycleDerivation(19, 630, CycleType.Monthly);
      AssertCycleDerivation(20, 631, CycleType.Monthly);
      AssertCycleDerivation(21, 632, CycleType.Monthly);
      AssertCycleDerivation(22, 633, CycleType.Monthly);
      AssertCycleDerivation(23, 634, CycleType.Monthly);
      AssertCycleDerivation(24, 635, CycleType.Monthly);
      AssertCycleDerivation(25, 636, CycleType.Monthly);
      AssertCycleDerivation(26, 637, CycleType.Monthly);
      AssertCycleDerivation(27, 638, CycleType.Monthly);
      AssertCycleDerivation(28, 639, CycleType.Monthly);
      AssertCycleDerivation(29, 640, CycleType.Monthly);
      AssertCycleDerivation(30, 641, CycleType.Monthly);
      AssertCycleDerivation(31, 642, CycleType.Monthly);
      AssertCycleDerivation(32, 643, CycleType.Monthly);

      // Annual starting Feb 1
      AssertCycleDerivation(33, 644, CycleType.Monthly);
      AssertCycleDerivation(3, 645, CycleType.Monthly);
      AssertCycleDerivation(4, 646, CycleType.Monthly);
      AssertCycleDerivation(5, 647, CycleType.Monthly);
      AssertCycleDerivation(6, 648, CycleType.Monthly);
      AssertCycleDerivation(7, 649, CycleType.Monthly);
      AssertCycleDerivation(8, 650, CycleType.Monthly);
      AssertCycleDerivation(9, 651, CycleType.Monthly);
      AssertCycleDerivation(10, 652, CycleType.Monthly);
      AssertCycleDerivation(11, 653, CycleType.Monthly);
      AssertCycleDerivation(12, 654, CycleType.Monthly);
      AssertCycleDerivation(13, 655, CycleType.Monthly);
      AssertCycleDerivation(14, 656, CycleType.Monthly);
      AssertCycleDerivation(15, 657, CycleType.Monthly);
      AssertCycleDerivation(16, 658, CycleType.Monthly);
      AssertCycleDerivation(17, 659, CycleType.Monthly);
      AssertCycleDerivation(18, 660, CycleType.Monthly);
      AssertCycleDerivation(19, 661, CycleType.Monthly);
      AssertCycleDerivation(20, 662, CycleType.Monthly);
      AssertCycleDerivation(21, 663, CycleType.Monthly);
      AssertCycleDerivation(22, 664, CycleType.Monthly);
      AssertCycleDerivation(23, 665, CycleType.Monthly);
      AssertCycleDerivation(24, 666, CycleType.Monthly);
      AssertCycleDerivation(25, 667, CycleType.Monthly);
      AssertCycleDerivation(26, 668, CycleType.Monthly);
      AssertCycleDerivation(27, 669, CycleType.Monthly);
      AssertCycleDerivation(28, 670, CycleType.Monthly);
      AssertCycleDerivation(29, 671, CycleType.Monthly);

      // Annual starting Mar 1
      AssertCycleDerivation(33, 672, CycleType.Monthly);
      AssertCycleDerivation(3, 673, CycleType.Monthly);
      AssertCycleDerivation(4, 674, CycleType.Monthly);
      AssertCycleDerivation(5, 675, CycleType.Monthly);
      AssertCycleDerivation(6, 676, CycleType.Monthly);
      AssertCycleDerivation(7, 677, CycleType.Monthly);
      AssertCycleDerivation(8, 678, CycleType.Monthly);
      AssertCycleDerivation(9, 679, CycleType.Monthly);
      AssertCycleDerivation(10, 680, CycleType.Monthly);
      AssertCycleDerivation(11, 681, CycleType.Monthly);
      AssertCycleDerivation(12, 682, CycleType.Monthly);
      AssertCycleDerivation(13, 683, CycleType.Monthly);
      AssertCycleDerivation(14, 684, CycleType.Monthly);
      AssertCycleDerivation(15, 685, CycleType.Monthly);
      AssertCycleDerivation(16, 686, CycleType.Monthly);
      AssertCycleDerivation(17, 687, CycleType.Monthly);
      AssertCycleDerivation(18, 688, CycleType.Monthly);
      AssertCycleDerivation(19, 689, CycleType.Monthly);
      AssertCycleDerivation(20, 690, CycleType.Monthly);
      AssertCycleDerivation(21, 691, CycleType.Monthly);
      AssertCycleDerivation(22, 692, CycleType.Monthly);
      AssertCycleDerivation(23, 693, CycleType.Monthly);
      AssertCycleDerivation(24, 694, CycleType.Monthly);
      AssertCycleDerivation(25, 695, CycleType.Monthly);
      AssertCycleDerivation(26, 696, CycleType.Monthly);
      AssertCycleDerivation(27, 697, CycleType.Monthly);
      AssertCycleDerivation(28, 698, CycleType.Monthly);
      AssertCycleDerivation(29, 699, CycleType.Monthly);
      AssertCycleDerivation(30, 700, CycleType.Monthly);
      AssertCycleDerivation(31, 701, CycleType.Monthly);
      AssertCycleDerivation(32, 702, CycleType.Monthly);

      // Annual starting Apr 1
      AssertCycleDerivation(33, 703, CycleType.Monthly);
      AssertCycleDerivation(3, 704, CycleType.Monthly);
      AssertCycleDerivation(4, 705, CycleType.Monthly);
      AssertCycleDerivation(5, 706, CycleType.Monthly);
      AssertCycleDerivation(6, 707, CycleType.Monthly);
      AssertCycleDerivation(7, 708, CycleType.Monthly);
      AssertCycleDerivation(8, 709, CycleType.Monthly);
      AssertCycleDerivation(9, 710, CycleType.Monthly);
      AssertCycleDerivation(10, 711, CycleType.Monthly);
      AssertCycleDerivation(11, 712, CycleType.Monthly);
      AssertCycleDerivation(12, 713, CycleType.Monthly);
      AssertCycleDerivation(13, 714, CycleType.Monthly);
      AssertCycleDerivation(14, 715, CycleType.Monthly);
      AssertCycleDerivation(15, 716, CycleType.Monthly);
      AssertCycleDerivation(16, 717, CycleType.Monthly);
      AssertCycleDerivation(17, 718, CycleType.Monthly);
      AssertCycleDerivation(18, 719, CycleType.Monthly);
      AssertCycleDerivation(19, 720, CycleType.Monthly);
      AssertCycleDerivation(20, 721, CycleType.Monthly);
      AssertCycleDerivation(21, 722, CycleType.Monthly);
      AssertCycleDerivation(22, 723, CycleType.Monthly);
      AssertCycleDerivation(23, 724, CycleType.Monthly);
      AssertCycleDerivation(24, 725, CycleType.Monthly);
      AssertCycleDerivation(25, 726, CycleType.Monthly);
      AssertCycleDerivation(26, 727, CycleType.Monthly);
      AssertCycleDerivation(27, 728, CycleType.Monthly);
      AssertCycleDerivation(28, 729, CycleType.Monthly);
      AssertCycleDerivation(29, 730, CycleType.Monthly);
      AssertCycleDerivation(30, 731, CycleType.Monthly);
      AssertCycleDerivation(31, 732, CycleType.Monthly);

      //Annual starting May 1
      AssertCycleDerivation(33, 733, CycleType.Monthly);
      AssertCycleDerivation(3, 734, CycleType.Monthly);
      AssertCycleDerivation(4, 735, CycleType.Monthly);
      AssertCycleDerivation(5, 736, CycleType.Monthly);
      AssertCycleDerivation(6, 737, CycleType.Monthly);
      AssertCycleDerivation(7, 738, CycleType.Monthly);
      AssertCycleDerivation(8, 739, CycleType.Monthly);
      AssertCycleDerivation(9, 740, CycleType.Monthly);
      AssertCycleDerivation(10, 741, CycleType.Monthly);
      AssertCycleDerivation(11, 742, CycleType.Monthly);
      AssertCycleDerivation(12, 743, CycleType.Monthly);
      AssertCycleDerivation(13, 744, CycleType.Monthly);
      AssertCycleDerivation(14, 745, CycleType.Monthly);
      AssertCycleDerivation(15, 746, CycleType.Monthly);
      AssertCycleDerivation(16, 747, CycleType.Monthly);
      AssertCycleDerivation(17, 748, CycleType.Monthly);
      AssertCycleDerivation(18, 749, CycleType.Monthly);
      AssertCycleDerivation(19, 750, CycleType.Monthly);
      AssertCycleDerivation(20, 751, CycleType.Monthly);
      AssertCycleDerivation(21, 752, CycleType.Monthly);
      AssertCycleDerivation(22, 753, CycleType.Monthly);
      AssertCycleDerivation(23, 754, CycleType.Monthly);
      AssertCycleDerivation(24, 755, CycleType.Monthly);
      AssertCycleDerivation(25, 756, CycleType.Monthly);
      AssertCycleDerivation(26, 757, CycleType.Monthly);
      AssertCycleDerivation(27, 758, CycleType.Monthly);
      AssertCycleDerivation(28, 759, CycleType.Monthly);
      AssertCycleDerivation(29, 760, CycleType.Monthly);
      AssertCycleDerivation(30, 761, CycleType.Monthly);
      AssertCycleDerivation(31, 762, CycleType.Monthly);
      AssertCycleDerivation(32, 763, CycleType.Monthly);

      //Annual starting June 1
      AssertCycleDerivation(33, 764, CycleType.Monthly);
      AssertCycleDerivation(3, 765, CycleType.Monthly);
      AssertCycleDerivation(4, 766, CycleType.Monthly);
      AssertCycleDerivation(5, 767, CycleType.Monthly);
      AssertCycleDerivation(6, 768, CycleType.Monthly);
      AssertCycleDerivation(7, 769, CycleType.Monthly);
      AssertCycleDerivation(8, 770, CycleType.Monthly);
      AssertCycleDerivation(9, 771, CycleType.Monthly);
      AssertCycleDerivation(10, 772, CycleType.Monthly);
      AssertCycleDerivation(11, 773, CycleType.Monthly);
      AssertCycleDerivation(12, 774, CycleType.Monthly);
      AssertCycleDerivation(13, 775, CycleType.Monthly);
      AssertCycleDerivation(14, 776, CycleType.Monthly);
      AssertCycleDerivation(15, 777, CycleType.Monthly);
      AssertCycleDerivation(16, 778, CycleType.Monthly);
      AssertCycleDerivation(17, 779, CycleType.Monthly);
      AssertCycleDerivation(18, 780, CycleType.Monthly);
      AssertCycleDerivation(19, 781, CycleType.Monthly);
      AssertCycleDerivation(20, 782, CycleType.Monthly);
      AssertCycleDerivation(21, 783, CycleType.Monthly);
      AssertCycleDerivation(22, 784, CycleType.Monthly);
      AssertCycleDerivation(23, 785, CycleType.Monthly);
      AssertCycleDerivation(24, 786, CycleType.Monthly);
      AssertCycleDerivation(25, 787, CycleType.Monthly);
      AssertCycleDerivation(26, 788, CycleType.Monthly);
      AssertCycleDerivation(27, 789, CycleType.Monthly);
      AssertCycleDerivation(28, 790, CycleType.Monthly);
      AssertCycleDerivation(29, 791, CycleType.Monthly);
      AssertCycleDerivation(30, 792, CycleType.Monthly);
      AssertCycleDerivation(31, 793, CycleType.Monthly);

      //Annual starting July 1
      AssertCycleDerivation(33, 794, CycleType.Monthly);
      AssertCycleDerivation(3, 795, CycleType.Monthly);
      AssertCycleDerivation(4, 796, CycleType.Monthly);
      AssertCycleDerivation(5, 797, CycleType.Monthly);
      AssertCycleDerivation(6, 798, CycleType.Monthly);
      AssertCycleDerivation(7, 799, CycleType.Monthly);
      AssertCycleDerivation(8, 800, CycleType.Monthly);
      AssertCycleDerivation(9, 801, CycleType.Monthly);
      AssertCycleDerivation(10, 802, CycleType.Monthly);
      AssertCycleDerivation(11, 803, CycleType.Monthly);
      AssertCycleDerivation(12, 804, CycleType.Monthly);
      AssertCycleDerivation(13, 805, CycleType.Monthly);
      AssertCycleDerivation(14, 806, CycleType.Monthly);
      AssertCycleDerivation(15, 807, CycleType.Monthly);
      AssertCycleDerivation(16, 808, CycleType.Monthly);
      AssertCycleDerivation(17, 809, CycleType.Monthly);
      AssertCycleDerivation(18, 810, CycleType.Monthly);
      AssertCycleDerivation(19, 811, CycleType.Monthly);
      AssertCycleDerivation(20, 812, CycleType.Monthly);
      AssertCycleDerivation(21, 813, CycleType.Monthly);
      AssertCycleDerivation(22, 814, CycleType.Monthly);
      AssertCycleDerivation(23, 815, CycleType.Monthly);
      AssertCycleDerivation(24, 816, CycleType.Monthly);
      AssertCycleDerivation(25, 817, CycleType.Monthly);
      AssertCycleDerivation(26, 818, CycleType.Monthly);
      AssertCycleDerivation(27, 819, CycleType.Monthly);
      AssertCycleDerivation(28, 820, CycleType.Monthly);
      AssertCycleDerivation(29, 821, CycleType.Monthly);
      AssertCycleDerivation(30, 822, CycleType.Monthly);
      AssertCycleDerivation(31, 823, CycleType.Monthly);
      AssertCycleDerivation(32, 824, CycleType.Monthly);

      //Annual starting August 1
      AssertCycleDerivation(33, 825, CycleType.Monthly);
      AssertCycleDerivation(3, 826, CycleType.Monthly);
      AssertCycleDerivation(4, 827, CycleType.Monthly);
      AssertCycleDerivation(5, 828, CycleType.Monthly);
      AssertCycleDerivation(6, 829, CycleType.Monthly);
      AssertCycleDerivation(7, 830, CycleType.Monthly);
      AssertCycleDerivation(8, 831, CycleType.Monthly);
      AssertCycleDerivation(9, 832, CycleType.Monthly);
      AssertCycleDerivation(10, 833, CycleType.Monthly);
      AssertCycleDerivation(11, 834, CycleType.Monthly);
      AssertCycleDerivation(12, 835, CycleType.Monthly);
      AssertCycleDerivation(13, 836, CycleType.Monthly);
      AssertCycleDerivation(14, 837, CycleType.Monthly);
      AssertCycleDerivation(15, 838, CycleType.Monthly);
      AssertCycleDerivation(16, 839, CycleType.Monthly);
      AssertCycleDerivation(17, 840, CycleType.Monthly);
      AssertCycleDerivation(18, 841, CycleType.Monthly);
      AssertCycleDerivation(19, 842, CycleType.Monthly);
      AssertCycleDerivation(20, 843, CycleType.Monthly);
      AssertCycleDerivation(21, 844, CycleType.Monthly);
      AssertCycleDerivation(22, 845, CycleType.Monthly);
      AssertCycleDerivation(23, 846, CycleType.Monthly);
      AssertCycleDerivation(24, 847, CycleType.Monthly);
      AssertCycleDerivation(25, 848, CycleType.Monthly);
      AssertCycleDerivation(26, 849, CycleType.Monthly);
      AssertCycleDerivation(27, 850, CycleType.Monthly);
      AssertCycleDerivation(28, 851, CycleType.Monthly);
      AssertCycleDerivation(29, 852, CycleType.Monthly);
      AssertCycleDerivation(30, 853, CycleType.Monthly);
      AssertCycleDerivation(31, 854, CycleType.Monthly);
      AssertCycleDerivation(32, 855, CycleType.Monthly);

      //Annual starting Sept 1
      AssertCycleDerivation(33, 856, CycleType.Monthly);
      AssertCycleDerivation(3, 857, CycleType.Monthly);
      AssertCycleDerivation(4, 858, CycleType.Monthly);
      AssertCycleDerivation(5, 859, CycleType.Monthly);
      AssertCycleDerivation(6, 860, CycleType.Monthly);
      AssertCycleDerivation(7, 861, CycleType.Monthly);
      AssertCycleDerivation(8, 862, CycleType.Monthly);
      AssertCycleDerivation(9, 863, CycleType.Monthly);
      AssertCycleDerivation(10, 864, CycleType.Monthly);
      AssertCycleDerivation(11, 865, CycleType.Monthly);
      AssertCycleDerivation(12, 866, CycleType.Monthly);
      AssertCycleDerivation(13, 867, CycleType.Monthly);
      AssertCycleDerivation(14, 868, CycleType.Monthly);
      AssertCycleDerivation(15, 869, CycleType.Monthly);
      AssertCycleDerivation(16, 870, CycleType.Monthly);
      AssertCycleDerivation(17, 871, CycleType.Monthly);
      AssertCycleDerivation(18, 872, CycleType.Monthly);
      AssertCycleDerivation(19, 873, CycleType.Monthly);
      AssertCycleDerivation(20, 874, CycleType.Monthly);
      AssertCycleDerivation(21, 875, CycleType.Monthly);
      AssertCycleDerivation(22, 876, CycleType.Monthly);
      AssertCycleDerivation(23, 877, CycleType.Monthly);
      AssertCycleDerivation(24, 878, CycleType.Monthly);
      AssertCycleDerivation(25, 879, CycleType.Monthly);
      AssertCycleDerivation(26, 880, CycleType.Monthly);
      AssertCycleDerivation(27, 881, CycleType.Monthly);
      AssertCycleDerivation(28, 882, CycleType.Monthly);
      AssertCycleDerivation(29, 883, CycleType.Monthly);
      AssertCycleDerivation(30, 884, CycleType.Monthly);
      AssertCycleDerivation(31, 885, CycleType.Monthly);

      //Annual starting Oct 1
      AssertCycleDerivation(33, 886, CycleType.Monthly);
      AssertCycleDerivation(3, 887, CycleType.Monthly);
      AssertCycleDerivation(4, 888, CycleType.Monthly);
      AssertCycleDerivation(5, 889, CycleType.Monthly);
      AssertCycleDerivation(6, 890, CycleType.Monthly);
      AssertCycleDerivation(7, 891, CycleType.Monthly);
      AssertCycleDerivation(8, 892, CycleType.Monthly);
      AssertCycleDerivation(9, 893, CycleType.Monthly);
      AssertCycleDerivation(10, 894, CycleType.Monthly);
      AssertCycleDerivation(11, 895, CycleType.Monthly);
      AssertCycleDerivation(12, 896, CycleType.Monthly);
      AssertCycleDerivation(13, 897, CycleType.Monthly);
      AssertCycleDerivation(14, 898, CycleType.Monthly);
      AssertCycleDerivation(15, 899, CycleType.Monthly);
      AssertCycleDerivation(16, 900, CycleType.Monthly);
      AssertCycleDerivation(17, 901, CycleType.Monthly);
      AssertCycleDerivation(18, 902, CycleType.Monthly);
      AssertCycleDerivation(19, 903, CycleType.Monthly);
      AssertCycleDerivation(20, 904, CycleType.Monthly);
      AssertCycleDerivation(21, 905, CycleType.Monthly);
      AssertCycleDerivation(22, 906, CycleType.Monthly);
      AssertCycleDerivation(23, 907, CycleType.Monthly);
      AssertCycleDerivation(24, 908, CycleType.Monthly);
      AssertCycleDerivation(25, 909, CycleType.Monthly);
      AssertCycleDerivation(26, 910, CycleType.Monthly);
      AssertCycleDerivation(27, 911, CycleType.Monthly);
      AssertCycleDerivation(28, 912, CycleType.Monthly);
      AssertCycleDerivation(29, 913, CycleType.Monthly);
      AssertCycleDerivation(30, 914, CycleType.Monthly);
      AssertCycleDerivation(31, 915, CycleType.Monthly);
      AssertCycleDerivation(32, 916, CycleType.Monthly);

      //Annual starting Nov 1
      AssertCycleDerivation(33, 917, CycleType.Monthly);
      AssertCycleDerivation(3, 918, CycleType.Monthly);
      AssertCycleDerivation(4, 919, CycleType.Monthly);
      AssertCycleDerivation(5, 920, CycleType.Monthly);
      AssertCycleDerivation(6, 921, CycleType.Monthly);
      AssertCycleDerivation(7, 922, CycleType.Monthly);
      AssertCycleDerivation(8, 923, CycleType.Monthly);
      AssertCycleDerivation(9, 924, CycleType.Monthly);
      AssertCycleDerivation(10, 925, CycleType.Monthly);
      AssertCycleDerivation(11, 926, CycleType.Monthly);
      AssertCycleDerivation(12, 927, CycleType.Monthly);
      AssertCycleDerivation(13, 928, CycleType.Monthly);
      AssertCycleDerivation(14, 929, CycleType.Monthly);
      AssertCycleDerivation(15, 930, CycleType.Monthly);
      AssertCycleDerivation(16, 931, CycleType.Monthly);
      AssertCycleDerivation(17, 932, CycleType.Monthly);
      AssertCycleDerivation(18, 933, CycleType.Monthly);
      AssertCycleDerivation(19, 934, CycleType.Monthly);
      AssertCycleDerivation(20, 935, CycleType.Monthly);
      AssertCycleDerivation(21, 936, CycleType.Monthly);
      AssertCycleDerivation(22, 937, CycleType.Monthly);
      AssertCycleDerivation(23, 938, CycleType.Monthly);
      AssertCycleDerivation(24, 939, CycleType.Monthly);
      AssertCycleDerivation(25, 940, CycleType.Monthly);
      AssertCycleDerivation(26, 941, CycleType.Monthly);
      AssertCycleDerivation(27, 942, CycleType.Monthly);
      AssertCycleDerivation(28, 943, CycleType.Monthly);
      AssertCycleDerivation(29, 944, CycleType.Monthly);
      AssertCycleDerivation(30, 945, CycleType.Monthly);
      AssertCycleDerivation(31, 946, CycleType.Monthly);

      //Annual starting Dec 1
      AssertCycleDerivation(33, 947, CycleType.Monthly);
      AssertCycleDerivation(3, 948, CycleType.Monthly);
      AssertCycleDerivation(4, 949, CycleType.Monthly);
      AssertCycleDerivation(5, 950, CycleType.Monthly);
      AssertCycleDerivation(6, 951, CycleType.Monthly);
      AssertCycleDerivation(7, 952, CycleType.Monthly);
      AssertCycleDerivation(8, 953, CycleType.Monthly);
      AssertCycleDerivation(9, 954, CycleType.Monthly);
      AssertCycleDerivation(10, 955, CycleType.Monthly);
      AssertCycleDerivation(11, 956, CycleType.Monthly);
      AssertCycleDerivation(12, 957, CycleType.Monthly);
      AssertCycleDerivation(13, 958, CycleType.Monthly);
      AssertCycleDerivation(14, 959, CycleType.Monthly);
      AssertCycleDerivation(15, 960, CycleType.Monthly);
      AssertCycleDerivation(16, 961, CycleType.Monthly);
      AssertCycleDerivation(17, 962, CycleType.Monthly);
      AssertCycleDerivation(18, 963, CycleType.Monthly);
      AssertCycleDerivation(19, 964, CycleType.Monthly);
      AssertCycleDerivation(20, 965, CycleType.Monthly);
      AssertCycleDerivation(21, 966, CycleType.Monthly);
      AssertCycleDerivation(22, 967, CycleType.Monthly);
      AssertCycleDerivation(23, 968, CycleType.Monthly);
      AssertCycleDerivation(24, 969, CycleType.Monthly);
      AssertCycleDerivation(25, 970, CycleType.Monthly);
      AssertCycleDerivation(26, 971, CycleType.Monthly);
      AssertCycleDerivation(27, 972, CycleType.Monthly);
      AssertCycleDerivation(28, 973, CycleType.Monthly);
      AssertCycleDerivation(29, 974, CycleType.Monthly);
      AssertCycleDerivation(30, 975, CycleType.Monthly);
      AssertCycleDerivation(31, 976, CycleType.Monthly);
      AssertCycleDerivation(32, 977, CycleType.Monthly);

      // SemiAnnual starting Jan 1
      AssertCycleDerivation(33, 978, CycleType.Monthly);
      AssertCycleDerivation(3, 979, CycleType.Monthly);
      AssertCycleDerivation(4, 980, CycleType.Monthly);
      AssertCycleDerivation(5, 981, CycleType.Monthly);
      AssertCycleDerivation(6, 982, CycleType.Monthly);
      AssertCycleDerivation(7, 983, CycleType.Monthly);
      AssertCycleDerivation(8, 984, CycleType.Monthly);
      AssertCycleDerivation(9, 985, CycleType.Monthly);
      AssertCycleDerivation(10, 986, CycleType.Monthly);
      AssertCycleDerivation(11, 987, CycleType.Monthly);
      AssertCycleDerivation(12, 988, CycleType.Monthly);
      AssertCycleDerivation(13, 989, CycleType.Monthly);
      AssertCycleDerivation(14, 990, CycleType.Monthly);
      AssertCycleDerivation(15, 991, CycleType.Monthly);
      AssertCycleDerivation(16, 992, CycleType.Monthly);
      AssertCycleDerivation(17, 993, CycleType.Monthly);
      AssertCycleDerivation(18, 994, CycleType.Monthly);
      AssertCycleDerivation(19, 995, CycleType.Monthly);
      AssertCycleDerivation(20, 996, CycleType.Monthly);
      AssertCycleDerivation(21, 997, CycleType.Monthly);
      AssertCycleDerivation(22, 998, CycleType.Monthly);
      AssertCycleDerivation(23, 999, CycleType.Monthly);
      AssertCycleDerivation(24, 1000, CycleType.Monthly);
      AssertCycleDerivation(25, 1001, CycleType.Monthly);
      AssertCycleDerivation(26, 1002, CycleType.Monthly);
      AssertCycleDerivation(27, 1003, CycleType.Monthly);
      AssertCycleDerivation(28, 1004, CycleType.Monthly);
      AssertCycleDerivation(29, 1005, CycleType.Monthly);
      AssertCycleDerivation(30, 1006, CycleType.Monthly);
      AssertCycleDerivation(31, 1007, CycleType.Monthly);
      AssertCycleDerivation(32, 1008, CycleType.Monthly);

      // SemiAnnual starting Feb 1
      AssertCycleDerivation(33, 1009, CycleType.Monthly);
      AssertCycleDerivation(3, 1010, CycleType.Monthly);
      AssertCycleDerivation(4, 1011, CycleType.Monthly);
      AssertCycleDerivation(5, 1012, CycleType.Monthly);
      AssertCycleDerivation(6, 1013, CycleType.Monthly);
      AssertCycleDerivation(7, 1014, CycleType.Monthly);
      AssertCycleDerivation(8, 1015, CycleType.Monthly);
      AssertCycleDerivation(9, 1016, CycleType.Monthly);
      AssertCycleDerivation(10, 1017, CycleType.Monthly);
      AssertCycleDerivation(11, 1018, CycleType.Monthly);
      AssertCycleDerivation(12, 1019, CycleType.Monthly);
      AssertCycleDerivation(13, 1020, CycleType.Monthly);
      AssertCycleDerivation(14, 1021, CycleType.Monthly);
      AssertCycleDerivation(15, 1022, CycleType.Monthly);
      AssertCycleDerivation(16, 1023, CycleType.Monthly);
      AssertCycleDerivation(17, 1024, CycleType.Monthly);
      AssertCycleDerivation(18, 1025, CycleType.Monthly);
      AssertCycleDerivation(19, 1026, CycleType.Monthly);
      AssertCycleDerivation(20, 1027, CycleType.Monthly);
      AssertCycleDerivation(21, 1028, CycleType.Monthly);
      AssertCycleDerivation(22, 1029, CycleType.Monthly);
      AssertCycleDerivation(23, 1030, CycleType.Monthly);
      AssertCycleDerivation(24, 1031, CycleType.Monthly);
      AssertCycleDerivation(25, 1032, CycleType.Monthly);
      AssertCycleDerivation(26, 1033, CycleType.Monthly);
      AssertCycleDerivation(27, 1034, CycleType.Monthly);
      AssertCycleDerivation(28, 1035, CycleType.Monthly);
      AssertCycleDerivation(29, 1036, CycleType.Monthly);

      // SemiAnnual starting Mar 1
      AssertCycleDerivation(33, 1037, CycleType.Monthly);
      AssertCycleDerivation(3, 1038, CycleType.Monthly);
      AssertCycleDerivation(4, 1039, CycleType.Monthly);
      AssertCycleDerivation(5, 1040, CycleType.Monthly);
      AssertCycleDerivation(6, 1041, CycleType.Monthly);
      AssertCycleDerivation(7, 1042, CycleType.Monthly);
      AssertCycleDerivation(8, 1043, CycleType.Monthly);
      AssertCycleDerivation(9, 1044, CycleType.Monthly);
      AssertCycleDerivation(10, 1045, CycleType.Monthly);
      AssertCycleDerivation(11, 1046, CycleType.Monthly);
      AssertCycleDerivation(12, 1047, CycleType.Monthly);
      AssertCycleDerivation(13, 1048, CycleType.Monthly);
      AssertCycleDerivation(14, 1049, CycleType.Monthly);
      AssertCycleDerivation(15, 1050, CycleType.Monthly);
      AssertCycleDerivation(16, 1051, CycleType.Monthly);
      AssertCycleDerivation(17, 1052, CycleType.Monthly);
      AssertCycleDerivation(18, 1053, CycleType.Monthly);
      AssertCycleDerivation(19, 1054, CycleType.Monthly);
      AssertCycleDerivation(20, 1055, CycleType.Monthly);
      AssertCycleDerivation(21, 1056, CycleType.Monthly);
      AssertCycleDerivation(22, 1057, CycleType.Monthly);
      AssertCycleDerivation(23, 1058, CycleType.Monthly);
      AssertCycleDerivation(24, 1059, CycleType.Monthly);
      AssertCycleDerivation(25, 1060, CycleType.Monthly);
      AssertCycleDerivation(26, 1061, CycleType.Monthly);
      AssertCycleDerivation(27, 1062, CycleType.Monthly);
      AssertCycleDerivation(28, 1063, CycleType.Monthly);
      AssertCycleDerivation(29, 1064, CycleType.Monthly);
      AssertCycleDerivation(30, 1065, CycleType.Monthly);
      AssertCycleDerivation(31, 1066, CycleType.Monthly);
      AssertCycleDerivation(32, 1067, CycleType.Monthly);

      // SemiAnnual starting Apr 1
      AssertCycleDerivation(33, 1068, CycleType.Monthly);
      AssertCycleDerivation(3, 1069, CycleType.Monthly);
      AssertCycleDerivation(4, 1070, CycleType.Monthly);
      AssertCycleDerivation(5, 1071, CycleType.Monthly);
      AssertCycleDerivation(6, 1072, CycleType.Monthly);
      AssertCycleDerivation(7, 1073, CycleType.Monthly);
      AssertCycleDerivation(8, 1074, CycleType.Monthly);
      AssertCycleDerivation(9, 1075, CycleType.Monthly);
      AssertCycleDerivation(10, 1076, CycleType.Monthly);
      AssertCycleDerivation(11, 1077, CycleType.Monthly);
      AssertCycleDerivation(12, 1078, CycleType.Monthly);
      AssertCycleDerivation(13, 1079, CycleType.Monthly);
      AssertCycleDerivation(14, 1080, CycleType.Monthly);
      AssertCycleDerivation(15, 1081, CycleType.Monthly);
      AssertCycleDerivation(16, 1082, CycleType.Monthly);
      AssertCycleDerivation(17, 1083, CycleType.Monthly);
      AssertCycleDerivation(18, 1084, CycleType.Monthly);
      AssertCycleDerivation(19, 1085, CycleType.Monthly);
      AssertCycleDerivation(20, 1086, CycleType.Monthly);
      AssertCycleDerivation(21, 1087, CycleType.Monthly);
      AssertCycleDerivation(22, 1088, CycleType.Monthly);
      AssertCycleDerivation(23, 1089, CycleType.Monthly);
      AssertCycleDerivation(24, 1090, CycleType.Monthly);
      AssertCycleDerivation(25, 1091, CycleType.Monthly);
      AssertCycleDerivation(26, 1092, CycleType.Monthly);
      AssertCycleDerivation(27, 1093, CycleType.Monthly);
      AssertCycleDerivation(28, 1094, CycleType.Monthly);
      AssertCycleDerivation(29, 1095, CycleType.Monthly);
      AssertCycleDerivation(30, 1096, CycleType.Monthly);
      AssertCycleDerivation(31, 1097, CycleType.Monthly);

      //SemiAnnual starting May 1
      AssertCycleDerivation(33, 1098, CycleType.Monthly);
      AssertCycleDerivation(3, 1099, CycleType.Monthly);
      AssertCycleDerivation(4, 1100, CycleType.Monthly);
      AssertCycleDerivation(5, 1101, CycleType.Monthly);
      AssertCycleDerivation(6, 1102, CycleType.Monthly);
      AssertCycleDerivation(7, 1103, CycleType.Monthly);
      AssertCycleDerivation(8, 1104, CycleType.Monthly);
      AssertCycleDerivation(9, 1105, CycleType.Monthly);
      AssertCycleDerivation(10, 1106, CycleType.Monthly);
      AssertCycleDerivation(11, 1107, CycleType.Monthly);
      AssertCycleDerivation(12, 1108, CycleType.Monthly);
      AssertCycleDerivation(13, 1109, CycleType.Monthly);
      AssertCycleDerivation(14, 1110, CycleType.Monthly);
      AssertCycleDerivation(15, 1111, CycleType.Monthly);
      AssertCycleDerivation(16, 1112, CycleType.Monthly);
      AssertCycleDerivation(17, 1113, CycleType.Monthly);
      AssertCycleDerivation(18, 1114, CycleType.Monthly);
      AssertCycleDerivation(19, 1115, CycleType.Monthly);
      AssertCycleDerivation(20, 1116, CycleType.Monthly);
      AssertCycleDerivation(21, 1117, CycleType.Monthly);
      AssertCycleDerivation(22, 1118, CycleType.Monthly);
      AssertCycleDerivation(23, 1119, CycleType.Monthly);
      AssertCycleDerivation(24, 1120, CycleType.Monthly);
      AssertCycleDerivation(25, 1121, CycleType.Monthly);
      AssertCycleDerivation(26, 1122, CycleType.Monthly);
      AssertCycleDerivation(27, 1123, CycleType.Monthly);
      AssertCycleDerivation(28, 1124, CycleType.Monthly);
      AssertCycleDerivation(29, 1125, CycleType.Monthly);
      AssertCycleDerivation(30, 1126, CycleType.Monthly);
      AssertCycleDerivation(31, 1127, CycleType.Monthly);
      AssertCycleDerivation(32, 1128, CycleType.Monthly);

      //SemiAnnual starting June 1
      AssertCycleDerivation(33, 1129, CycleType.Monthly);
      AssertCycleDerivation(3, 1130, CycleType.Monthly);
      AssertCycleDerivation(4, 1131, CycleType.Monthly);
      AssertCycleDerivation(5, 1132, CycleType.Monthly);
      AssertCycleDerivation(6, 1133, CycleType.Monthly);
      AssertCycleDerivation(7, 1134, CycleType.Monthly);
      AssertCycleDerivation(8, 1135, CycleType.Monthly);
      AssertCycleDerivation(9, 1136, CycleType.Monthly);
      AssertCycleDerivation(10, 1137, CycleType.Monthly);
      AssertCycleDerivation(11, 1138, CycleType.Monthly);
      AssertCycleDerivation(12, 1139, CycleType.Monthly);
      AssertCycleDerivation(13, 1140, CycleType.Monthly);
      AssertCycleDerivation(14, 1141, CycleType.Monthly);
      AssertCycleDerivation(15, 1142, CycleType.Monthly);
      AssertCycleDerivation(16, 1143, CycleType.Monthly);
      AssertCycleDerivation(17, 1144, CycleType.Monthly);
      AssertCycleDerivation(18, 1145, CycleType.Monthly);
      AssertCycleDerivation(19, 1146, CycleType.Monthly);
      AssertCycleDerivation(20, 1147, CycleType.Monthly);
      AssertCycleDerivation(21, 1148, CycleType.Monthly);
      AssertCycleDerivation(22, 1149, CycleType.Monthly);
      AssertCycleDerivation(23, 1150, CycleType.Monthly);
      AssertCycleDerivation(24, 1151, CycleType.Monthly);
      AssertCycleDerivation(25, 1152, CycleType.Monthly);
      AssertCycleDerivation(26, 1153, CycleType.Monthly);
      AssertCycleDerivation(27, 1154, CycleType.Monthly);
      AssertCycleDerivation(28, 1155, CycleType.Monthly);
      AssertCycleDerivation(29, 1156, CycleType.Monthly);
      AssertCycleDerivation(30, 1157, CycleType.Monthly);
      AssertCycleDerivation(31, 1158, CycleType.Monthly);

      //SemiAnnual starting July 1
      AssertCycleDerivation(33, 1159, CycleType.Monthly);
      AssertCycleDerivation(3, 1160, CycleType.Monthly);
      AssertCycleDerivation(4, 1161, CycleType.Monthly);
      AssertCycleDerivation(5, 1162, CycleType.Monthly);
      AssertCycleDerivation(6, 1163, CycleType.Monthly);
      AssertCycleDerivation(7, 1164, CycleType.Monthly);
      AssertCycleDerivation(8, 1165, CycleType.Monthly);
      AssertCycleDerivation(9, 1166, CycleType.Monthly);
      AssertCycleDerivation(10, 1167, CycleType.Monthly);
      AssertCycleDerivation(11, 1168, CycleType.Monthly);
      AssertCycleDerivation(12, 1169, CycleType.Monthly);
      AssertCycleDerivation(13, 1170, CycleType.Monthly);
      AssertCycleDerivation(14, 1171, CycleType.Monthly);
      AssertCycleDerivation(15, 1172, CycleType.Monthly);
      AssertCycleDerivation(16, 1173, CycleType.Monthly);
      AssertCycleDerivation(17, 1174, CycleType.Monthly);
      AssertCycleDerivation(18, 1175, CycleType.Monthly);
      AssertCycleDerivation(19, 1176, CycleType.Monthly);
      AssertCycleDerivation(20, 1177, CycleType.Monthly);
      AssertCycleDerivation(21, 1178, CycleType.Monthly);
      AssertCycleDerivation(22, 1179, CycleType.Monthly);
      AssertCycleDerivation(23, 1180, CycleType.Monthly);
      AssertCycleDerivation(24, 1181, CycleType.Monthly);
      AssertCycleDerivation(25, 1182, CycleType.Monthly);
      AssertCycleDerivation(26, 1183, CycleType.Monthly);
      AssertCycleDerivation(27, 1184, CycleType.Monthly);
      AssertCycleDerivation(28, 1185, CycleType.Monthly);
      AssertCycleDerivation(29, 1186, CycleType.Monthly);
      AssertCycleDerivation(30, 1187, CycleType.Monthly);
      AssertCycleDerivation(31, 1188, CycleType.Monthly);
      AssertCycleDerivation(32, 1189, CycleType.Monthly);

      //SemiAnnual starting August 1
      AssertCycleDerivation(33, 1190, CycleType.Monthly);
      AssertCycleDerivation(3, 1191, CycleType.Monthly);
      AssertCycleDerivation(4, 1192, CycleType.Monthly);
      AssertCycleDerivation(5, 1193, CycleType.Monthly);
      AssertCycleDerivation(6, 1194, CycleType.Monthly);
      AssertCycleDerivation(7, 1195, CycleType.Monthly);
      AssertCycleDerivation(8, 1196, CycleType.Monthly);
      AssertCycleDerivation(9, 1197, CycleType.Monthly);
      AssertCycleDerivation(10, 1198, CycleType.Monthly);
      AssertCycleDerivation(11, 1199, CycleType.Monthly);
      AssertCycleDerivation(12, 1200, CycleType.Monthly);
      AssertCycleDerivation(13, 1201, CycleType.Monthly);
      AssertCycleDerivation(14, 1202, CycleType.Monthly);
      AssertCycleDerivation(15, 1203, CycleType.Monthly);
      AssertCycleDerivation(16, 1204, CycleType.Monthly);
      AssertCycleDerivation(17, 1205, CycleType.Monthly);
      AssertCycleDerivation(18, 1206, CycleType.Monthly);
      AssertCycleDerivation(19, 1207, CycleType.Monthly);
      AssertCycleDerivation(20, 1208, CycleType.Monthly);
      AssertCycleDerivation(21, 1209, CycleType.Monthly);
      AssertCycleDerivation(22, 1210, CycleType.Monthly);
      AssertCycleDerivation(23, 1211, CycleType.Monthly);
      AssertCycleDerivation(24, 1212, CycleType.Monthly);
      AssertCycleDerivation(25, 1213, CycleType.Monthly);
      AssertCycleDerivation(26, 1214, CycleType.Monthly);
      AssertCycleDerivation(27, 1215, CycleType.Monthly);
      AssertCycleDerivation(28, 1216, CycleType.Monthly);
      AssertCycleDerivation(29, 1217, CycleType.Monthly);
      AssertCycleDerivation(30, 1218, CycleType.Monthly);
      AssertCycleDerivation(31, 1219, CycleType.Monthly);
      AssertCycleDerivation(32, 1220, CycleType.Monthly);

      //SemiAnnual starting Sept 1
      AssertCycleDerivation(33, 1221, CycleType.Monthly);
      AssertCycleDerivation(3, 1222, CycleType.Monthly);
      AssertCycleDerivation(4, 1223, CycleType.Monthly);
      AssertCycleDerivation(5, 1224, CycleType.Monthly);
      AssertCycleDerivation(6, 1225, CycleType.Monthly);
      AssertCycleDerivation(7, 1226, CycleType.Monthly);
      AssertCycleDerivation(8, 1227, CycleType.Monthly);
      AssertCycleDerivation(9, 1228, CycleType.Monthly);
      AssertCycleDerivation(10, 1229, CycleType.Monthly);
      AssertCycleDerivation(11, 1230, CycleType.Monthly);
      AssertCycleDerivation(12, 1231, CycleType.Monthly);
      AssertCycleDerivation(13, 1232, CycleType.Monthly);
      AssertCycleDerivation(14, 1233, CycleType.Monthly);
      AssertCycleDerivation(15, 1234, CycleType.Monthly);
      AssertCycleDerivation(16, 1235, CycleType.Monthly);
      AssertCycleDerivation(17, 1236, CycleType.Monthly);
      AssertCycleDerivation(18, 1237, CycleType.Monthly);
      AssertCycleDerivation(19, 1238, CycleType.Monthly);
      AssertCycleDerivation(20, 1239, CycleType.Monthly);
      AssertCycleDerivation(21, 1240, CycleType.Monthly);
      AssertCycleDerivation(22, 1241, CycleType.Monthly);
      AssertCycleDerivation(23, 1242, CycleType.Monthly);
      AssertCycleDerivation(24, 1243, CycleType.Monthly);
      AssertCycleDerivation(25, 1244, CycleType.Monthly);
      AssertCycleDerivation(26, 1245, CycleType.Monthly);
      AssertCycleDerivation(27, 1246, CycleType.Monthly);
      AssertCycleDerivation(28, 1247, CycleType.Monthly);
      AssertCycleDerivation(29, 1248, CycleType.Monthly);
      AssertCycleDerivation(30, 1249, CycleType.Monthly);
      AssertCycleDerivation(31, 1250, CycleType.Monthly);

      //SemiAnnual starting Oct 1
      AssertCycleDerivation(33, 1251, CycleType.Monthly);
      AssertCycleDerivation(3, 1252, CycleType.Monthly);
      AssertCycleDerivation(4, 1253, CycleType.Monthly);
      AssertCycleDerivation(5, 1254, CycleType.Monthly);
      AssertCycleDerivation(6, 1255, CycleType.Monthly);
      AssertCycleDerivation(7, 1256, CycleType.Monthly);
      AssertCycleDerivation(8, 1257, CycleType.Monthly);
      AssertCycleDerivation(9, 1258, CycleType.Monthly);
      AssertCycleDerivation(10, 1259, CycleType.Monthly);
      AssertCycleDerivation(11, 1260, CycleType.Monthly);
      AssertCycleDerivation(12, 1261, CycleType.Monthly);
      AssertCycleDerivation(13, 1262, CycleType.Monthly);
      AssertCycleDerivation(14, 1263, CycleType.Monthly);
      AssertCycleDerivation(15, 1264, CycleType.Monthly);
      AssertCycleDerivation(16, 1265, CycleType.Monthly);
      AssertCycleDerivation(17, 1266, CycleType.Monthly);
      AssertCycleDerivation(18, 1267, CycleType.Monthly);
      AssertCycleDerivation(19, 1268, CycleType.Monthly);
      AssertCycleDerivation(20, 1269, CycleType.Monthly);
      AssertCycleDerivation(21, 1270, CycleType.Monthly);
      AssertCycleDerivation(22, 1271, CycleType.Monthly);
      AssertCycleDerivation(23, 1272, CycleType.Monthly);
      AssertCycleDerivation(24, 1273, CycleType.Monthly);
      AssertCycleDerivation(25, 1274, CycleType.Monthly);
      AssertCycleDerivation(26, 1275, CycleType.Monthly);
      AssertCycleDerivation(27, 1276, CycleType.Monthly);
      AssertCycleDerivation(28, 1277, CycleType.Monthly);
      AssertCycleDerivation(29, 1278, CycleType.Monthly);
      AssertCycleDerivation(30, 1279, CycleType.Monthly);
      AssertCycleDerivation(31, 1280, CycleType.Monthly);
      AssertCycleDerivation(32, 1281, CycleType.Monthly);

      //SemiAnnual starting Nov 1
      AssertCycleDerivation(33, 1282, CycleType.Monthly);
      AssertCycleDerivation(3, 1283, CycleType.Monthly);
      AssertCycleDerivation(4, 1284, CycleType.Monthly);
      AssertCycleDerivation(5, 1285, CycleType.Monthly);
      AssertCycleDerivation(6, 1286, CycleType.Monthly);
      AssertCycleDerivation(7, 1287, CycleType.Monthly);
      AssertCycleDerivation(8, 1288, CycleType.Monthly);
      AssertCycleDerivation(9, 1289, CycleType.Monthly);
      AssertCycleDerivation(10, 1290, CycleType.Monthly);
      AssertCycleDerivation(11, 1291, CycleType.Monthly);
      AssertCycleDerivation(12, 1292, CycleType.Monthly);
      AssertCycleDerivation(13, 1293, CycleType.Monthly);
      AssertCycleDerivation(14, 1294, CycleType.Monthly);
      AssertCycleDerivation(15, 1295, CycleType.Monthly);
      AssertCycleDerivation(16, 1296, CycleType.Monthly);
      AssertCycleDerivation(17, 1297, CycleType.Monthly);
      AssertCycleDerivation(18, 1298, CycleType.Monthly);
      AssertCycleDerivation(19, 1299, CycleType.Monthly);
      AssertCycleDerivation(20, 1300, CycleType.Monthly);
      AssertCycleDerivation(21, 1301, CycleType.Monthly);
      AssertCycleDerivation(22, 1302, CycleType.Monthly);
      AssertCycleDerivation(23, 1303, CycleType.Monthly);
      AssertCycleDerivation(24, 1304, CycleType.Monthly);
      AssertCycleDerivation(25, 1305, CycleType.Monthly);
      AssertCycleDerivation(26, 1306, CycleType.Monthly);
      AssertCycleDerivation(27, 1307, CycleType.Monthly);
      AssertCycleDerivation(28, 1308, CycleType.Monthly);
      AssertCycleDerivation(29, 1309, CycleType.Monthly);
      AssertCycleDerivation(30, 1310, CycleType.Monthly);
      AssertCycleDerivation(31, 1311, CycleType.Monthly);

      //SemiAnnual starting Dec 1
      AssertCycleDerivation(33, 1312, CycleType.Monthly);
      AssertCycleDerivation(3, 1313, CycleType.Monthly);
      AssertCycleDerivation(4, 1314, CycleType.Monthly);
      AssertCycleDerivation(5, 1315, CycleType.Monthly);
      AssertCycleDerivation(6, 1316, CycleType.Monthly);
      AssertCycleDerivation(7, 1317, CycleType.Monthly);
      AssertCycleDerivation(8, 1318, CycleType.Monthly);
      AssertCycleDerivation(9, 1319, CycleType.Monthly);
      AssertCycleDerivation(10, 1320, CycleType.Monthly);
      AssertCycleDerivation(11, 1321, CycleType.Monthly);
      AssertCycleDerivation(12, 1322, CycleType.Monthly);
      AssertCycleDerivation(13, 1323, CycleType.Monthly);
      AssertCycleDerivation(14, 1324, CycleType.Monthly);
      AssertCycleDerivation(15, 1325, CycleType.Monthly);
      AssertCycleDerivation(16, 1326, CycleType.Monthly);
      AssertCycleDerivation(17, 1327, CycleType.Monthly);
      AssertCycleDerivation(18, 1328, CycleType.Monthly);
      AssertCycleDerivation(19, 1329, CycleType.Monthly);
      AssertCycleDerivation(20, 1330, CycleType.Monthly);
      AssertCycleDerivation(21, 1331, CycleType.Monthly);
      AssertCycleDerivation(22, 1332, CycleType.Monthly);
      AssertCycleDerivation(23, 1333, CycleType.Monthly);
      AssertCycleDerivation(24, 1334, CycleType.Monthly);
      AssertCycleDerivation(25, 1335, CycleType.Monthly);
      AssertCycleDerivation(26, 1336, CycleType.Monthly);
      AssertCycleDerivation(27, 1337, CycleType.Monthly);
      AssertCycleDerivation(28, 1338, CycleType.Monthly);
      AssertCycleDerivation(29, 1339, CycleType.Monthly);
      AssertCycleDerivation(30, 1340, CycleType.Monthly);
      AssertCycleDerivation(31, 1341, CycleType.Monthly);
      AssertCycleDerivation(32, 1342, CycleType.Monthly);

    }

    /// <summary>
    /// Tests cycle derivations for Quarterly EBCR PIs
    /// </summary>
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T04TestQuarterlyEBCRCycleDerivations()
    {
      // tests trivial BCR-reduction cases
      for (int cycle = 520; cycle <= 612; cycle++)
        AssertCycleDerivation(cycle, cycle, CycleType.Quarterly);

      //
      // tests Monthly usage cycles
      //

      // every Monthly cycle with a subscription date starting in Jan
      AssertCycleDerivation(521, 3, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(522, 4, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(523, 5, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(524, 6, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(525, 7, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(526, 8, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(527, 9, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(528, 10, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(529, 11, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(530, 12, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(531, 13, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(532, 14, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(533, 15, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(534, 16, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(535, 17, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(536, 18, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(537, 19, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(538, 20, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(539, 21, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(540, 22, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(541, 23, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(542, 24, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(543, 25, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(544, 26, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(545, 27, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(546, 28, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(547, 29, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(548, 30, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(549, 31, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(550, 32, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);
      AssertCycleDerivation(551, 33, GenerateRandomDateTimeWithMonth(1), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Feb
      AssertCycleDerivation(552, 3, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(553, 4, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(554, 5, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(555, 6, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(556, 7, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(557, 8, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(558, 9, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(559, 10, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(560, 11, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(561, 12, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(562, 13, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(563, 14, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(564, 15, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(565, 16, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(566, 17, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(567, 18, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(568, 19, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(569, 20, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(570, 21, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(571, 22, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(572, 23, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(573, 24, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(574, 25, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(575, 26, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(576, 27, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(577, 28, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(578, 29, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);
      AssertCycleDerivation(579, 30, GenerateRandomDateTimeWithMonth(2), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Mar
      AssertCycleDerivation(583, 3, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(584, 4, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(585, 5, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(586, 6, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(587, 7, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(588, 8, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(589, 9, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(590, 10, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(591, 11, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(592, 12, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(593, 13, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(594, 14, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(595, 15, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(596, 16, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(597, 17, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(598, 18, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(599, 19, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(600, 20, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(601, 21, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(602, 22, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(603, 23, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(604, 24, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(605, 25, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(606, 26, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(607, 27, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(608, 28, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(609, 29, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(610, 30, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(611, 31, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(612, 32, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);
      AssertCycleDerivation(520, 33, GenerateRandomDateTimeWithMonth(3), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Apr
      AssertCycleDerivation(521, 3, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(522, 4, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(523, 5, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(524, 6, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(525, 7, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(526, 8, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(527, 9, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(528, 10, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(529, 11, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(530, 12, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(531, 13, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(532, 14, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(533, 15, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(534, 16, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(535, 17, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(536, 18, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(537, 19, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(538, 20, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(539, 21, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(540, 22, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(541, 23, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(542, 24, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(543, 25, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(544, 26, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(545, 27, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(546, 28, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(547, 29, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(548, 30, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(549, 31, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);
      AssertCycleDerivation(550, 32, GenerateRandomDateTimeWithMonth(4), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in May
      AssertCycleDerivation(552, 3, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(553, 4, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(554, 5, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(555, 6, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(556, 7, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(557, 8, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(558, 9, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(559, 10, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(560, 11, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(561, 12, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(562, 13, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(563, 14, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(564, 15, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(565, 16, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(566, 17, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(567, 18, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(568, 19, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(569, 20, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(570, 21, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(571, 22, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(572, 23, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(573, 24, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(574, 25, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(575, 26, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(576, 27, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(577, 28, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(578, 29, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(579, 30, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(580, 31, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(581, 32, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);
      AssertCycleDerivation(582, 33, GenerateRandomDateTimeWithMonth(5), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Jun
      AssertCycleDerivation(583, 3, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(584, 4, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(585, 5, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(586, 6, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(587, 7, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(588, 8, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(589, 9, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(590, 10, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(591, 11, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(592, 12, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(593, 13, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(594, 14, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(595, 15, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(596, 16, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(597, 17, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(598, 18, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(599, 19, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(600, 20, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(601, 21, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(602, 22, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(603, 23, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(604, 24, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(605, 25, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(606, 26, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(607, 27, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(608, 28, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(609, 29, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(610, 30, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(611, 31, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);
      AssertCycleDerivation(520, 33, GenerateRandomDateTimeWithMonth(6), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Jul
      AssertCycleDerivation(521, 3, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(522, 4, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(523, 5, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(524, 6, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(525, 7, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(526, 8, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(527, 9, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(528, 10, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(529, 11, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(530, 12, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(531, 13, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(532, 14, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(533, 15, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(534, 16, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(535, 17, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(536, 18, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(537, 19, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(538, 20, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(539, 21, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(540, 22, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(541, 23, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(542, 24, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(543, 25, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(544, 26, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(545, 27, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(546, 28, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(547, 29, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(548, 30, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(549, 31, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(550, 32, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);
      AssertCycleDerivation(551, 33, GenerateRandomDateTimeWithMonth(7), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Aug
      AssertCycleDerivation(552, 3, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(553, 4, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(554, 5, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(555, 6, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(556, 7, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(557, 8, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(558, 9, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(559, 10, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(560, 11, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(561, 12, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(562, 13, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(563, 14, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(564, 15, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(565, 16, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(566, 17, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(567, 18, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(568, 19, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(569, 20, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(570, 21, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(571, 22, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(572, 23, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(573, 24, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(574, 25, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(575, 26, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(576, 27, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(577, 28, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(578, 29, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(579, 30, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(580, 31, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(581, 32, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);
      AssertCycleDerivation(582, 33, GenerateRandomDateTimeWithMonth(8), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Sep
      AssertCycleDerivation(583, 3, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(584, 4, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(585, 5, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(586, 6, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(587, 7, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(588, 8, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(589, 9, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(590, 10, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(591, 11, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(592, 12, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(593, 13, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(594, 14, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(595, 15, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(596, 16, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(597, 17, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(598, 18, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(599, 19, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(600, 20, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(601, 21, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(602, 22, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(603, 23, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(604, 24, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(605, 25, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(606, 26, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(607, 27, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(608, 28, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(609, 29, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(610, 30, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(611, 31, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);
      AssertCycleDerivation(520, 33, GenerateRandomDateTimeWithMonth(9), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Oct
      AssertCycleDerivation(521, 3, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(522, 4, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(523, 5, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(524, 6, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(525, 7, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(526, 8, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(527, 9, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(528, 10, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(529, 11, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(530, 12, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(531, 13, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(532, 14, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(533, 15, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(534, 16, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(535, 17, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(536, 18, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(537, 19, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(538, 20, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(539, 21, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(540, 22, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(541, 23, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(542, 24, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(543, 25, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(544, 26, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(545, 27, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(546, 28, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(547, 29, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(548, 30, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(549, 31, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(550, 32, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);
      AssertCycleDerivation(551, 33, GenerateRandomDateTimeWithMonth(10), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Nov
      AssertCycleDerivation(552, 3, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(553, 4, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(554, 5, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(555, 6, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(556, 7, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(557, 8, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(558, 9, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(559, 10, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(560, 11, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(561, 12, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(562, 13, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(563, 14, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(564, 15, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(565, 16, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(566, 17, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(567, 18, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(568, 19, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(569, 20, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(570, 21, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(571, 22, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(572, 23, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(573, 24, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(574, 25, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(575, 26, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(576, 27, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(577, 28, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(578, 29, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(579, 30, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(580, 31, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);
      AssertCycleDerivation(581, 32, GenerateRandomDateTimeWithMonth(11), CycleType.Quarterly);

      // every Monthly cycle with a subscription date starting in Dec
      AssertCycleDerivation(583, 3, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(584, 4, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(585, 5, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(586, 6, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(587, 7, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(588, 8, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(589, 9, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(590, 10, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(591, 11, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(592, 12, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(593, 13, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(594, 14, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(595, 15, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(596, 16, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(597, 17, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(598, 18, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(599, 19, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(600, 20, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(601, 21, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(602, 22, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(603, 23, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(604, 24, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(605, 25, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(606, 26, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(607, 27, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(608, 28, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(609, 29, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(610, 30, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(611, 31, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(612, 32, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);
      AssertCycleDerivation(520, 33, GenerateRandomDateTimeWithMonth(12), CycleType.Quarterly);

      //
      // tests Annual usage cycles
      //
      //The script for generating these looks something like this:
      //      echo // Annual starting on Aug 1
      //for /l %%x in (0, 1, 30) do (
      //    set /a result=!result!+1
      //  set /a input=!input!+1
      //  echo  AssertCycleDerivation^(!result!, !input!,  CycleType.Quarterly^);
      //  )
      //echo.
      //echo // Annual starting on Sep 1
      //for /l %%x in (0, 1, 29) do (
      //    set /a result=!result!+1
      //  set /a input=!input!+1
      //  echo  AssertCycleDerivation^(!result!, !input!,  CycleType.Quarterly^);
      //  )
      //echo.
      //set /a result=%1
      //echo // Annual starting on Oct 1
      //for /l %%x in (0, 1, 30) do (
      //    set /a result=!result!+1
      //  set /a input=!input!+1
      //  echo  AssertCycleDerivation^(!result!, !input!, CycleType.Quarterly^);
      //  )
      // Annual starting on Jan 1
      AssertCycleDerivation(520, 613, CycleType.Quarterly);
      AssertCycleDerivation(521, 614, CycleType.Quarterly);
      AssertCycleDerivation(522, 615, CycleType.Quarterly);
      AssertCycleDerivation(523, 616, CycleType.Quarterly);
      AssertCycleDerivation(524, 617, CycleType.Quarterly);
      AssertCycleDerivation(525, 618, CycleType.Quarterly);
      AssertCycleDerivation(526, 619, CycleType.Quarterly);
      AssertCycleDerivation(527, 620, CycleType.Quarterly);
      AssertCycleDerivation(528, 621, CycleType.Quarterly);
      AssertCycleDerivation(529, 622, CycleType.Quarterly);
      AssertCycleDerivation(530, 623, CycleType.Quarterly);
      AssertCycleDerivation(531, 624, CycleType.Quarterly);
      AssertCycleDerivation(532, 625, CycleType.Quarterly);
      AssertCycleDerivation(533, 626, CycleType.Quarterly);
      AssertCycleDerivation(534, 627, CycleType.Quarterly);
      AssertCycleDerivation(535, 628, CycleType.Quarterly);
      AssertCycleDerivation(536, 629, CycleType.Quarterly);
      AssertCycleDerivation(537, 630, CycleType.Quarterly);
      AssertCycleDerivation(538, 631, CycleType.Quarterly);
      AssertCycleDerivation(539, 632, CycleType.Quarterly);
      AssertCycleDerivation(540, 633, CycleType.Quarterly);
      AssertCycleDerivation(541, 634, CycleType.Quarterly);
      AssertCycleDerivation(542, 635, CycleType.Quarterly);
      AssertCycleDerivation(543, 636, CycleType.Quarterly);
      AssertCycleDerivation(544, 637, CycleType.Quarterly);
      AssertCycleDerivation(545, 638, CycleType.Quarterly);
      AssertCycleDerivation(546, 639, CycleType.Quarterly);
      AssertCycleDerivation(547, 640, CycleType.Quarterly);
      AssertCycleDerivation(548, 641, CycleType.Quarterly);
      AssertCycleDerivation(549, 642, CycleType.Quarterly);
      AssertCycleDerivation(550, 643, CycleType.Quarterly);

      // Annual starting on Feb 1
      AssertCycleDerivation(551, 644, CycleType.Quarterly);
      AssertCycleDerivation(552, 645, CycleType.Quarterly);
      AssertCycleDerivation(553, 646, CycleType.Quarterly);
      AssertCycleDerivation(554, 647, CycleType.Quarterly);
      AssertCycleDerivation(555, 648, CycleType.Quarterly);
      AssertCycleDerivation(556, 649, CycleType.Quarterly);
      AssertCycleDerivation(557, 650, CycleType.Quarterly);
      AssertCycleDerivation(558, 651, CycleType.Quarterly);
      AssertCycleDerivation(559, 652, CycleType.Quarterly);
      AssertCycleDerivation(560, 653, CycleType.Quarterly);
      AssertCycleDerivation(561, 654, CycleType.Quarterly);
      AssertCycleDerivation(562, 655, CycleType.Quarterly);
      AssertCycleDerivation(563, 656, CycleType.Quarterly);
      AssertCycleDerivation(564, 657, CycleType.Quarterly);
      AssertCycleDerivation(565, 658, CycleType.Quarterly);
      AssertCycleDerivation(566, 659, CycleType.Quarterly);
      AssertCycleDerivation(567, 660, CycleType.Quarterly);
      AssertCycleDerivation(568, 661, CycleType.Quarterly);
      AssertCycleDerivation(569, 662, CycleType.Quarterly);
      AssertCycleDerivation(570, 663, CycleType.Quarterly);
      AssertCycleDerivation(571, 664, CycleType.Quarterly);
      AssertCycleDerivation(572, 665, CycleType.Quarterly);
      AssertCycleDerivation(573, 666, CycleType.Quarterly);
      AssertCycleDerivation(574, 667, CycleType.Quarterly);
      AssertCycleDerivation(575, 668, CycleType.Quarterly);
      AssertCycleDerivation(576, 669, CycleType.Quarterly);
      AssertCycleDerivation(577, 670, CycleType.Quarterly);
      AssertCycleDerivation(578, 671, CycleType.Quarterly);

      // Annual starting on Mar 1
      AssertCycleDerivation(582, 672, CycleType.Quarterly);
      AssertCycleDerivation(583, 673, CycleType.Quarterly);
      AssertCycleDerivation(584, 674, CycleType.Quarterly);
      AssertCycleDerivation(585, 675, CycleType.Quarterly);
      AssertCycleDerivation(586, 676, CycleType.Quarterly);
      AssertCycleDerivation(587, 677, CycleType.Quarterly);
      AssertCycleDerivation(588, 678, CycleType.Quarterly);
      AssertCycleDerivation(589, 679, CycleType.Quarterly);
      AssertCycleDerivation(590, 680, CycleType.Quarterly);
      AssertCycleDerivation(591, 681, CycleType.Quarterly);
      AssertCycleDerivation(592, 682, CycleType.Quarterly);
      AssertCycleDerivation(593, 683, CycleType.Quarterly);
      AssertCycleDerivation(594, 684, CycleType.Quarterly);
      AssertCycleDerivation(595, 685, CycleType.Quarterly);
      AssertCycleDerivation(596, 686, CycleType.Quarterly);
      AssertCycleDerivation(597, 687, CycleType.Quarterly);
      AssertCycleDerivation(598, 688, CycleType.Quarterly);
      AssertCycleDerivation(599, 689, CycleType.Quarterly);
      AssertCycleDerivation(600, 690, CycleType.Quarterly);
      AssertCycleDerivation(601, 691, CycleType.Quarterly);
      AssertCycleDerivation(602, 692, CycleType.Quarterly);
      AssertCycleDerivation(603, 693, CycleType.Quarterly);
      AssertCycleDerivation(604, 694, CycleType.Quarterly);
      AssertCycleDerivation(605, 695, CycleType.Quarterly);
      AssertCycleDerivation(606, 696, CycleType.Quarterly);
      AssertCycleDerivation(607, 697, CycleType.Quarterly);
      AssertCycleDerivation(608, 698, CycleType.Quarterly);
      AssertCycleDerivation(609, 699, CycleType.Quarterly);
      AssertCycleDerivation(610, 700, CycleType.Quarterly);
      AssertCycleDerivation(611, 701, CycleType.Quarterly);
      AssertCycleDerivation(612, 702, CycleType.Quarterly);

      // Annual starting on Apr 1
      AssertCycleDerivation(520, 703, CycleType.Quarterly);
      AssertCycleDerivation(521, 704, CycleType.Quarterly);
      AssertCycleDerivation(522, 705, CycleType.Quarterly);
      AssertCycleDerivation(523, 706, CycleType.Quarterly);
      AssertCycleDerivation(524, 707, CycleType.Quarterly);
      AssertCycleDerivation(525, 708, CycleType.Quarterly);
      AssertCycleDerivation(526, 709, CycleType.Quarterly);
      AssertCycleDerivation(527, 710, CycleType.Quarterly);
      AssertCycleDerivation(528, 711, CycleType.Quarterly);
      AssertCycleDerivation(529, 712, CycleType.Quarterly);
      AssertCycleDerivation(530, 713, CycleType.Quarterly);
      AssertCycleDerivation(531, 714, CycleType.Quarterly);
      AssertCycleDerivation(532, 715, CycleType.Quarterly);
      AssertCycleDerivation(533, 716, CycleType.Quarterly);
      AssertCycleDerivation(534, 717, CycleType.Quarterly);
      AssertCycleDerivation(535, 718, CycleType.Quarterly);
      AssertCycleDerivation(536, 719, CycleType.Quarterly);
      AssertCycleDerivation(537, 720, CycleType.Quarterly);
      AssertCycleDerivation(538, 721, CycleType.Quarterly);
      AssertCycleDerivation(539, 722, CycleType.Quarterly);
      AssertCycleDerivation(540, 723, CycleType.Quarterly);
      AssertCycleDerivation(541, 724, CycleType.Quarterly);
      AssertCycleDerivation(542, 725, CycleType.Quarterly);
      AssertCycleDerivation(543, 726, CycleType.Quarterly);
      AssertCycleDerivation(544, 727, CycleType.Quarterly);
      AssertCycleDerivation(545, 728, CycleType.Quarterly);
      AssertCycleDerivation(546, 729, CycleType.Quarterly);
      AssertCycleDerivation(547, 730, CycleType.Quarterly);
      AssertCycleDerivation(548, 731, CycleType.Quarterly);
      AssertCycleDerivation(549, 732, CycleType.Quarterly);

      // Annual starting on May 1
      AssertCycleDerivation(551, 733, CycleType.Quarterly);
      AssertCycleDerivation(552, 734, CycleType.Quarterly);
      AssertCycleDerivation(553, 735, CycleType.Quarterly);
      AssertCycleDerivation(554, 736, CycleType.Quarterly);
      AssertCycleDerivation(555, 737, CycleType.Quarterly);
      AssertCycleDerivation(556, 738, CycleType.Quarterly);
      AssertCycleDerivation(557, 739, CycleType.Quarterly);
      AssertCycleDerivation(558, 740, CycleType.Quarterly);
      AssertCycleDerivation(559, 741, CycleType.Quarterly);
      AssertCycleDerivation(560, 742, CycleType.Quarterly);
      AssertCycleDerivation(561, 743, CycleType.Quarterly);
      AssertCycleDerivation(562, 744, CycleType.Quarterly);
      AssertCycleDerivation(563, 745, CycleType.Quarterly);
      AssertCycleDerivation(564, 746, CycleType.Quarterly);
      AssertCycleDerivation(565, 747, CycleType.Quarterly);
      AssertCycleDerivation(566, 748, CycleType.Quarterly);
      AssertCycleDerivation(567, 749, CycleType.Quarterly);
      AssertCycleDerivation(568, 750, CycleType.Quarterly);
      AssertCycleDerivation(569, 751, CycleType.Quarterly);
      AssertCycleDerivation(570, 752, CycleType.Quarterly);
      AssertCycleDerivation(571, 753, CycleType.Quarterly);
      AssertCycleDerivation(572, 754, CycleType.Quarterly);
      AssertCycleDerivation(573, 755, CycleType.Quarterly);
      AssertCycleDerivation(574, 756, CycleType.Quarterly);
      AssertCycleDerivation(575, 757, CycleType.Quarterly);
      AssertCycleDerivation(576, 758, CycleType.Quarterly);
      AssertCycleDerivation(577, 759, CycleType.Quarterly);
      AssertCycleDerivation(578, 760, CycleType.Quarterly);
      AssertCycleDerivation(579, 761, CycleType.Quarterly);
      AssertCycleDerivation(580, 762, CycleType.Quarterly);
      AssertCycleDerivation(581, 763, CycleType.Quarterly);

      // Annual starting on Jun 1
      AssertCycleDerivation(582, 764, CycleType.Quarterly);
      AssertCycleDerivation(583, 765, CycleType.Quarterly);
      AssertCycleDerivation(584, 766, CycleType.Quarterly);
      AssertCycleDerivation(585, 767, CycleType.Quarterly);
      AssertCycleDerivation(586, 768, CycleType.Quarterly);
      AssertCycleDerivation(587, 769, CycleType.Quarterly);
      AssertCycleDerivation(588, 770, CycleType.Quarterly);
      AssertCycleDerivation(589, 771, CycleType.Quarterly);
      AssertCycleDerivation(590, 772, CycleType.Quarterly);
      AssertCycleDerivation(591, 773, CycleType.Quarterly);
      AssertCycleDerivation(592, 774, CycleType.Quarterly);
      AssertCycleDerivation(593, 775, CycleType.Quarterly);
      AssertCycleDerivation(594, 776, CycleType.Quarterly);
      AssertCycleDerivation(595, 777, CycleType.Quarterly);
      AssertCycleDerivation(596, 778, CycleType.Quarterly);
      AssertCycleDerivation(597, 779, CycleType.Quarterly);
      AssertCycleDerivation(598, 780, CycleType.Quarterly);
      AssertCycleDerivation(599, 781, CycleType.Quarterly);
      AssertCycleDerivation(600, 782, CycleType.Quarterly);
      AssertCycleDerivation(601, 783, CycleType.Quarterly);
      AssertCycleDerivation(602, 784, CycleType.Quarterly);
      AssertCycleDerivation(603, 785, CycleType.Quarterly);
      AssertCycleDerivation(604, 786, CycleType.Quarterly);
      AssertCycleDerivation(605, 787, CycleType.Quarterly);
      AssertCycleDerivation(606, 788, CycleType.Quarterly);
      AssertCycleDerivation(607, 789, CycleType.Quarterly);
      AssertCycleDerivation(608, 790, CycleType.Quarterly);
      AssertCycleDerivation(609, 791, CycleType.Quarterly);
      AssertCycleDerivation(610, 792, CycleType.Quarterly);
      AssertCycleDerivation(611, 793, CycleType.Quarterly);

      // Annual starting on Jul 1
      AssertCycleDerivation(520, 794, CycleType.Quarterly);
      AssertCycleDerivation(521, 795, CycleType.Quarterly);
      AssertCycleDerivation(522, 796, CycleType.Quarterly);
      AssertCycleDerivation(523, 797, CycleType.Quarterly);
      AssertCycleDerivation(524, 798, CycleType.Quarterly);
      AssertCycleDerivation(525, 799, CycleType.Quarterly);
      AssertCycleDerivation(526, 800, CycleType.Quarterly);
      AssertCycleDerivation(527, 801, CycleType.Quarterly);
      AssertCycleDerivation(528, 802, CycleType.Quarterly);
      AssertCycleDerivation(529, 803, CycleType.Quarterly);
      AssertCycleDerivation(530, 804, CycleType.Quarterly);
      AssertCycleDerivation(531, 805, CycleType.Quarterly);
      AssertCycleDerivation(532, 806, CycleType.Quarterly);
      AssertCycleDerivation(533, 807, CycleType.Quarterly);
      AssertCycleDerivation(534, 808, CycleType.Quarterly);
      AssertCycleDerivation(535, 809, CycleType.Quarterly);
      AssertCycleDerivation(536, 810, CycleType.Quarterly);
      AssertCycleDerivation(537, 811, CycleType.Quarterly);
      AssertCycleDerivation(538, 812, CycleType.Quarterly);
      AssertCycleDerivation(539, 813, CycleType.Quarterly);
      AssertCycleDerivation(540, 814, CycleType.Quarterly);
      AssertCycleDerivation(541, 815, CycleType.Quarterly);
      AssertCycleDerivation(542, 816, CycleType.Quarterly);
      AssertCycleDerivation(543, 817, CycleType.Quarterly);
      AssertCycleDerivation(544, 818, CycleType.Quarterly);
      AssertCycleDerivation(545, 819, CycleType.Quarterly);
      AssertCycleDerivation(546, 820, CycleType.Quarterly);
      AssertCycleDerivation(547, 821, CycleType.Quarterly);
      AssertCycleDerivation(548, 822, CycleType.Quarterly);
      AssertCycleDerivation(549, 823, CycleType.Quarterly);
      AssertCycleDerivation(550, 824, CycleType.Quarterly);

      // Annual starting on Aug 1
      AssertCycleDerivation(551, 825, CycleType.Quarterly);
      AssertCycleDerivation(552, 826, CycleType.Quarterly);
      AssertCycleDerivation(553, 827, CycleType.Quarterly);
      AssertCycleDerivation(554, 828, CycleType.Quarterly);
      AssertCycleDerivation(555, 829, CycleType.Quarterly);
      AssertCycleDerivation(556, 830, CycleType.Quarterly);
      AssertCycleDerivation(557, 831, CycleType.Quarterly);
      AssertCycleDerivation(558, 832, CycleType.Quarterly);
      AssertCycleDerivation(559, 833, CycleType.Quarterly);
      AssertCycleDerivation(560, 834, CycleType.Quarterly);
      AssertCycleDerivation(561, 835, CycleType.Quarterly);
      AssertCycleDerivation(562, 836, CycleType.Quarterly);
      AssertCycleDerivation(563, 837, CycleType.Quarterly);
      AssertCycleDerivation(564, 838, CycleType.Quarterly);
      AssertCycleDerivation(565, 839, CycleType.Quarterly);
      AssertCycleDerivation(566, 840, CycleType.Quarterly);
      AssertCycleDerivation(567, 841, CycleType.Quarterly);
      AssertCycleDerivation(568, 842, CycleType.Quarterly);
      AssertCycleDerivation(569, 843, CycleType.Quarterly);
      AssertCycleDerivation(570, 844, CycleType.Quarterly);
      AssertCycleDerivation(571, 845, CycleType.Quarterly);
      AssertCycleDerivation(572, 846, CycleType.Quarterly);
      AssertCycleDerivation(573, 847, CycleType.Quarterly);
      AssertCycleDerivation(574, 848, CycleType.Quarterly);
      AssertCycleDerivation(575, 849, CycleType.Quarterly);
      AssertCycleDerivation(576, 850, CycleType.Quarterly);
      AssertCycleDerivation(577, 851, CycleType.Quarterly);
      AssertCycleDerivation(578, 852, CycleType.Quarterly);
      AssertCycleDerivation(579, 853, CycleType.Quarterly);
      AssertCycleDerivation(580, 854, CycleType.Quarterly);
      AssertCycleDerivation(581, 855, CycleType.Quarterly);

      // Annual starting on Sep 1
      AssertCycleDerivation(582, 856, CycleType.Quarterly);
      AssertCycleDerivation(583, 857, CycleType.Quarterly);
      AssertCycleDerivation(584, 858, CycleType.Quarterly);
      AssertCycleDerivation(585, 859, CycleType.Quarterly);
      AssertCycleDerivation(586, 860, CycleType.Quarterly);
      AssertCycleDerivation(587, 861, CycleType.Quarterly);
      AssertCycleDerivation(588, 862, CycleType.Quarterly);
      AssertCycleDerivation(589, 863, CycleType.Quarterly);
      AssertCycleDerivation(590, 864, CycleType.Quarterly);
      AssertCycleDerivation(591, 865, CycleType.Quarterly);
      AssertCycleDerivation(592, 866, CycleType.Quarterly);
      AssertCycleDerivation(593, 867, CycleType.Quarterly);
      AssertCycleDerivation(594, 868, CycleType.Quarterly);
      AssertCycleDerivation(595, 869, CycleType.Quarterly);
      AssertCycleDerivation(596, 870, CycleType.Quarterly);
      AssertCycleDerivation(597, 871, CycleType.Quarterly);
      AssertCycleDerivation(598, 872, CycleType.Quarterly);
      AssertCycleDerivation(599, 873, CycleType.Quarterly);
      AssertCycleDerivation(600, 874, CycleType.Quarterly);
      AssertCycleDerivation(601, 875, CycleType.Quarterly);
      AssertCycleDerivation(602, 876, CycleType.Quarterly);
      AssertCycleDerivation(603, 877, CycleType.Quarterly);
      AssertCycleDerivation(604, 878, CycleType.Quarterly);
      AssertCycleDerivation(605, 879, CycleType.Quarterly);
      AssertCycleDerivation(606, 880, CycleType.Quarterly);
      AssertCycleDerivation(607, 881, CycleType.Quarterly);
      AssertCycleDerivation(608, 882, CycleType.Quarterly);
      AssertCycleDerivation(609, 883, CycleType.Quarterly);
      AssertCycleDerivation(610, 884, CycleType.Quarterly);
      AssertCycleDerivation(611, 885, CycleType.Quarterly);

      // Annual starting on Oct 1
      AssertCycleDerivation(520, 886, CycleType.Quarterly);
      AssertCycleDerivation(521, 887, CycleType.Quarterly);
      AssertCycleDerivation(522, 888, CycleType.Quarterly);
      AssertCycleDerivation(523, 889, CycleType.Quarterly);
      AssertCycleDerivation(524, 890, CycleType.Quarterly);
      AssertCycleDerivation(525, 891, CycleType.Quarterly);
      AssertCycleDerivation(526, 892, CycleType.Quarterly);
      AssertCycleDerivation(527, 893, CycleType.Quarterly);
      AssertCycleDerivation(528, 894, CycleType.Quarterly);
      AssertCycleDerivation(529, 895, CycleType.Quarterly);
      AssertCycleDerivation(530, 896, CycleType.Quarterly);
      AssertCycleDerivation(531, 897, CycleType.Quarterly);
      AssertCycleDerivation(532, 898, CycleType.Quarterly);
      AssertCycleDerivation(533, 899, CycleType.Quarterly);
      AssertCycleDerivation(534, 900, CycleType.Quarterly);
      AssertCycleDerivation(535, 901, CycleType.Quarterly);
      AssertCycleDerivation(536, 902, CycleType.Quarterly);
      AssertCycleDerivation(537, 903, CycleType.Quarterly);
      AssertCycleDerivation(538, 904, CycleType.Quarterly);
      AssertCycleDerivation(539, 905, CycleType.Quarterly);
      AssertCycleDerivation(540, 906, CycleType.Quarterly);
      AssertCycleDerivation(541, 907, CycleType.Quarterly);
      AssertCycleDerivation(542, 908, CycleType.Quarterly);
      AssertCycleDerivation(543, 909, CycleType.Quarterly);
      AssertCycleDerivation(544, 910, CycleType.Quarterly);
      AssertCycleDerivation(545, 911, CycleType.Quarterly);
      AssertCycleDerivation(546, 912, CycleType.Quarterly);
      AssertCycleDerivation(547, 913, CycleType.Quarterly);
      AssertCycleDerivation(548, 914, CycleType.Quarterly);
      AssertCycleDerivation(549, 915, CycleType.Quarterly);
      AssertCycleDerivation(550, 916, CycleType.Quarterly);

      // Annual starting on Nov 1
      AssertCycleDerivation(551, 917, CycleType.Quarterly);
      AssertCycleDerivation(552, 918, CycleType.Quarterly);
      AssertCycleDerivation(553, 919, CycleType.Quarterly);
      AssertCycleDerivation(554, 920, CycleType.Quarterly);
      AssertCycleDerivation(555, 921, CycleType.Quarterly);
      AssertCycleDerivation(556, 922, CycleType.Quarterly);
      AssertCycleDerivation(557, 923, CycleType.Quarterly);
      AssertCycleDerivation(558, 924, CycleType.Quarterly);
      AssertCycleDerivation(559, 925, CycleType.Quarterly);
      AssertCycleDerivation(560, 926, CycleType.Quarterly);
      AssertCycleDerivation(561, 927, CycleType.Quarterly);
      AssertCycleDerivation(562, 928, CycleType.Quarterly);
      AssertCycleDerivation(563, 929, CycleType.Quarterly);
      AssertCycleDerivation(564, 930, CycleType.Quarterly);
      AssertCycleDerivation(565, 931, CycleType.Quarterly);
      AssertCycleDerivation(566, 932, CycleType.Quarterly);
      AssertCycleDerivation(567, 933, CycleType.Quarterly);
      AssertCycleDerivation(568, 934, CycleType.Quarterly);
      AssertCycleDerivation(569, 935, CycleType.Quarterly);
      AssertCycleDerivation(570, 936, CycleType.Quarterly);
      AssertCycleDerivation(571, 937, CycleType.Quarterly);
      AssertCycleDerivation(572, 938, CycleType.Quarterly);
      AssertCycleDerivation(573, 939, CycleType.Quarterly);
      AssertCycleDerivation(574, 940, CycleType.Quarterly);
      AssertCycleDerivation(575, 941, CycleType.Quarterly);
      AssertCycleDerivation(576, 942, CycleType.Quarterly);
      AssertCycleDerivation(577, 943, CycleType.Quarterly);
      AssertCycleDerivation(578, 944, CycleType.Quarterly);
      AssertCycleDerivation(579, 945, CycleType.Quarterly);
      AssertCycleDerivation(580, 946, CycleType.Quarterly);

      // Annual starting on Dec 1
      AssertCycleDerivation(582, 947, CycleType.Quarterly);
      AssertCycleDerivation(583, 948, CycleType.Quarterly);
      AssertCycleDerivation(584, 949, CycleType.Quarterly);
      AssertCycleDerivation(585, 950, CycleType.Quarterly);
      AssertCycleDerivation(586, 951, CycleType.Quarterly);
      AssertCycleDerivation(587, 952, CycleType.Quarterly);
      AssertCycleDerivation(588, 953, CycleType.Quarterly);
      AssertCycleDerivation(589, 954, CycleType.Quarterly);
      AssertCycleDerivation(590, 955, CycleType.Quarterly);
      AssertCycleDerivation(591, 956, CycleType.Quarterly);
      AssertCycleDerivation(592, 957, CycleType.Quarterly);
      AssertCycleDerivation(593, 958, CycleType.Quarterly);
      AssertCycleDerivation(594, 959, CycleType.Quarterly);
      AssertCycleDerivation(595, 960, CycleType.Quarterly);
      AssertCycleDerivation(596, 961, CycleType.Quarterly);
      AssertCycleDerivation(597, 962, CycleType.Quarterly);
      AssertCycleDerivation(598, 963, CycleType.Quarterly);
      AssertCycleDerivation(599, 964, CycleType.Quarterly);
      AssertCycleDerivation(600, 965, CycleType.Quarterly);
      AssertCycleDerivation(601, 966, CycleType.Quarterly);
      AssertCycleDerivation(602, 967, CycleType.Quarterly);
      AssertCycleDerivation(603, 968, CycleType.Quarterly);
      AssertCycleDerivation(604, 969, CycleType.Quarterly);
      AssertCycleDerivation(605, 970, CycleType.Quarterly);
      AssertCycleDerivation(606, 971, CycleType.Quarterly);
      AssertCycleDerivation(607, 972, CycleType.Quarterly);
      AssertCycleDerivation(608, 973, CycleType.Quarterly);
      AssertCycleDerivation(609, 974, CycleType.Quarterly);
      AssertCycleDerivation(610, 975, CycleType.Quarterly);
      AssertCycleDerivation(611, 976, CycleType.Quarterly);
      AssertCycleDerivation(612, 977, CycleType.Quarterly);

      // SemiAnnual starting on Jan 1
      AssertCycleDerivation(520, 978, CycleType.Quarterly);
      AssertCycleDerivation(521, 979, CycleType.Quarterly);
      AssertCycleDerivation(522, 980, CycleType.Quarterly);
      AssertCycleDerivation(523, 981, CycleType.Quarterly);
      AssertCycleDerivation(524, 982, CycleType.Quarterly);
      AssertCycleDerivation(525, 983, CycleType.Quarterly);
      AssertCycleDerivation(526, 984, CycleType.Quarterly);
      AssertCycleDerivation(527, 985, CycleType.Quarterly);
      AssertCycleDerivation(528, 986, CycleType.Quarterly);
      AssertCycleDerivation(529, 987, CycleType.Quarterly);
      AssertCycleDerivation(530, 988, CycleType.Quarterly);
      AssertCycleDerivation(531, 989, CycleType.Quarterly);
      AssertCycleDerivation(532, 990, CycleType.Quarterly);
      AssertCycleDerivation(533, 991, CycleType.Quarterly);
      AssertCycleDerivation(534, 992, CycleType.Quarterly);
      AssertCycleDerivation(535, 993, CycleType.Quarterly);
      AssertCycleDerivation(536, 994, CycleType.Quarterly);
      AssertCycleDerivation(537, 995, CycleType.Quarterly);
      AssertCycleDerivation(538, 996, CycleType.Quarterly);
      AssertCycleDerivation(539, 997, CycleType.Quarterly);
      AssertCycleDerivation(540, 998, CycleType.Quarterly);
      AssertCycleDerivation(541, 999, CycleType.Quarterly);
      AssertCycleDerivation(542, 1000, CycleType.Quarterly);
      AssertCycleDerivation(543, 1001, CycleType.Quarterly);
      AssertCycleDerivation(544, 1002, CycleType.Quarterly);
      AssertCycleDerivation(545, 1003, CycleType.Quarterly);
      AssertCycleDerivation(546, 1004, CycleType.Quarterly);
      AssertCycleDerivation(547, 1005, CycleType.Quarterly);
      AssertCycleDerivation(548, 1006, CycleType.Quarterly);
      AssertCycleDerivation(549, 1007, CycleType.Quarterly);
      AssertCycleDerivation(550, 1008, CycleType.Quarterly);

      // SemiAnnual starting on Feb 1
      AssertCycleDerivation(551, 1009, CycleType.Quarterly);
      AssertCycleDerivation(552, 1010, CycleType.Quarterly);
      AssertCycleDerivation(553, 1011, CycleType.Quarterly);
      AssertCycleDerivation(554, 1012, CycleType.Quarterly);
      AssertCycleDerivation(555, 1013, CycleType.Quarterly);
      AssertCycleDerivation(556, 1014, CycleType.Quarterly);
      AssertCycleDerivation(557, 1015, CycleType.Quarterly);
      AssertCycleDerivation(558, 1016, CycleType.Quarterly);
      AssertCycleDerivation(559, 1017, CycleType.Quarterly);
      AssertCycleDerivation(560, 1018, CycleType.Quarterly);
      AssertCycleDerivation(561, 1019, CycleType.Quarterly);
      AssertCycleDerivation(562, 1020, CycleType.Quarterly);
      AssertCycleDerivation(563, 1021, CycleType.Quarterly);
      AssertCycleDerivation(564, 1022, CycleType.Quarterly);
      AssertCycleDerivation(565, 1023, CycleType.Quarterly);
      AssertCycleDerivation(566, 1024, CycleType.Quarterly);
      AssertCycleDerivation(567, 1025, CycleType.Quarterly);
      AssertCycleDerivation(568, 1026, CycleType.Quarterly);
      AssertCycleDerivation(569, 1027, CycleType.Quarterly);
      AssertCycleDerivation(570, 1028, CycleType.Quarterly);
      AssertCycleDerivation(571, 1029, CycleType.Quarterly);
      AssertCycleDerivation(572, 1030, CycleType.Quarterly);
      AssertCycleDerivation(573, 1031, CycleType.Quarterly);
      AssertCycleDerivation(574, 1032, CycleType.Quarterly);
      AssertCycleDerivation(575, 1033, CycleType.Quarterly);
      AssertCycleDerivation(576, 1034, CycleType.Quarterly);
      AssertCycleDerivation(577, 1035, CycleType.Quarterly);
      AssertCycleDerivation(578, 1036, CycleType.Quarterly);

      // SemiAnnual starting on Mar 1
      AssertCycleDerivation(582, 1037, CycleType.Quarterly);
      AssertCycleDerivation(583, 1038, CycleType.Quarterly);
      AssertCycleDerivation(584, 1039, CycleType.Quarterly);
      AssertCycleDerivation(585, 1040, CycleType.Quarterly);
      AssertCycleDerivation(586, 1041, CycleType.Quarterly);
      AssertCycleDerivation(587, 1042, CycleType.Quarterly);
      AssertCycleDerivation(588, 1043, CycleType.Quarterly);
      AssertCycleDerivation(589, 1044, CycleType.Quarterly);
      AssertCycleDerivation(590, 1045, CycleType.Quarterly);
      AssertCycleDerivation(591, 1046, CycleType.Quarterly);
      AssertCycleDerivation(592, 1047, CycleType.Quarterly);
      AssertCycleDerivation(593, 1048, CycleType.Quarterly);
      AssertCycleDerivation(594, 1049, CycleType.Quarterly);
      AssertCycleDerivation(595, 1050, CycleType.Quarterly);
      AssertCycleDerivation(596, 1051, CycleType.Quarterly);
      AssertCycleDerivation(597, 1052, CycleType.Quarterly);
      AssertCycleDerivation(598, 1053, CycleType.Quarterly);
      AssertCycleDerivation(599, 1054, CycleType.Quarterly);
      AssertCycleDerivation(600, 1055, CycleType.Quarterly);
      AssertCycleDerivation(601, 1056, CycleType.Quarterly);
      AssertCycleDerivation(602, 1057, CycleType.Quarterly);
      AssertCycleDerivation(603, 1058, CycleType.Quarterly);
      AssertCycleDerivation(604, 1059, CycleType.Quarterly);
      AssertCycleDerivation(605, 1060, CycleType.Quarterly);
      AssertCycleDerivation(606, 1061, CycleType.Quarterly);
      AssertCycleDerivation(607, 1062, CycleType.Quarterly);
      AssertCycleDerivation(608, 1063, CycleType.Quarterly);
      AssertCycleDerivation(609, 1064, CycleType.Quarterly);
      AssertCycleDerivation(610, 1065, CycleType.Quarterly);
      AssertCycleDerivation(611, 1066, CycleType.Quarterly);
      AssertCycleDerivation(612, 1067, CycleType.Quarterly);

      // SemiAnnual starting on Apr 1
      AssertCycleDerivation(520, 1068, CycleType.Quarterly);
      AssertCycleDerivation(521, 1069, CycleType.Quarterly);
      AssertCycleDerivation(522, 1070, CycleType.Quarterly);
      AssertCycleDerivation(523, 1071, CycleType.Quarterly);
      AssertCycleDerivation(524, 1072, CycleType.Quarterly);
      AssertCycleDerivation(525, 1073, CycleType.Quarterly);
      AssertCycleDerivation(526, 1074, CycleType.Quarterly);
      AssertCycleDerivation(527, 1075, CycleType.Quarterly);
      AssertCycleDerivation(528, 1076, CycleType.Quarterly);
      AssertCycleDerivation(529, 1077, CycleType.Quarterly);
      AssertCycleDerivation(530, 1078, CycleType.Quarterly);
      AssertCycleDerivation(531, 1079, CycleType.Quarterly);
      AssertCycleDerivation(532, 1080, CycleType.Quarterly);
      AssertCycleDerivation(533, 1081, CycleType.Quarterly);
      AssertCycleDerivation(534, 1082, CycleType.Quarterly);
      AssertCycleDerivation(535, 1083, CycleType.Quarterly);
      AssertCycleDerivation(536, 1084, CycleType.Quarterly);
      AssertCycleDerivation(537, 1085, CycleType.Quarterly);
      AssertCycleDerivation(538, 1086, CycleType.Quarterly);
      AssertCycleDerivation(539, 1087, CycleType.Quarterly);
      AssertCycleDerivation(540, 1088, CycleType.Quarterly);
      AssertCycleDerivation(541, 1089, CycleType.Quarterly);
      AssertCycleDerivation(542, 1090, CycleType.Quarterly);
      AssertCycleDerivation(543, 1091, CycleType.Quarterly);
      AssertCycleDerivation(544, 1092, CycleType.Quarterly);
      AssertCycleDerivation(545, 1093, CycleType.Quarterly);
      AssertCycleDerivation(546, 1094, CycleType.Quarterly);
      AssertCycleDerivation(547, 1095, CycleType.Quarterly);
      AssertCycleDerivation(548, 1096, CycleType.Quarterly);
      AssertCycleDerivation(549, 1097, CycleType.Quarterly);

      // SemiAnnual starting on May 1
      AssertCycleDerivation(551, 1098, CycleType.Quarterly);
      AssertCycleDerivation(552, 1099, CycleType.Quarterly);
      AssertCycleDerivation(553, 1100, CycleType.Quarterly);
      AssertCycleDerivation(554, 1101, CycleType.Quarterly);
      AssertCycleDerivation(555, 1102, CycleType.Quarterly);
      AssertCycleDerivation(556, 1103, CycleType.Quarterly);
      AssertCycleDerivation(557, 1104, CycleType.Quarterly);
      AssertCycleDerivation(558, 1105, CycleType.Quarterly);
      AssertCycleDerivation(559, 1106, CycleType.Quarterly);
      AssertCycleDerivation(560, 1107, CycleType.Quarterly);
      AssertCycleDerivation(561, 1108, CycleType.Quarterly);
      AssertCycleDerivation(562, 1109, CycleType.Quarterly);
      AssertCycleDerivation(563, 1110, CycleType.Quarterly);
      AssertCycleDerivation(564, 1111, CycleType.Quarterly);
      AssertCycleDerivation(565, 1112, CycleType.Quarterly);
      AssertCycleDerivation(566, 1113, CycleType.Quarterly);
      AssertCycleDerivation(567, 1114, CycleType.Quarterly);
      AssertCycleDerivation(568, 1115, CycleType.Quarterly);
      AssertCycleDerivation(569, 1116, CycleType.Quarterly);
      AssertCycleDerivation(570, 1117, CycleType.Quarterly);
      AssertCycleDerivation(571, 1118, CycleType.Quarterly);
      AssertCycleDerivation(572, 1119, CycleType.Quarterly);
      AssertCycleDerivation(573, 1120, CycleType.Quarterly);
      AssertCycleDerivation(574, 1121, CycleType.Quarterly);
      AssertCycleDerivation(575, 1122, CycleType.Quarterly);
      AssertCycleDerivation(576, 1123, CycleType.Quarterly);
      AssertCycleDerivation(577, 1124, CycleType.Quarterly);
      AssertCycleDerivation(578, 1125, CycleType.Quarterly);
      AssertCycleDerivation(579, 1126, CycleType.Quarterly);
      AssertCycleDerivation(580, 1127, CycleType.Quarterly);
      AssertCycleDerivation(581, 1128, CycleType.Quarterly);

      // SemiAnnual starting on Jun 1
      AssertCycleDerivation(582, 1129, CycleType.Quarterly);
      AssertCycleDerivation(583, 1130, CycleType.Quarterly);
      AssertCycleDerivation(584, 1131, CycleType.Quarterly);
      AssertCycleDerivation(585, 1132, CycleType.Quarterly);
      AssertCycleDerivation(586, 1133, CycleType.Quarterly);
      AssertCycleDerivation(587, 1134, CycleType.Quarterly);
      AssertCycleDerivation(588, 1135, CycleType.Quarterly);
      AssertCycleDerivation(589, 1136, CycleType.Quarterly);
      AssertCycleDerivation(590, 1137, CycleType.Quarterly);
      AssertCycleDerivation(591, 1138, CycleType.Quarterly);
      AssertCycleDerivation(592, 1139, CycleType.Quarterly);
      AssertCycleDerivation(593, 1140, CycleType.Quarterly);
      AssertCycleDerivation(594, 1141, CycleType.Quarterly);
      AssertCycleDerivation(595, 1142, CycleType.Quarterly);
      AssertCycleDerivation(596, 1143, CycleType.Quarterly);
      AssertCycleDerivation(597, 1144, CycleType.Quarterly);
      AssertCycleDerivation(598, 1145, CycleType.Quarterly);
      AssertCycleDerivation(599, 1146, CycleType.Quarterly);
      AssertCycleDerivation(600, 1147, CycleType.Quarterly);
      AssertCycleDerivation(601, 1148, CycleType.Quarterly);
      AssertCycleDerivation(602, 1149, CycleType.Quarterly);
      AssertCycleDerivation(603, 1150, CycleType.Quarterly);
      AssertCycleDerivation(604, 1151, CycleType.Quarterly);
      AssertCycleDerivation(605, 1152, CycleType.Quarterly);
      AssertCycleDerivation(606, 1153, CycleType.Quarterly);
      AssertCycleDerivation(607, 1154, CycleType.Quarterly);
      AssertCycleDerivation(608, 1155, CycleType.Quarterly);
      AssertCycleDerivation(609, 1156, CycleType.Quarterly);
      AssertCycleDerivation(610, 1157, CycleType.Quarterly);
      AssertCycleDerivation(611, 1158, CycleType.Quarterly);

      // SemiAnnual starting on Jul 1
      AssertCycleDerivation(520, 1159, CycleType.Quarterly);
      AssertCycleDerivation(521, 1160, CycleType.Quarterly);
      AssertCycleDerivation(522, 1161, CycleType.Quarterly);
      AssertCycleDerivation(523, 1162, CycleType.Quarterly);
      AssertCycleDerivation(524, 1163, CycleType.Quarterly);
      AssertCycleDerivation(525, 1164, CycleType.Quarterly);
      AssertCycleDerivation(526, 1165, CycleType.Quarterly);
      AssertCycleDerivation(527, 1166, CycleType.Quarterly);
      AssertCycleDerivation(528, 1167, CycleType.Quarterly);
      AssertCycleDerivation(529, 1168, CycleType.Quarterly);
      AssertCycleDerivation(530, 1169, CycleType.Quarterly);
      AssertCycleDerivation(531, 1170, CycleType.Quarterly);
      AssertCycleDerivation(532, 1171, CycleType.Quarterly);
      AssertCycleDerivation(533, 1172, CycleType.Quarterly);
      AssertCycleDerivation(534, 1173, CycleType.Quarterly);
      AssertCycleDerivation(535, 1174, CycleType.Quarterly);
      AssertCycleDerivation(536, 1175, CycleType.Quarterly);
      AssertCycleDerivation(537, 1176, CycleType.Quarterly);
      AssertCycleDerivation(538, 1177, CycleType.Quarterly);
      AssertCycleDerivation(539, 1178, CycleType.Quarterly);
      AssertCycleDerivation(540, 1179, CycleType.Quarterly);
      AssertCycleDerivation(541, 1180, CycleType.Quarterly);
      AssertCycleDerivation(542, 1181, CycleType.Quarterly);
      AssertCycleDerivation(543, 1182, CycleType.Quarterly);
      AssertCycleDerivation(544, 1183, CycleType.Quarterly);
      AssertCycleDerivation(545, 1184, CycleType.Quarterly);
      AssertCycleDerivation(546, 1185, CycleType.Quarterly);
      AssertCycleDerivation(547, 1186, CycleType.Quarterly);
      AssertCycleDerivation(548, 1187, CycleType.Quarterly);
      AssertCycleDerivation(549, 1188, CycleType.Quarterly);
      AssertCycleDerivation(550, 1189, CycleType.Quarterly);

      // SemiAnnual starting on Aug 1
      AssertCycleDerivation(551, 1190, CycleType.Quarterly);
      AssertCycleDerivation(552, 1191, CycleType.Quarterly);
      AssertCycleDerivation(553, 1192, CycleType.Quarterly);
      AssertCycleDerivation(554, 1193, CycleType.Quarterly);
      AssertCycleDerivation(555, 1194, CycleType.Quarterly);
      AssertCycleDerivation(556, 1195, CycleType.Quarterly);
      AssertCycleDerivation(557, 1196, CycleType.Quarterly);
      AssertCycleDerivation(558, 1197, CycleType.Quarterly);
      AssertCycleDerivation(559, 1198, CycleType.Quarterly);
      AssertCycleDerivation(560, 1199, CycleType.Quarterly);
      AssertCycleDerivation(561, 1200, CycleType.Quarterly);
      AssertCycleDerivation(562, 1201, CycleType.Quarterly);
      AssertCycleDerivation(563, 1202, CycleType.Quarterly);
      AssertCycleDerivation(564, 1203, CycleType.Quarterly);
      AssertCycleDerivation(565, 1204, CycleType.Quarterly);
      AssertCycleDerivation(566, 1205, CycleType.Quarterly);
      AssertCycleDerivation(567, 1206, CycleType.Quarterly);
      AssertCycleDerivation(568, 1207, CycleType.Quarterly);
      AssertCycleDerivation(569, 1208, CycleType.Quarterly);
      AssertCycleDerivation(570, 1209, CycleType.Quarterly);
      AssertCycleDerivation(571, 1210, CycleType.Quarterly);
      AssertCycleDerivation(572, 1211, CycleType.Quarterly);
      AssertCycleDerivation(573, 1212, CycleType.Quarterly);
      AssertCycleDerivation(574, 1213, CycleType.Quarterly);
      AssertCycleDerivation(575, 1214, CycleType.Quarterly);
      AssertCycleDerivation(576, 1215, CycleType.Quarterly);
      AssertCycleDerivation(577, 1216, CycleType.Quarterly);
      AssertCycleDerivation(578, 1217, CycleType.Quarterly);
      AssertCycleDerivation(579, 1218, CycleType.Quarterly);
      AssertCycleDerivation(580, 1219, CycleType.Quarterly);
      AssertCycleDerivation(581, 1220, CycleType.Quarterly);

      // SemiAnnual starting on Sep 1
      AssertCycleDerivation(582, 1221, CycleType.Quarterly);
      AssertCycleDerivation(583, 1222, CycleType.Quarterly);
      AssertCycleDerivation(584, 1223, CycleType.Quarterly);
      AssertCycleDerivation(585, 1224, CycleType.Quarterly);
      AssertCycleDerivation(586, 1225, CycleType.Quarterly);
      AssertCycleDerivation(587, 1226, CycleType.Quarterly);
      AssertCycleDerivation(588, 1227, CycleType.Quarterly);
      AssertCycleDerivation(589, 1228, CycleType.Quarterly);
      AssertCycleDerivation(590, 1229, CycleType.Quarterly);
      AssertCycleDerivation(591, 1230, CycleType.Quarterly);
      AssertCycleDerivation(592, 1231, CycleType.Quarterly);
      AssertCycleDerivation(593, 1232, CycleType.Quarterly);
      AssertCycleDerivation(594, 1233, CycleType.Quarterly);
      AssertCycleDerivation(595, 1234, CycleType.Quarterly);
      AssertCycleDerivation(596, 1235, CycleType.Quarterly);
      AssertCycleDerivation(597, 1236, CycleType.Quarterly);
      AssertCycleDerivation(598, 1237, CycleType.Quarterly);
      AssertCycleDerivation(599, 1238, CycleType.Quarterly);
      AssertCycleDerivation(600, 1239, CycleType.Quarterly);
      AssertCycleDerivation(601, 1240, CycleType.Quarterly);
      AssertCycleDerivation(602, 1241, CycleType.Quarterly);
      AssertCycleDerivation(603, 1242, CycleType.Quarterly);
      AssertCycleDerivation(604, 1243, CycleType.Quarterly);
      AssertCycleDerivation(605, 1244, CycleType.Quarterly);
      AssertCycleDerivation(606, 1245, CycleType.Quarterly);
      AssertCycleDerivation(607, 1246, CycleType.Quarterly);
      AssertCycleDerivation(608, 1247, CycleType.Quarterly);
      AssertCycleDerivation(609, 1248, CycleType.Quarterly);
      AssertCycleDerivation(610, 1249, CycleType.Quarterly);
      AssertCycleDerivation(611, 1250, CycleType.Quarterly);

      // SemiAnnual starting on Oct 1
      AssertCycleDerivation(520, 1251, CycleType.Quarterly);
      AssertCycleDerivation(521, 1252, CycleType.Quarterly);
      AssertCycleDerivation(522, 1253, CycleType.Quarterly);
      AssertCycleDerivation(523, 1254, CycleType.Quarterly);
      AssertCycleDerivation(524, 1255, CycleType.Quarterly);
      AssertCycleDerivation(525, 1256, CycleType.Quarterly);
      AssertCycleDerivation(526, 1257, CycleType.Quarterly);
      AssertCycleDerivation(527, 1258, CycleType.Quarterly);
      AssertCycleDerivation(528, 1259, CycleType.Quarterly);
      AssertCycleDerivation(529, 1260, CycleType.Quarterly);
      AssertCycleDerivation(530, 1261, CycleType.Quarterly);
      AssertCycleDerivation(531, 1262, CycleType.Quarterly);
      AssertCycleDerivation(532, 1263, CycleType.Quarterly);
      AssertCycleDerivation(533, 1264, CycleType.Quarterly);
      AssertCycleDerivation(534, 1265, CycleType.Quarterly);
      AssertCycleDerivation(535, 1266, CycleType.Quarterly);
      AssertCycleDerivation(536, 1267, CycleType.Quarterly);
      AssertCycleDerivation(537, 1268, CycleType.Quarterly);
      AssertCycleDerivation(538, 1269, CycleType.Quarterly);
      AssertCycleDerivation(539, 1270, CycleType.Quarterly);
      AssertCycleDerivation(540, 1271, CycleType.Quarterly);
      AssertCycleDerivation(541, 1272, CycleType.Quarterly);
      AssertCycleDerivation(542, 1273, CycleType.Quarterly);
      AssertCycleDerivation(543, 1274, CycleType.Quarterly);
      AssertCycleDerivation(544, 1275, CycleType.Quarterly);
      AssertCycleDerivation(545, 1276, CycleType.Quarterly);
      AssertCycleDerivation(546, 1277, CycleType.Quarterly);
      AssertCycleDerivation(547, 1278, CycleType.Quarterly);
      AssertCycleDerivation(548, 1279, CycleType.Quarterly);
      AssertCycleDerivation(549, 1280, CycleType.Quarterly);
      AssertCycleDerivation(550, 1281, CycleType.Quarterly);

      // SemiAnnual starting on Nov 1
      AssertCycleDerivation(551, 1282, CycleType.Quarterly);
      AssertCycleDerivation(552, 1283, CycleType.Quarterly);
      AssertCycleDerivation(553, 1284, CycleType.Quarterly);
      AssertCycleDerivation(554, 1285, CycleType.Quarterly);
      AssertCycleDerivation(555, 1286, CycleType.Quarterly);
      AssertCycleDerivation(556, 1287, CycleType.Quarterly);
      AssertCycleDerivation(557, 1288, CycleType.Quarterly);
      AssertCycleDerivation(558, 1289, CycleType.Quarterly);
      AssertCycleDerivation(559, 1290, CycleType.Quarterly);
      AssertCycleDerivation(560, 1291, CycleType.Quarterly);
      AssertCycleDerivation(561, 1292, CycleType.Quarterly);
      AssertCycleDerivation(562, 1293, CycleType.Quarterly);
      AssertCycleDerivation(563, 1294, CycleType.Quarterly);
      AssertCycleDerivation(564, 1295, CycleType.Quarterly);
      AssertCycleDerivation(565, 1296, CycleType.Quarterly);
      AssertCycleDerivation(566, 1297, CycleType.Quarterly);
      AssertCycleDerivation(567, 1298, CycleType.Quarterly);
      AssertCycleDerivation(568, 1299, CycleType.Quarterly);
      AssertCycleDerivation(569, 1300, CycleType.Quarterly);
      AssertCycleDerivation(570, 1301, CycleType.Quarterly);
      AssertCycleDerivation(571, 1302, CycleType.Quarterly);
      AssertCycleDerivation(572, 1303, CycleType.Quarterly);
      AssertCycleDerivation(573, 1304, CycleType.Quarterly);
      AssertCycleDerivation(574, 1305, CycleType.Quarterly);
      AssertCycleDerivation(575, 1306, CycleType.Quarterly);
      AssertCycleDerivation(576, 1307, CycleType.Quarterly);
      AssertCycleDerivation(577, 1308, CycleType.Quarterly);
      AssertCycleDerivation(578, 1309, CycleType.Quarterly);
      AssertCycleDerivation(579, 1310, CycleType.Quarterly);
      AssertCycleDerivation(580, 1311, CycleType.Quarterly);

      // SemiAnnual starting on Dec 1
      AssertCycleDerivation(582, 1312, CycleType.Quarterly);
      AssertCycleDerivation(583, 1313, CycleType.Quarterly);
      AssertCycleDerivation(584, 1314, CycleType.Quarterly);
      AssertCycleDerivation(585, 1315, CycleType.Quarterly);
      AssertCycleDerivation(586, 1316, CycleType.Quarterly);
      AssertCycleDerivation(587, 1317, CycleType.Quarterly);
      AssertCycleDerivation(588, 1318, CycleType.Quarterly);
      AssertCycleDerivation(589, 1319, CycleType.Quarterly);
      AssertCycleDerivation(590, 1320, CycleType.Quarterly);
      AssertCycleDerivation(591, 1321, CycleType.Quarterly);
      AssertCycleDerivation(592, 1322, CycleType.Quarterly);
      AssertCycleDerivation(593, 1323, CycleType.Quarterly);
      AssertCycleDerivation(594, 1324, CycleType.Quarterly);
      AssertCycleDerivation(595, 1325, CycleType.Quarterly);
      AssertCycleDerivation(596, 1326, CycleType.Quarterly);
      AssertCycleDerivation(597, 1327, CycleType.Quarterly);
      AssertCycleDerivation(598, 1328, CycleType.Quarterly);
      AssertCycleDerivation(599, 1329, CycleType.Quarterly);
      AssertCycleDerivation(600, 1330, CycleType.Quarterly);
      AssertCycleDerivation(601, 1331, CycleType.Quarterly);
      AssertCycleDerivation(602, 1332, CycleType.Quarterly);
      AssertCycleDerivation(603, 1333, CycleType.Quarterly);
      AssertCycleDerivation(604, 1334, CycleType.Quarterly);
      AssertCycleDerivation(605, 1335, CycleType.Quarterly);
      AssertCycleDerivation(606, 1336, CycleType.Quarterly);
      AssertCycleDerivation(607, 1337, CycleType.Quarterly);
      AssertCycleDerivation(608, 1338, CycleType.Quarterly);
      AssertCycleDerivation(609, 1339, CycleType.Quarterly);
      AssertCycleDerivation(610, 1340, CycleType.Quarterly);
      AssertCycleDerivation(611, 1341, CycleType.Quarterly);
      AssertCycleDerivation(612, 1342, CycleType.Quarterly);
    }


		/// <summary>
		/// Tests cycle derivations for Annual EBCR PIs
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T05TestAnnualEBCRCycleDerivations()
		{
			// tests trivial BCR-reduction cases
			for (int cycle = 613; cycle <= 977; cycle++)
				AssertCycleDerivation(cycle, cycle, CycleType.Annual);

			//
			// tests Monthly billing cycles
			//

      // every Monthly cycle with a subscription date starting in Jan
      AssertCycleDerivation(614, 3, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(615, 4, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(616, 5, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(617, 6, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(618, 7, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(619, 8, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(620, 9, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(621, 10, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(622, 11, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(623, 12, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(624, 13, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(625, 14, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(626, 15, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(627, 16, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(628, 17, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(629, 18, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(630, 19, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(631, 20, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(632, 21, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(633, 22, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(634, 23, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(635, 24, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(636, 25, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(637, 26, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(638, 27, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(639, 28, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(640, 29, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(641, 30, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(642, 31, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(643, 32, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);
      AssertCycleDerivation(644, 33, GenerateRandomDateTimeWithMonth(1), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Feb
      AssertCycleDerivation(645, 3, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(646, 4, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(647, 5, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(648, 6, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(649, 7, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(650, 8, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(651, 9, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(652, 10, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(653, 11, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(654, 12, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(655, 13, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(656, 14, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(657, 15, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(658, 16, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(659, 17, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(660, 18, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(661, 19, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(662, 20, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(663, 21, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(664, 22, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(665, 23, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(666, 24, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(667, 25, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(668, 26, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(669, 27, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(670, 28, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(671, 29, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);
      AssertCycleDerivation(672, 30, GenerateRandomDateTimeWithMonth(2), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Mar
      AssertCycleDerivation(673, 3, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(674, 4, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(675, 5, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(676, 6, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(677, 7, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(678, 8, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(679, 9, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(680, 10, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(681, 11, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(682, 12, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(683, 13, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(684, 14, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(685, 15, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(686, 16, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(687, 17, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(688, 18, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(689, 19, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(690, 20, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(691, 21, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(692, 22, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(693, 23, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(694, 24, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(695, 25, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(696, 26, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(697, 27, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(698, 28, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(699, 29, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(700, 30, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(701, 31, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(702, 32, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);
      AssertCycleDerivation(703, 33, GenerateRandomDateTimeWithMonth(3), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Apr
      AssertCycleDerivation(704, 3, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(705, 4, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(706, 5, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(707, 6, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(708, 7, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(709, 8, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(710, 9, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(711, 10, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(712, 11, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(713, 12, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(714, 13, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(715, 14, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(716, 15, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(717, 16, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(718, 17, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(719, 18, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(720, 19, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(721, 20, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(722, 21, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(723, 22, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(724, 23, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(725, 24, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(726, 25, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(727, 26, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(728, 27, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(729, 28, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(730, 29, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(731, 30, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(732, 31, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);
      AssertCycleDerivation(733, 32, GenerateRandomDateTimeWithMonth(4), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in May
      AssertCycleDerivation(734, 3, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(735, 4, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(736, 5, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(737, 6, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(738, 7, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(739, 8, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(740, 9, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(741, 10, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(742, 11, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(743, 12, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(744, 13, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(745, 14, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(746, 15, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(747, 16, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(748, 17, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(749, 18, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(750, 19, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(751, 20, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(752, 21, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(753, 22, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(754, 23, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(755, 24, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(756, 25, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(757, 26, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(758, 27, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(759, 28, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(760, 29, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(761, 30, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(762, 31, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(763, 32, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);
      AssertCycleDerivation(764, 33, GenerateRandomDateTimeWithMonth(5), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Jun
      AssertCycleDerivation(765, 3, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(766, 4, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(767, 5, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(768, 6, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(769, 7, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(770, 8, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(771, 9, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(772, 10, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(773, 11, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(774, 12, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(775, 13, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(776, 14, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(777, 15, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(778, 16, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(779, 17, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(780, 18, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(781, 19, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(782, 20, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(783, 21, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(784, 22, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(785, 23, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(786, 24, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(787, 25, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(788, 26, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(789, 27, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(790, 28, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(791, 29, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(792, 30, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(793, 31, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);
      AssertCycleDerivation(794, 32, GenerateRandomDateTimeWithMonth(6), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Jul
      AssertCycleDerivation(795, 3, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(796, 4, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(797, 5, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(798, 6, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(799, 7, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(800, 8, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(801, 9, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(802, 10, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(803, 11, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(804, 12, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(805, 13, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(806, 14, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(807, 15, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(808, 16, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(809, 17, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(810, 18, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(811, 19, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(812, 20, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(813, 21, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(814, 22, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(815, 23, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(816, 24, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(817, 25, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(818, 26, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(819, 27, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(820, 28, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(821, 29, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(822, 30, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(823, 31, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(824, 32, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);
      AssertCycleDerivation(825, 33, GenerateRandomDateTimeWithMonth(7), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Aug
      AssertCycleDerivation(826, 3, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(827, 4, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(828, 5, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(829, 6, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(830, 7, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(831, 8, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(832, 9, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(833, 10, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(834, 11, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(835, 12, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(836, 13, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(837, 14, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(838, 15, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(839, 16, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(840, 17, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(841, 18, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(842, 19, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(843, 20, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(844, 21, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(845, 22, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(846, 23, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(847, 24, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(848, 25, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(849, 26, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(850, 27, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(851, 28, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(852, 29, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(853, 30, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(854, 31, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(855, 32, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);
      AssertCycleDerivation(856, 33, GenerateRandomDateTimeWithMonth(8), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Sep
      AssertCycleDerivation(857, 3, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(858, 4, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(859, 5, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(860, 6, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(861, 7, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(862, 8, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(863, 9, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(864, 10, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(865, 11, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(866, 12, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(867, 13, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(868, 14, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(869, 15, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(870, 16, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(871, 17, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(872, 18, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(873, 19, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(874, 20, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(875, 21, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(876, 22, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(877, 23, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(878, 24, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(879, 25, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(880, 26, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(881, 27, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(882, 28, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(883, 29, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(884, 30, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(885, 31, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);
      AssertCycleDerivation(886, 32, GenerateRandomDateTimeWithMonth(9), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Oct
      AssertCycleDerivation(887, 3, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(888, 4, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(889, 5, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(890, 6, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(891, 7, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(892, 8, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(893, 9, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(894, 10, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(895, 11, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(896, 12, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(897, 13, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(898, 14, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(899, 15, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(900, 16, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(901, 17, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(902, 18, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(903, 19, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(904, 20, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(905, 21, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(906, 22, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(907, 23, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(908, 24, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(909, 25, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(910, 26, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(911, 27, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(912, 28, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(913, 29, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(914, 30, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(915, 31, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(916, 32, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);
      AssertCycleDerivation(917, 33, GenerateRandomDateTimeWithMonth(10), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Nov
      AssertCycleDerivation(918, 3, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(919, 4, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(920, 5, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(921, 6, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(922, 7, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(923, 8, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(924, 9, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(925, 10, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(926, 11, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(927, 12, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(928, 13, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(929, 14, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(930, 15, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(931, 16, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(932, 17, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(933, 18, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(934, 19, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(935, 20, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(936, 21, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(937, 22, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(938, 23, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(939, 24, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(940, 25, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(941, 26, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(942, 27, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(943, 28, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(944, 29, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(945, 30, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(946, 31, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);
      AssertCycleDerivation(947, 32, GenerateRandomDateTimeWithMonth(11), CycleType.Annual);

      // every Monthly cycle with a subscription date starting in Dec
      AssertCycleDerivation(948, 3, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(949, 4, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(950, 5, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(951, 6, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(952, 7, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(953, 8, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(954, 9, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(955, 10, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(956, 11, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(957, 12, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(958, 13, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(959, 14, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(960, 15, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(961, 16, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(962, 17, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(963, 18, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(964, 19, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(965, 20, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(966, 21, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(967, 22, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(968, 23, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(969, 24, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(970, 25, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(971, 26, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(972, 27, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(973, 28, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(974, 29, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(975, 30, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(976, 31, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(977, 32, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);
      AssertCycleDerivation(613, 33, GenerateRandomDateTimeWithMonth(12), CycleType.Annual);


			//
			// tests Quarterly billing cycles
			//

      //  Quarterly starting in month 1
      AssertCycleDerivation(613, 520, CycleType.Annual);
      AssertCycleDerivation(614, 521, CycleType.Annual);
      AssertCycleDerivation(615, 522, CycleType.Annual);
      AssertCycleDerivation(616, 523, CycleType.Annual);
      AssertCycleDerivation(617, 524, CycleType.Annual);
      AssertCycleDerivation(618, 525, CycleType.Annual);
      AssertCycleDerivation(619, 526, CycleType.Annual);
      AssertCycleDerivation(620, 527, CycleType.Annual);
      AssertCycleDerivation(621, 528, CycleType.Annual);
      AssertCycleDerivation(622, 529, CycleType.Annual);
      AssertCycleDerivation(623, 530, CycleType.Annual);
      AssertCycleDerivation(624, 531, CycleType.Annual);
      AssertCycleDerivation(625, 532, CycleType.Annual);
      AssertCycleDerivation(626, 533, CycleType.Annual);
      AssertCycleDerivation(627, 534, CycleType.Annual);
      AssertCycleDerivation(628, 535, CycleType.Annual);
      AssertCycleDerivation(629, 536, CycleType.Annual);
      AssertCycleDerivation(630, 537, CycleType.Annual);
      AssertCycleDerivation(631, 538, CycleType.Annual);
      AssertCycleDerivation(632, 539, CycleType.Annual);
      AssertCycleDerivation(633, 540, CycleType.Annual);
      AssertCycleDerivation(634, 541, CycleType.Annual);
      AssertCycleDerivation(635, 542, CycleType.Annual);
      AssertCycleDerivation(636, 543, CycleType.Annual);
      AssertCycleDerivation(637, 544, CycleType.Annual);
      AssertCycleDerivation(638, 545, CycleType.Annual);
      AssertCycleDerivation(639, 546, CycleType.Annual);
      AssertCycleDerivation(640, 547, CycleType.Annual);
      AssertCycleDerivation(641, 548, CycleType.Annual);
      AssertCycleDerivation(642, 549, CycleType.Annual);
      AssertCycleDerivation(643, 550, CycleType.Annual);

      //  Quarterly starting in month 2
      AssertCycleDerivation(644, 551, CycleType.Annual);
      AssertCycleDerivation(645, 552, CycleType.Annual);
      AssertCycleDerivation(646, 553, CycleType.Annual);
      AssertCycleDerivation(647, 554, CycleType.Annual);
      AssertCycleDerivation(648, 555, CycleType.Annual);
      AssertCycleDerivation(649, 556, CycleType.Annual);
      AssertCycleDerivation(650, 557, CycleType.Annual);
      AssertCycleDerivation(651, 558, CycleType.Annual);
      AssertCycleDerivation(652, 559, CycleType.Annual);
      AssertCycleDerivation(653, 560, CycleType.Annual);
      AssertCycleDerivation(654, 561, CycleType.Annual);
      AssertCycleDerivation(655, 562, CycleType.Annual);
      AssertCycleDerivation(656, 563, CycleType.Annual);
      AssertCycleDerivation(657, 564, CycleType.Annual);
      AssertCycleDerivation(658, 565, CycleType.Annual);
      AssertCycleDerivation(659, 566, CycleType.Annual);
      AssertCycleDerivation(660, 567, CycleType.Annual);
      AssertCycleDerivation(661, 568, CycleType.Annual);
      AssertCycleDerivation(662, 569, CycleType.Annual);
      AssertCycleDerivation(663, 570, CycleType.Annual);
      AssertCycleDerivation(664, 571, CycleType.Annual);
      AssertCycleDerivation(665, 572, CycleType.Annual);
      AssertCycleDerivation(666, 573, CycleType.Annual);
      AssertCycleDerivation(667, 574, CycleType.Annual);
      AssertCycleDerivation(668, 575, CycleType.Annual);
      AssertCycleDerivation(669, 576, CycleType.Annual);
      AssertCycleDerivation(670, 577, CycleType.Annual);
      AssertCycleDerivation(671, 578, CycleType.Annual);
      AssertCycleDerivation(671, 579, CycleType.Annual);
      AssertCycleDerivation(671, 580, CycleType.Annual);
      AssertCycleDerivation(671, 581, CycleType.Annual);

      //  Quarterly starting in month 3
      AssertCycleDerivation(672, 582, CycleType.Annual);
      AssertCycleDerivation(673, 583, CycleType.Annual);
      AssertCycleDerivation(674, 584, CycleType.Annual);
      AssertCycleDerivation(675, 585, CycleType.Annual);
      AssertCycleDerivation(676, 586, CycleType.Annual);
      AssertCycleDerivation(677, 587, CycleType.Annual);
      AssertCycleDerivation(678, 588, CycleType.Annual);
      AssertCycleDerivation(679, 589, CycleType.Annual);
      AssertCycleDerivation(680, 590, CycleType.Annual);
      AssertCycleDerivation(681, 591, CycleType.Annual);
      AssertCycleDerivation(682, 592, CycleType.Annual);
      AssertCycleDerivation(683, 593, CycleType.Annual);
      AssertCycleDerivation(684, 594, CycleType.Annual);
      AssertCycleDerivation(685, 595, CycleType.Annual);
      AssertCycleDerivation(686, 596, CycleType.Annual);
      AssertCycleDerivation(687, 597, CycleType.Annual);
      AssertCycleDerivation(688, 598, CycleType.Annual);
      AssertCycleDerivation(689, 599, CycleType.Annual);
      AssertCycleDerivation(690, 600, CycleType.Annual);
      AssertCycleDerivation(691, 601, CycleType.Annual);
      AssertCycleDerivation(692, 602, CycleType.Annual);
      AssertCycleDerivation(693, 603, CycleType.Annual);
      AssertCycleDerivation(694, 604, CycleType.Annual);
      AssertCycleDerivation(695, 605, CycleType.Annual);
      AssertCycleDerivation(696, 606, CycleType.Annual);
      AssertCycleDerivation(697, 607, CycleType.Annual);
      AssertCycleDerivation(698, 608, CycleType.Annual);
      AssertCycleDerivation(699, 609, CycleType.Annual);
      AssertCycleDerivation(700, 610, CycleType.Annual);
      AssertCycleDerivation(701, 611, CycleType.Annual);
      AssertCycleDerivation(702, 612, CycleType.Annual);

      // tests semiAnnual cases
      for (int cycle = 613; cycle <= 977; cycle++)
        AssertCycleDerivation(cycle, cycle+365, CycleType.Annual);

			Console.WriteLine("\nTests {0}", mComparisons);
		}

    		/// <summary>
		/// Tests cycle derivations for SemiAnnual EBCR PIs
		/// </summary>
    [Test]
    public void T06TestSemiAnnualEBCRCycleDerivations()
    {
      // tests trivial BCR-reduction cases
      for (int cycle = 978; cycle <= 1342; cycle++)
        AssertCycleDerivation(cycle, cycle, CycleType.SemiAnnual);

            // every Monthly cycle with a subscription date starting in Jan,
      AssertCycleDerivation(979,3, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(980,4, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(981,5, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(982,6, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(983,7, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(984,8, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(985,9, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(986,10, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(987,11, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(988,12, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(989,13, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(990,14, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(991,15, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(992,16, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(993,17, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(994,18, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(995,19, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(996,20, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(997,21, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(998,22, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(999,23, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1000,24, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1001,25, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1002,26, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1003,27, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1004,28, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1005,29, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1006,30, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1007,31, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1008,32, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);
      AssertCycleDerivation(1009,33, GenerateRandomDateTimeWithMonth(1), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Feb,
      AssertCycleDerivation(1010,3, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1011,4, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1012,5, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1013,6, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1014,7, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1015,8, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1016,9, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1017,10, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1018,11, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1019,12, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1020,13, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1021,14, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1022,15, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1023,16, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1024,17, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1025,18, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1026,19, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1027,20, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1028,21, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1029,22, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1030,23, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1031,24, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1032,25, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1033,26, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1034,27, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1035,28, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1036,29, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      AssertCycleDerivation(1037,30, GenerateRandomDateTimeWithMonth(2), CycleType.SemiAnnual);
      // every Monthly cycle with a subscription date starting in Mar,
      AssertCycleDerivation(1038,3, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1039,4, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1040,5, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1041,6, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1042,7, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1043,8, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1044,9, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1045,10, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1046,11, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1047,12, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1048,13, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1049,14, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1050,15, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1051,16, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1052,17, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1053,18, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1054,19, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1055,20, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1056,21, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1057,22, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1058,23, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1059,24, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1060,25, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1061,26, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1062,27, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1063,28, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1064,29, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1065,30, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1066,31, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1067,32, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);
      AssertCycleDerivation(1068,33, GenerateRandomDateTimeWithMonth(3), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Apr,
      AssertCycleDerivation(1069,3, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1070,4, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1071,5, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1072,6, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1073,7, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1074,8, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1075,9, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1076,10, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1077,11, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1078,12, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1079,13, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1080,14, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1081,15, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1082,16, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1083,17, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1084,18, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1085,19, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1086,20, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1087,21, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1088,22, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1089,23, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1090,24, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1091,25, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1092,26, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1093,27, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1094,28, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1095,29, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1096,30, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1097,31, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);
      AssertCycleDerivation(1098,32, GenerateRandomDateTimeWithMonth(4), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in May,
      AssertCycleDerivation(1099,3, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1100,4, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1101,5, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1102,6, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1103,7, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1104,8, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1105,9, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1106,10, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1107,11, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1108,12, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1109,13, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1110,14, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1111,15, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1112,16, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1113,17, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1114,18, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1115,19, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1116,20, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1117,21, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1118,22, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1119,23, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1120,24, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1121,25, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1122,26, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1123,27, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1124,28, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1125,29, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1126,30, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1127,31, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1128,32, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);
      AssertCycleDerivation(1129,33, GenerateRandomDateTimeWithMonth(5), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Jun,
      AssertCycleDerivation(1130,3, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1131,4, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1132,5, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1133,6, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1134,7, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1135,8, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1136,9, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1137,10, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1138,11, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1139,12, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1140,13, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1141,14, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1142,15, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1143,16, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1144,17, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1145,18, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1146,19, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1147,20, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1148,21, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1149,22, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1150,23, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1151,24, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1152,25, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1153,26, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1154,27, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1155,28, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1156,29, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1157,30, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1158,31, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);
      AssertCycleDerivation(1159,32, GenerateRandomDateTimeWithMonth(6), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Jul,
      AssertCycleDerivation(1160,3, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1161,4, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1162,5, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1163,6, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1164,7, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1165,8, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1166,9, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1167,10, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1168,11, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1169,12, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1170,13, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1171,14, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1172,15, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1173,16, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1174,17, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1175,18, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1176,19, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1177,20, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1178,21, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1179,22, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1180,23, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1181,24, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1182,25, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1183,26, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1184,27, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1185,28, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1186,29, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1187,30, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1188,31, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1189,32, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);
      AssertCycleDerivation(1190,33, GenerateRandomDateTimeWithMonth(7), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Aug,
      AssertCycleDerivation(1191,3, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1192,4, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1193,5, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1194,6, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1195,7, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1196,8, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1197,9, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1198,10, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1199,11, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1200,12, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1201,13, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1202,14, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1203,15, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1204,16, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1205,17, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1206,18, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1207,19, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1208,20, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1209,21, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1210,22, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1211,23, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1212,24, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1213,25, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1214,26, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1215,27, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1216,28, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1217,29, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1218,30, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1219,31, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1220,32, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);
      AssertCycleDerivation(1221,33, GenerateRandomDateTimeWithMonth(8), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Sep,
      AssertCycleDerivation(1222,3, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1223,4, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1224,5, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1225,6, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1226,7, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1227,8, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1228,9, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1229,10, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1230,11, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1231,12, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1232,13, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1233,14, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1234,15, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1235,16, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1236,17, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1237,18, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1238,19, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1239,20, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1240,21, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1241,22, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1242,23, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1243,24, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1244,25, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1245,26, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1246,27, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1247,28, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1248,29, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1249,30, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1250,31, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);
      AssertCycleDerivation(1251,32, GenerateRandomDateTimeWithMonth(9), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Oct,
      AssertCycleDerivation(1252,3, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1253,4, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1254,5, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1255,6, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1256,7, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1257,8, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1258,9, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1259,10, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1260,11, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1261,12, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1262,13, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1263,14, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1264,15, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1265,16, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1266,17, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1267,18, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1268,19, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1269,20, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1270,21, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1271,22, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1272,23, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1273,24, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1274,25, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1275,26, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1276,27, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1277,28, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1278,29, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1279,30, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1280,31, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1281,32, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);
      AssertCycleDerivation(1282,33, GenerateRandomDateTimeWithMonth(10), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Nov,
      AssertCycleDerivation(1283,3, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1284,4, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1285,5, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1286,6, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1287,7, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1288,8, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1289,9, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1290,10, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1291,11, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1292,12, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1293,13, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1294,14, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1295,15, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1296,16, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1297,17, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1298,18, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1299,19, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1300,20, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1301,21, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1302,22, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1303,23, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1304,24, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1305,25, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1306,26, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1307,27, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1308,28, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1309,29, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1310,30, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1311,31, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);
      AssertCycleDerivation(1312,32, GenerateRandomDateTimeWithMonth(11), CycleType.SemiAnnual);

      // every Monthly cycle with a subscription date starting in Dec,
      AssertCycleDerivation(1313,3, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1314,4, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1315,5, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1316,6, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1317,7, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1318,8, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1319,9, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1320,10, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1321,11, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1322,12, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1323,13, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1324,14, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1325,15, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1326,16, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1327,17, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1328,18, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1329,19, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1330,20, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1331,21, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1332,22, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1333,23, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1334,24, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1335,25, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1336,26, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1337,27, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1338,28, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1339,29, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1340,30, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1341,31, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(1342,32, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);
      AssertCycleDerivation(978,33, GenerateRandomDateTimeWithMonth(12), CycleType.SemiAnnual);

      //
      // tests Quarterly billing cycles
      //

      //  Quarterly starting in month 1
      AssertCycleDerivation(978, 520, CycleType.SemiAnnual);
      AssertCycleDerivation(979, 521, CycleType.SemiAnnual);
      AssertCycleDerivation(980, 522, CycleType.SemiAnnual);
      AssertCycleDerivation(981, 523, CycleType.SemiAnnual);
      AssertCycleDerivation(982, 524, CycleType.SemiAnnual);
      AssertCycleDerivation(983, 525, CycleType.SemiAnnual);
      AssertCycleDerivation(984, 526, CycleType.SemiAnnual);
      AssertCycleDerivation(985, 527, CycleType.SemiAnnual);
      AssertCycleDerivation(986, 528, CycleType.SemiAnnual);
      AssertCycleDerivation(987, 529, CycleType.SemiAnnual);
      AssertCycleDerivation(988, 530, CycleType.SemiAnnual);
      AssertCycleDerivation(989, 531, CycleType.SemiAnnual);
      AssertCycleDerivation(990, 532, CycleType.SemiAnnual);
      AssertCycleDerivation(991, 533, CycleType.SemiAnnual);
      AssertCycleDerivation(992, 534, CycleType.SemiAnnual);
      AssertCycleDerivation(993, 535, CycleType.SemiAnnual);
      AssertCycleDerivation(994, 536, CycleType.SemiAnnual);
      AssertCycleDerivation(995, 537, CycleType.SemiAnnual);
      AssertCycleDerivation(996, 538, CycleType.SemiAnnual);
      AssertCycleDerivation(997, 539, CycleType.SemiAnnual);
      AssertCycleDerivation(998, 540, CycleType.SemiAnnual);
      AssertCycleDerivation(999, 541, CycleType.SemiAnnual);
      AssertCycleDerivation(1000, 542, CycleType.SemiAnnual);
      AssertCycleDerivation(1001, 543, CycleType.SemiAnnual);
      AssertCycleDerivation(1002, 544, CycleType.SemiAnnual);
      AssertCycleDerivation(1003, 545, CycleType.SemiAnnual);
      AssertCycleDerivation(1004, 546, CycleType.SemiAnnual);
      AssertCycleDerivation(1005, 547, CycleType.SemiAnnual);
      AssertCycleDerivation(1006, 548, CycleType.SemiAnnual);
      AssertCycleDerivation(1007, 549, CycleType.SemiAnnual);
      AssertCycleDerivation(1008, 550, CycleType.SemiAnnual);

      //  Quarterly starting in month 2
      AssertCycleDerivation(1009, 551, CycleType.SemiAnnual);
      AssertCycleDerivation(1010, 552, CycleType.SemiAnnual);
      AssertCycleDerivation(1011, 553, CycleType.SemiAnnual);
      AssertCycleDerivation(1012, 554, CycleType.SemiAnnual);
      AssertCycleDerivation(1013, 555, CycleType.SemiAnnual);
      AssertCycleDerivation(1014, 556, CycleType.SemiAnnual);
      AssertCycleDerivation(1015, 557, CycleType.SemiAnnual);
      AssertCycleDerivation(1016, 558, CycleType.SemiAnnual);
      AssertCycleDerivation(1017, 559, CycleType.SemiAnnual);
      AssertCycleDerivation(1018, 560, CycleType.SemiAnnual);
      AssertCycleDerivation(1019, 561, CycleType.SemiAnnual);
      AssertCycleDerivation(1020, 562, CycleType.SemiAnnual);
      AssertCycleDerivation(1021, 563, CycleType.SemiAnnual);
      AssertCycleDerivation(1022, 564, CycleType.SemiAnnual);
      AssertCycleDerivation(1023, 565, CycleType.SemiAnnual);
      AssertCycleDerivation(1024, 566, CycleType.SemiAnnual);
      AssertCycleDerivation(1025, 567, CycleType.SemiAnnual);
      AssertCycleDerivation(1026, 568, CycleType.SemiAnnual);
      AssertCycleDerivation(1027, 569, CycleType.SemiAnnual);
      AssertCycleDerivation(1028, 570, CycleType.SemiAnnual);
      AssertCycleDerivation(1029, 571, CycleType.SemiAnnual);
      AssertCycleDerivation(1030, 572, CycleType.SemiAnnual);
      AssertCycleDerivation(1031, 573, CycleType.SemiAnnual);
      AssertCycleDerivation(1032, 574, CycleType.SemiAnnual);
      AssertCycleDerivation(1033, 575, CycleType.SemiAnnual);
      AssertCycleDerivation(1034, 576, CycleType.SemiAnnual);
      AssertCycleDerivation(1035, 577, CycleType.SemiAnnual);
      AssertCycleDerivation(1036, 578, CycleType.SemiAnnual);
      AssertCycleDerivation(1036, 579, CycleType.SemiAnnual);
      AssertCycleDerivation(1036, 580, CycleType.SemiAnnual);
      AssertCycleDerivation(1036, 581, CycleType.SemiAnnual);

      //  Quarterly starting in month 3
      AssertCycleDerivation(1037, 582, CycleType.SemiAnnual);
      AssertCycleDerivation(1038, 583, CycleType.SemiAnnual);
      AssertCycleDerivation(1039, 584, CycleType.SemiAnnual);
      AssertCycleDerivation(1040, 585, CycleType.SemiAnnual);
      AssertCycleDerivation(1041, 586, CycleType.SemiAnnual);
      AssertCycleDerivation(1042, 587, CycleType.SemiAnnual);
      AssertCycleDerivation(1043, 588, CycleType.SemiAnnual);
      AssertCycleDerivation(1044, 589, CycleType.SemiAnnual);
      AssertCycleDerivation(1045, 590, CycleType.SemiAnnual);
      AssertCycleDerivation(1046, 591, CycleType.SemiAnnual);
      AssertCycleDerivation(1047, 592, CycleType.SemiAnnual);
      AssertCycleDerivation(1048, 593, CycleType.SemiAnnual);
      AssertCycleDerivation(1049, 594, CycleType.SemiAnnual);
      AssertCycleDerivation(1050, 595, CycleType.SemiAnnual);
      AssertCycleDerivation(1051, 596, CycleType.SemiAnnual);
      AssertCycleDerivation(1052, 597, CycleType.SemiAnnual);
      AssertCycleDerivation(1053, 598, CycleType.SemiAnnual);
      AssertCycleDerivation(1054, 599, CycleType.SemiAnnual);
      AssertCycleDerivation(1055, 600, CycleType.SemiAnnual);
      AssertCycleDerivation(1056, 601, CycleType.SemiAnnual);
      AssertCycleDerivation(1057, 602, CycleType.SemiAnnual);
      AssertCycleDerivation(1058, 603, CycleType.SemiAnnual);
      AssertCycleDerivation(1059, 604, CycleType.SemiAnnual);
      AssertCycleDerivation(1060, 605, CycleType.SemiAnnual);
      AssertCycleDerivation(1061, 606, CycleType.SemiAnnual);
      AssertCycleDerivation(1062, 607, CycleType.SemiAnnual);
      AssertCycleDerivation(1063, 608, CycleType.SemiAnnual);
      AssertCycleDerivation(1064, 609, CycleType.SemiAnnual);
      AssertCycleDerivation(1065, 610, CycleType.SemiAnnual);
      AssertCycleDerivation(1066, 611, CycleType.SemiAnnual);
      AssertCycleDerivation(1067, 612, CycleType.SemiAnnual);

      // tests annual cases
      for (int cycle = 978; cycle <= 1342; cycle++)
        AssertCycleDerivation(cycle, cycle - 365, CycleType.SemiAnnual);

    }

		/// <summary>
		/// Computes the derived EBCR cycle based on an account's usage cycle and the
		/// PI's EBCR cycle type.
		/// </summary>
		private int DeriveEBCRCycle(int usageCycleID, DateTime subscriptionStart, CycleType ebcrCycleType)
		{
			int cycle;
			string subStartDate = string.Format("'{0}'", 
				subscriptionStart.ToString()); // ok for mssql
			string fromDual = "";

			ConnectionInfo ci = new ConnectionInfo("NetMeter");
			if (ci.DatabaseType == DBType.Oracle)
			{
				subStartDate = string.Format(" to_date('{0}', 'MM/DD/YYYY HH:MI:SS AM')",
					subscriptionStart.ToString());
				fromDual = "from dual ";
			}


            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                string query = String.Format("SELECT dbo.DeriveEBCRCycle({0}, {1}, {2}) {3}",
                                                                         usageCycleID,
                    subStartDate,
                                                                         (int)ebcrCycleType,
                    fromDual);

                using (IMTStatement stmt = conn.CreateStatement(query))
                {

                    // TODO: MetraTech.DataAccess is missing ExecuteScalar
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        reader.Read();
                        cycle = reader.GetInt32(0);
                    }
                }
            }
			
			return cycle;
		}

		/// <summary>
		/// Generates a reasonable random DateTime between Jan 1, 2000 and Dec 31, 2020
		/// </summary>
		private DateTime GenerateRandomDateTime()
		{
			int month = mRandom.Next(1, 12);
			return GenerateRandomDateTimeWithMonth(month);
		}

		private DateTime GenerateRandomDateTimeWithMonth(int month)
		{
			int year = mRandom.Next(2000, 2020);
			int day = mRandom.Next(1, DateTime.DaysInMonth(year, month));
			int hour = mRandom.Next(0, 23);
			int minute = mRandom.Next(0, 59);
			int second = mRandom.Next(0,59);

			return new DateTime(year, month, day, hour, minute, second);
		}


		/// <summary>
		/// Derives EBCR cycle and asserts that the cycle ID matches the expected.
		/// Displays a custom assertion failed message that uniquely identifies the test case.
		/// </summary>
		private void AssertCycleDerivation(int expectedCycleID, int usageCycleID, DateTime subStart, CycleType ebcrCycleType)
		{
			int derivedCycleID = DeriveEBCRCycle(usageCycleID, subStart, ebcrCycleType);
			
			if (expectedCycleID != derivedCycleID)
			{
				string msg = String.Format("DeriveEBCRCycle({0}, '{1}', {2}) yielded <{3}> however <{4}> was expected!",
																	 usageCycleID, subStart, ebcrCycleType, derivedCycleID, expectedCycleID);
				Assert.Fail(msg);
			}

			mComparisons++;
		}


		/// <summary>
		/// Derives EBCR cycle and asserts that the cycle ID matches the expected.
		/// This method is used when the subscription start date should not factor
		/// into the derivation. A random subscription start date is generated and
		/// passed to the UDF to validate that there is no dependence.
		/// </summary>
		private void AssertCycleDerivation(int expectedCycleID, int usageCycleID, CycleType ebcrCycleType)
		{
			AssertCycleDerivation(expectedCycleID, usageCycleID, GenerateRandomDateTime(), ebcrCycleType);
		}

		Random mRandom = new Random((int) DateTime.Now.Ticks);
		int mComparisons;
	}
}
