using System;
using System.Collections.Generic;

namespace MetraTech.Quoting.Test.ConsoleForTesting
{
  [Serializable]
  public class FakeRequest
  {
    public List<int> IdAccountsToQuoteFor { get; set; }
    public List<int> IdProductOfferingsToQuoteFor { get; set; }
    public string QuoteIdentifier { get; set; }
    public bool RunPDFGenerationForAllTestsByDefault { get; set; }
    public DateTime EffectiveDate { get; set; }
    public DateTime EffectiveEndDate { get; set; }
  }
}