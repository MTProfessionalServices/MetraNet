using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for AmpDecisionValidationError
/// </summary>
public class AmpDecisionValidationError
{
  private string mValidationErrorID;
  public string ValidationErrorID
  {
    get { return mValidationErrorID; }
    set { mValidationErrorID = value; }
  }

  private string mValidationErrorSeverity;
  public string ValidationErrorSeverity
  {
    get { return mValidationErrorSeverity; }
    set { mValidationErrorSeverity = value; }
  }

  private string mValidationErrorMessage;
  public string ValidationErrorMessage
  {
    get { return mValidationErrorMessage; }
    set { mValidationErrorMessage = value; }
  }
}