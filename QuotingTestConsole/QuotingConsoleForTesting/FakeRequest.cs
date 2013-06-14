using System;

namespace MetraTech.Quoting.Test.ConsoleForTesting
{
  [Serializable]
  public class FakeRequest
  {
    public int IdAccountToQuoteFor { get; set; }
    public int IdProductOfferingToQuoteFor { get; set; }
    public string QuoteIdentifier { get; set; }
    public bool RunPDFGenerationForAllTestsByDefault { get; set; }
    public DateTime EffectiveDate { get; set; }
    public DateTime EffectiveEndDate { get; set; }
  }
}