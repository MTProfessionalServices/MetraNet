using System;
using MetraTech.Interop.MTProductCatalog;
using System.Runtime.InteropServices;

namespace MetraTech.Adjustments
{
	/// <summary>
	/// Summary description for AdjustmentException.
	/// </summary>
	/// 
  [ComVisible(false)]
  public class AdjustmentException : ApplicationException
  {
    public AdjustmentException(string msg) : base(msg)
    {
      //
      // TODO: Add constructor logic here
      //
    }
  }
  /// <summary>
  /// Summary description for AdjustmentUserException.
  /// Exceptions of this type are usually not critical and do not get bubbled up
  /// to a client. They are normally used to populate a warnings rowset
  /// </summary>
  /// 
  [ComVisible(false)]
  public class AdjustmentUserException : AdjustmentException
  {
    public AdjustmentUserException(string msg) : base(msg)
    {
      //
      // TODO: Add constructor logic here
      //
    }
  }

  [ComVisible(false)]
  public class AdjustmentStateTransitionException : AdjustmentUserException
  {
    public AdjustmentStateTransitionException(string msg) : base(msg) 
    {}
  }

  [ComVisible(false)]
  public class InvalidApplicabilityRule : AdjustmentException
  {
    public InvalidApplicabilityRule(string rule) 
      : base(System.String.Format("Applicability Rule {0} calculation formula is missing 'IsApplicable' BOOLEAN OUTPUT parameter", rule))
    {}
  }

  [ComVisible(false)]
  public class InvalidAdjustmentFormulaException : AdjustmentException
  {
    public InvalidAdjustmentFormulaException(string msg) 
      : base(msg)
    {}
  }

  [ComVisible(false)]
  public class TotalAdjustmentAmountException : AdjustmentException
  {
    public TotalAdjustmentAmountException(decimal am1, decimal am2) 
      : base(String.Format(@"TotalAdjustmentAmount output property has to be a sum" + 
        " of all charge based output properties: Charge Total: {0} != TotalAdjustmentAmount: {1}", am1, am2))
    {}
  }

	[ComVisible(false)]
	public class AdjustmentZeroAmountException : AdjustmentException
	{
		public AdjustmentZeroAmountException(long idsess) 
			: base(string.Format(@"Adjustment amount for Session <{0}> is 0, adjustment will not be saved.", idsess))
			
		{}
	}

	

  [ComVisible(false)]
  public class SecondPrebillAdjustmentException : AdjustmentUserException
  {
    public SecondPrebillAdjustmentException(long idsess) 
      : base(System.String.Format("Session <{0}> can not be prebill adjusted second time, delete adjustments first.", idsess) )
    {}

  }
  [ComVisible(false)]
  public class SecondPostbillAdjustmentException : AdjustmentUserException
  {
    public SecondPostbillAdjustmentException(long idsess) 
      : base(System.String.Format("Session <{0}> can not be postbill adjusted second time, delete adjustments first.", idsess) )
    {}

  }

  [ComVisible(false)]
  public class AdjustmentApplicabilityException : AdjustmentUserException
  {
    public AdjustmentApplicabilityException(long idsess, string rule) 
      : base(System.String.Format("Session {0} did not pass {1} applicability rule and can not be adjusted", idsess, rule) )
    {}
  }

  [ComVisible(false)]
  public class BusinessRuleException : AdjustmentUserException
  {
    public BusinessRuleException(long idsess, MTPC_BUSINESS_RULE rule) 
      : base(System.String.Format("Attempt to adjust session {0} violated {1} business rule", idsess, rule) )
    {}
  }

  [ComVisible(false)]
  public class NoGreaterThanChargeBusinessRuleException : AdjustmentUserException
  {
    public NoGreaterThanChargeBusinessRuleException(long idsess, MTPC_BUSINESS_RULE rule, decimal ajamount, decimal chargeamount) 
      : base(System.String.Format
      ("Attempt to adjust session {0} violated {1} business rule: (Adjustment Amount: {2}, Charge Amount: {3})", idsess, rule, ajamount, chargeamount) )
    {}
  }

  [ComVisible(false)]
  public class RebillUserException : AdjustmentUserException
  {
    public RebillUserException(string msg) 
      : base(msg)
    {}
  }

  [ComVisible(false)]
  public class SoftClosedIntervalException : AdjustmentUserException
  {
    public SoftClosedIntervalException(int aIntervalID, long aSessionID) 
      :  base(System.String.Format
      ("Interval {0} is soft closed, Transaction {1} cannot be adjusted or reassigned", aIntervalID, aSessionID) )
    {}
  }

  [ComVisible(false)]
  public class RebillException : AdjustmentException
  {
    public RebillException(string msg) 
      : base(msg)
    {}
  }

	[ComVisible(false)]
	public class ParentSessionPostbillReassignedException : AdjustmentException
	{
		public ParentSessionPostbillReassignedException(long idsess) 
			: base(System.String.Format("Session <{0}> cannot be adjusted, because it is a part of a previously reassigned compound session.", idsess) )
		{}
	}

  
}

  
