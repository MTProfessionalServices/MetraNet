using System;

  /// <summary>
  /// ExtensionMethods
  /// </summary>
public static class ExtensionMethods
{

  public static DateTime ToEndOfDay(this DateTime value)
  {
    // a little math to move us to midnight
    const int secondsInDay = 86400;
    var currentSeconds = (value.Hour * 3600) + (value.Minute * 60) + value.Second;
    var toMidnight = secondsInDay - currentSeconds - 1;
    value = value.AddSeconds(toMidnight);
    return value;
  }

  public static string ToSmallString(this string value)
  {
    string str;
    if ((value.Length > 10) && !(value.Length < 13))
    {
      str = value.Substring(0, 10);
      str += "...";
    }
    else
    {
      str = value;
    }
    return str;
  }

  public static string AppendWildcard(this string input)
  {
    const char wildcardChar = '%';
    var output = input;

    //don't do anything for null/empty strings
    if (String.IsNullOrEmpty(output))
    {
      return input;
    }

    //if last char is the wildcard, don't do anything
    if (input.LastIndexOf(wildcardChar) == input.Length - 1)
    {
      return input;
    }

    //append wildcard char if necessary
    output = output + wildcardChar;

    output = output.Replace("*", wildcardChar.ToString());
    output = output.Replace(wildcardChar + wildcardChar.ToString(), wildcardChar.ToString());

    return output;
  }
}
