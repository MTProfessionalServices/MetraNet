using System;
using System.Runtime.Serialization;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.BaseTypes;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.MetraPay
{
    public enum MTExpDateFormat
    {
        MT_YYMM = 0,
        MT_MMYY = 1,
        MT_YYYYMM = 2,
        MT_MMYYYY = 3,
        MT_MM_slash_YY = 4,
        MT_YY_slash_MM = 5,
        MT_MM_slash_YYYY = 6,
        MT_YYYY_slash_MM = 7,
        MT_DATE_FORMAT_NOT_SUPPORTED = 8
    }; 

  [DataContract]
  [Serializable]
  public class CreditCardPaymentMethod : MetraPaymentMethod
  {
    public override PaymentType PaymentMethodType
    {
      get { return PaymentType.Credit_Card; }
    }

    #region CreditCardType
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isCreditCardTypeDirty = false;
    [MTDirtyProperty("IsCreditCardTypeDirty")]
    protected MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType m_CreditCardType;
    [MTDataMember(Description = "This specifies the type of credit card", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType CreditCardType
    {
      get { return m_CreditCardType; }
      set
      {
        m_CreditCardType = value;
        isCreditCardTypeDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCreditCardTypeDirty
    {
      get { return isCreditCardTypeDirty; }
    }

    public string CreditCardTypeValueDisplayName
    {
      get
      {
        return BaseObject.GetDisplayName(this.CreditCardType);
      }
    }

    #endregion

    #region CVNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isCVNumberDirty = false;
    [MTDirtyProperty("IsCVNumberDirty")]
    protected String m_cvNumber;
    [MTDataMember(Description = "This specifies the credit card validation number", Length = 4)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public String CVNumber
    {
      get { return m_cvNumber; }
      set
      {
        m_cvNumber = value;
        isCVNumberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsCVNumberDirty
    {
      get { return isCVNumberDirty; }
    }
    #endregion

    #region ExpirationDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isExpirationDateDirty = false;
    [MTDirtyProperty("IsExpirationDateDirty")]
    protected string m_ExpirationDate;
    [MTDataMember(Description = "This is the expiration date on the card", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string ExpirationDate
    {
      get { return m_ExpirationDate; }
      set
      {

        m_ExpirationDate = value;
        isExpirationDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExpirationDateDirty
    {
      get { return isExpirationDateDirty; }
    }
    #endregion

    #region ExpirationDateFormat
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isExpirationDateFormatDirty = false;
    [MTDirtyProperty("IsExpirationDateFormatDirty")]
    protected MTExpDateFormat m_ExpirationDateFormat;
    [MTDataMember(Description = "This is the format of the expiration date", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public MTExpDateFormat ExpirationDateFormat
    {
      get { return m_ExpirationDateFormat; }
      set
      {
        m_ExpirationDateFormat = value;
        isExpirationDateFormatDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsExpirationDateFormatDirty
    {
      get { return isExpirationDateFormatDirty; }
    }
    #endregion

    #region StartDate
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isStartDateDirty = false;
    [MTDirtyProperty("IsStartDateDirty")]
    protected string m_StartDate;
    [MTDataMember(Description = "This is the start date for the card (MAESTRO)", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string StartDate
    {
      get { return m_StartDate; }
      set
      {

        m_StartDate = value;
        isStartDateDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsStartDateDirty
    {
      get { return isStartDateDirty; }
    }
    #endregion

    #region IssuerNumber
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    protected bool isIssuerNumberDirty = false;
    [MTDirtyProperty("IsIssuerNumberDirty")]
    protected string m_IssuerNumber;
    [MTDataMember(Description = "This is the card issuer number (MAESTRO)", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public string IssuerNumber
    {
      get { return m_IssuerNumber; }
      set
      {

        m_IssuerNumber = value;
        isIssuerNumberDirty = true;
      }
    }
    [ScriptIgnore]
    public bool IsIssuerNumberDirty
    {
      get { return isIssuerNumberDirty; }
    }
    #endregion

    #region Public Methods

    /// <summary>
    /// Using the credit card info object, parse out and return expiration month and year in out parameters
    /// </summary>
    /// <param name="expirationMonth">Returns expiration month</param>
    /// <param name="expirationYear">Returns expiration year</param>
    public void GetExpirationDate(out string expirationMonth, out string expirationYear)
    {
      //initialize
      expirationMonth = String.Empty;
      expirationYear = String.Empty;

      string expDate = this.ExpirationDate;
      MTExpDateFormat expFormatCode = this.ExpirationDateFormat;
      string expFormat = GetExpDateFormatString(expFormatCode);

      if ((String.IsNullOrEmpty(expDate)) || (String.IsNullOrEmpty(expFormat)))
      {
        return;
      }

      if (expDate.Length != expFormat.Length)
      {
        return;
      }

      expirationMonth = ParseMonthOrYear("MM", expFormat, expDate);
      expirationYear = ParseMonthOrYear("YYYY", expFormat, expDate);

      //if 4 digit year could not be parsed out, attempt to read out a 2 digit year and concatenate with 20xx
      if (expirationYear == String.Empty)
      {
        expirationYear = "20" + ParseMonthOrYear("YY", expFormat, expDate);
      }
    }
    #endregion

    #region protected Methods
    /* Returns format string based on the mapping below
     
          MT_YYMM = 0,
          MT_MMYY = 1,
          MT_YYYYMM = 2,
          MT_MMYYYY = 3,
          MT_MM_slash_YY = 4,
          MT_YY_slash_MM = 5,
          MT_MM_slash_YYYY = 6,
          MT_YYYY_slash_MM = 7,
          MT_DATE_FORMAT_NOT_SUPPORTED = 8
         */
    protected string GetExpDateFormatString(MTExpDateFormat expFormatCode)
    {
      string strFormat = String.Empty;

      switch (expFormatCode)
      {
          case MTExpDateFormat.MT_YYMM:
          strFormat = "YYMM";
          break;

        case MTExpDateFormat.MT_MMYY:
          strFormat = "MMYY";
          break;

        case MTExpDateFormat.MT_YYYYMM:
          strFormat = "YYYYMM";
          break;

        case MTExpDateFormat.MT_MMYYYY:
          strFormat = "MMYYYY";
          break;

        case MTExpDateFormat.MT_MM_slash_YY:
          strFormat = "MM/YY";
          break;

        case MTExpDateFormat.MT_YY_slash_MM:
          strFormat = "YY/MM";
          break;

        case MTExpDateFormat.MT_MM_slash_YYYY:
          strFormat = "MM/YYYY";
          break;

        case MTExpDateFormat.MT_YYYY_slash_MM:
          strFormat = "YYYY/MM";
          break;

        default:
          strFormat = "MM/YYYY";
          break;
      }

      return strFormat;
    }

    /// <summary>
    /// Returns a string that is either a parsed month or year, depending on monthOrYearFormat string
    /// </summary>
    /// <param name="datePartFormat">either MM or YY or YYYY</param>
    /// <param name="expFormat">format definition for exp date</param>
    /// <param name="expDate">expiration date to parse out</param>
    /// <returns></returns>
    protected string ParseMonthOrYear(string datePartFormat, string expFormat, string expDate)
    {
      int startPos = expFormat.IndexOf(datePartFormat, StringComparison.CurrentCultureIgnoreCase);
      if (startPos < 0)
      {
        return string.Empty;
      }

      //parse out the value from expDate, according to format and place into temporary placeholder
      string tmpVal = expDate.Substring(startPos, datePartFormat.Length);
      int numericValue = 0;

      //make sure the value is numeric
      try
      {
        if (Int32.TryParse(tmpVal, out numericValue))
        {
          return tmpVal;
        }
      }
      catch
      {
        //unable to parse out a numeric value
        return "0";
      }

      return String.Empty;
    }
    #endregion

  }
}
