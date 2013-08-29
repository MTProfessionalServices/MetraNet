using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Domain.Test
{
  /// <summary>
  /// TODO: Update summary.
  /// </summary>
  public class Comparers
  {
    public static void CompareStringArrays(IEnumerable<string> array1, IEnumerable<string> array2, string propertyName)
    {
      var list1 = array1 as IList<string> ?? array1.ToList();
      var list2 = array2 as IList<string> ?? array2.ToList();

      if (list1.Count == 0 && list2.Count == 0)
        return;

      if (list1.Count != list2.Count)
        Assert.Fail(propertyName + " have deferent element count");

      foreach (var element in list1)
        Assert.IsTrue(list2.Contains(element),
          String.Format(CultureInfo.InvariantCulture, "{0}. Element {1} not found in the second array.", propertyName, element));
    }

    public static void CompareDictionaries(IDictionary<string, string> dictionary1, IDictionary<string, string> dictionary2, string propertyName)
    {
      if (dictionary1 == null)
        dictionary1 = new Dictionary<string, string>();

      if (dictionary2 == null)
        dictionary2 = new Dictionary<string, string>();

      if (dictionary1.Count != dictionary2.Count)
        Assert.Fail(propertyName + " have deferent element count");

      foreach (var key in dictionary1.Keys)
      {
        if (!dictionary2.ContainsKey(key))
          Assert.Fail("{0}. Key {1} not found in the second array.", propertyName, key);

        if (dictionary1[key] != dictionary2[key])
          Assert.Fail("{0}. Value {1} deferent in the second array for {2} key.", propertyName, dictionary1[key], key);
      }
    }
  }
}
