using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace MetraTech.Basic
{
  /// <summary>
  ///   Use this class to create XML without the encoding.
  ///   <?xml version="1.0"?> instead of 
  ///   <?xml version="1.0" encoding="utf-16"?>
  /// </summary>
  public class NullEncodingStringWriter : StringWriter
  {
    public override Encoding Encoding
    {
      get { return null; }
    }
  }
}
