using System;

namespace MetraTech.Domain
{
  /// <summary>
  /// Extension methods for string class.
  /// </summary>
  public static class StringExtensions
  {
    /// <summary>
    /// Indicates whether the specified string is not null and not Empty string.
    /// </summary>
    /// <param name="value">The string to test.</param>
    /// <returns><c>true</c> if the value parameter is <c>null</c> or an empty string (""); otherwise, <c>false</c>.</returns>
    public static bool HasValue(this string value)
    {
      return !string.IsNullOrEmpty(value);
    }

    /// <summary>
    /// Converts a UTF-8 string to a Base-64 version of the string.
    /// </summary>
    /// <param name="valueToConvert">The string to convert to Base-64.</param>
    /// <returns>The Base-64 converted string.</returns>
    public static string ToBase64(this string valueToConvert)
    {
      byte[] bytes = System.Text.Encoding.UTF8.GetBytes(valueToConvert);
      return Convert.ToBase64String(bytes);
    }

    /// <summary>
    /// Converts a Base-64 encoded string to UTF-8.
    /// </summary>
    /// <param name="valueToConvert">The string to convert from Base-64.</param>
    /// <returns>The converted UTF-8 string.</returns>
    public static string FromBase64(this string valueToConvert)
    {
      byte[] bytes = Convert.FromBase64String(valueToConvert);
      return System.Text.Encoding.UTF8.GetString(bytes);
    }
  }
}