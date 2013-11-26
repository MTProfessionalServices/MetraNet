using System.Collections.Generic;
using System.Linq;

namespace MetraTech.Domain
{
  /// <summary>
  /// Extension methods for arrays and collections.
  /// </summary>
  public static class Extensions
  {
    /// <summary>
    /// Returns true if array is not null and has values defined.
    /// </summary>
    /// <param name="items"></param>
    /// <returns>boolean</returns>
    public static bool HasValue(this object[] items)
    {
      return (items != null && items.Count() > 0);
    }
    /// <summary>
    /// Returns true if collection is not null and has items in it.
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="items"></param>
    /// <returns>boolean</returns>
    public static bool HasValue<T>(this IEnumerable<T> items)
    {
      return (items != null && items.Count() > 0);
    }
        
  }
}