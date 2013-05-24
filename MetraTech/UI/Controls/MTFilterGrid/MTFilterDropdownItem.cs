using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.UI.Controls
{
  public class MTFilterDropdownItem
  {
    private string key;

    public string Key
    {
      get { return key; }
      set { key = value; }
    }

    private string _value;

    public string Value
    {
      get { return _value; }
      set { _value = value; }
    }
	
  }
}
