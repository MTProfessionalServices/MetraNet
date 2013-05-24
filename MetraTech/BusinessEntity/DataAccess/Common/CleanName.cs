using System;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using Microsoft.Win32;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  /// <summary>
  ///    Valid identifiers in C# are defined in the C# Language Specification, item 2.4.2. The rules are:
  ///     - An identifier must start with a letter or an underscore
  ///     - After the first character, it may contain numbers, letters, connectors, etc
  ///     - If the identifier is a keyword, it must be prepended with “@” 
  /// </summary>
  public static class CleanName
  {
    /// <summary>
    ///   Return a valid C# identifier.
    /// </summary>
    /// <param name="entity"></param>
    /// <returns></returns>
    public static string GetIdentifier(string name)
    { //Compliant with item 2.4.2 of the C# specification
      Regex regex = new Regex(@"[^\p{Ll}\p{Lu}\p{Lt}\p{Lo}\p{Nd}\p{Nl}\p{Mn}\p{Mc}\p{Cf}\p{Pc}\p{Lm}]");
      string ret = regex.Replace(name, "_"); 
      //The identifier must start with a character or _
      if (!char.IsLetter(ret, 0))
      {
        ret = string.Concat("_", ret);
      }

      if (!Microsoft.CSharp.CSharpCodeProvider.CreateProvider("C#").IsValidIdentifier(ret))
      {
        ret = string.Concat("@", ret);
      }

      return ret; 
    }

    public static bool IsValidIdentifier(string identifier)
    {
      return Microsoft.CSharp.CSharpCodeProvider.CreateProvider("C#").IsValidIdentifier(identifier);
    }
  }
}
