using System;
using System.Globalization;

namespace MetraTech.Domain.Notifications
{
  [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1053:StaticHolderTypesShouldNotHaveConstructors", Justification = "Mario: Requires a constructor to be used by XsltCompiledTransform")]
  public class ExtendedXsltFunctions
  {
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Performance", "CA1804:RemoveUnusedLocals", MessageId = "money", Justification = "Mario: Temporary until TODO is implemented")]
    public static string GetFormattedMoney(string textMoney)
    {
      if (String.IsNullOrEmpty(textMoney)) return textMoney;
      var textAmount = textMoney.Substring(0, textMoney.Length - 3);
      var currency = textMoney.Substring(textMoney.Length - 3, 3);
      if (textAmount == double.NaN.ToString(CultureInfo.InvariantCulture)) return textMoney;
      decimal amount;
      if (!decimal.TryParse(textAmount, out amount)) return textMoney;
      var money = new Money(amount, currency);
      //TODO: here we should invoke a method that will format money...
      return "$" + textAmount;
    }
  }
}
