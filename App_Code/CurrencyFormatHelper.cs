using System;
using System.Collections.Generic;
using System.Globalization;

namespace MetraNet
{
  ///<summary>
  /// Provides ability to format digit value with money to the string currency format corresponding to view on UI.
  ///</summary>
  public static class CurrencyFormatHelper
  {
    private static List<CultureInfo> _cultures;

    ///<summary>
    /// @NOTE: Attention!! Method is deprecated! Use MoneyFormattingCurrentCulture instead.
    /// Format decimal value to the currency format.
    ///</summary>
    ///<param name="money" example="12345.9876">Money value.</param>
    ///<param name="isoCurrencySymbol"  example="USD, RUB">Currency code of the maney.</param>
    ///<returns examle="$12,345.99  MoneyFormating(12345.9876, USD).">Formated string representation for the specific currency.</returns>
    public static string MoneyFormatting(decimal money, string isoCurrencySymbol)
    {
      var ci = GetCultureInfoByMoneyCode(isoCurrencySymbol);
      
      if(ci.Name == "en-US")
      {
        if (money < 0)
        {
          // remove "(" and ")" if it exist from string ($12.00) (this is a format for negative $)
          var tempFormat = money.ToString("C", ci).Replace("(", string.Empty).Replace(")", string.Empty);
          // add minus symbol if it not exists.
          return tempFormat.Contains("-") ? tempFormat : string.Format(CultureInfo.InvariantCulture, "-{0}", tempFormat);
        }
      }
      ci.NumberFormat.CurrencyDecimalSeparator = CultureInfo.CurrentCulture.NumberFormat.CurrencyDecimalSeparator;
      ci.NumberFormat.CurrencyGroupSeparator = CultureInfo.CurrentCulture.NumberFormat.CurrencyGroupSeparator;
      return money != 0m ? money.ToString("C", ci) : 0m.ToString("C", ci);
    }

    ///<summary>
    /// Format decimal value to the currency format according current culture but with required currency symbol.
    ///</summary>
    ///<param name="money" example="12345.9876">Money value.</param>
    ///<param name="isoCurrencyCode"  example="USD, RUB">Currency code of the maney.</param>
    /// <param name="currentCulture">current culture</param>
    ///<returns examle="$12,345.99  MoneyFormating(12345.9876, USD).">Formated string representation for the specific currency.</returns>
    public static string MoneyFormattingCurrentCulture(decimal money, string isoCurrencyCode, CultureInfo currentCulture)
    {
      if (currentCulture == null) throw new ArgumentNullException("currentCulture");
      if(currentCulture.IsReadOnly)
        currentCulture=new CultureInfo(currentCulture.Name);
      if (!string.IsNullOrEmpty(isoCurrencyCode))
      {
        var ci = GetCultureInfoByMoneyCode(isoCurrencyCode);
        currentCulture.NumberFormat.CurrencySymbol = ci.NumberFormat.CurrencySymbol;
      }
      else
      {
        currentCulture.NumberFormat.CurrencySymbol = string.Empty;
      }
      
      return money != 0m ? money.ToString("C", currentCulture).Trim() : 0m.ToString("C", currentCulture).Trim();
    }

    ///<summary>
    /// Format decimal value to the currency format.
    ///</summary>
    ///<param name="money" example="12345.9876">Money value.</param>
    ///<param name="isoCurrencySymbol"  example="USD, RUB">Currency code of the money.</param>
    ///<param name="decimals">Decimals value (from Currency table)</param>
    ///<param name="currencySymbol">Symbol value from (Currency table)</param>
    ///<returns examle="$12,345.99  MoneyFormating(12345.9876, USD).">Formated string representation for the specific currency.</returns>
    public static string MoneyFormatting(decimal money, string isoCurrencySymbol, int? decimals, string currencySymbol)
    {
      var ci = GetCultureInfoByMoneyCode(isoCurrencySymbol);
      if (!ci.NumberFormat.IsReadOnly)
      {
        if (decimals.HasValue)
        {
          if (decimals.Value < 0 || decimals.Value > 99)
            throw new ArgumentException("Invalid value for decimals.");
          ci.NumberFormat.CurrencyDecimalDigits = decimals.Value;
        }
        if (currencySymbol != null)
        {
          ci.NumberFormat.CurrencySymbol = currencySymbol;
        }
      }
      ci.NumberFormat.CurrencyDecimalSeparator = CultureInfo.CurrentCulture.NumberFormat.CurrencyDecimalSeparator;
      ci.NumberFormat.CurrencyGroupSeparator = CultureInfo.CurrentCulture.NumberFormat.CurrencyGroupSeparator;
      if (money < 0)
        ci.NumberFormat.CurrencyNegativePattern = ci.Parent.CompareInfo.LCID == CultureInfo.CurrentUICulture.Parent.CompareInfo.LCID ? CultureInfo.CurrentUICulture.NumberFormat.CurrencyNegativePattern : 1;
      return money.ToString("C", ci);
    }

    /// <summary>
    /// Get Currency Symbol By iso Currency code
    /// </summary>
    /// <param name="isoCurrencySymbol">iso Currency code</param>
    /// <returns></returns>
    public static string GetCurrencySymbolByMoneyCode(string isoCurrencySymbol)
    {
      return GetCultureInfoByMoneyCode(isoCurrencySymbol).NumberFormat.CurrencySymbol;
    }

    ///<summary>
    /// Format nullable decimal value to the currency format.
    ///</summary>
    ///<param name="money" example="12345.9876">Money value.</param>
    ///<param name="isoCurrencySymbol"  example="USD, RUB">Currency code of the maney.</param>
    ///<returns examle="$12,345.99  MoneyFormating(12345.9876, USD).">Formated string representation for the specific currency.</returns>
    public static string MoneyFormatting(decimal? money, string isoCurrencySymbol)
    {
      return money.HasValue
               ? (money == 0m
                    ? MoneyFormatting(0m, isoCurrencySymbol)
                    : MoneyFormatting(money.Value, isoCurrencySymbol))
               : MoneyFormatting(0m, isoCurrencySymbol);
    }

    /// <summary>
    /// Finds cuture object by currencySymbol (for exam. by USD, RUB)
    /// </summary>
    public static CultureInfo GetCultureInfoByMoneyCode(string isoCurrencySymbol)
    {
      if (string.IsNullOrEmpty(isoCurrencySymbol) || string.IsNullOrWhiteSpace(isoCurrencySymbol))
        throw new ArgumentException("ISO currency symbol is invalid.");

      if (_cultures == null)
      {
        _cultures = new List<CultureInfo>();
        foreach (var ci in CultureInfo.GetCultures(CultureTypes.AllCultures))
        {
          CultureInfo specName = null;
          try { specName = CultureInfo.CreateSpecificCulture(ci.Name); }
          catch (ArgumentOutOfRangeException) { }

          _cultures.Add(specName);
        }
      }

      foreach (var culture in _cultures)
      {
        try
        {
          var regionInfo = new RegionInfo(culture.LCID);
          if (regionInfo.ISOCurrencySymbol == isoCurrencySymbol)
            // return new instance to prevent of possible modification
            return new CultureInfo(culture.Name);
        }
        catch (ArgumentException)
        {
        }
      }
      throw new InvalidOperationException(String.Format(CultureInfo.InvariantCulture, "Cannot find Region Info for ISO currency symbol {0}", isoCurrencySymbol));
    }
  }
}
