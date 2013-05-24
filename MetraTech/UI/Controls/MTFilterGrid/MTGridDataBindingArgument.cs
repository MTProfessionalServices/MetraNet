using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;

namespace MetraTech.UI.Controls
{

  #region MTGridDataBindingArgument class
  public class MTGridDataBindingArgument
  {
    public MTGridDataBindingArgument() { }
    public MTGridDataBindingArgument(string name, string value)
    {
      this.name = name;
      this.valueProp = value;
    }

    private string name;

    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    private string valueProp;

    public string Value
    {
      get { return valueProp; }
      set { valueProp = value; }
    }

  }
  #endregion

  #region MTGridDataBindingArgumentCollection class
  public class MTGridDataBindingArgumentCollection : CollectionBase // IList
  {
    public MTGridDataBindingArgument this[int index]
    {
      get
      {
        return ((MTGridDataBindingArgument)List[index]);
      }
      set
      {
        List[index] = value;
      }
    }

    public int Add(MTGridDataBindingArgument item)
    {
      return (List.Add(item));
    }

    public int Add(string name, string value)
    {
      MTGridDataBindingArgument arg = new MTGridDataBindingArgument(name, value);
      return (List.Add(arg));
    }

    public int IndexOf(MTGridDataBindingArgument item)
    {
      return (List.IndexOf(item));
    }

    public void Insert(int index, MTGridDataBindingArgument item)
    {
      List.Insert(index, item);
    }

    public void Remove(MTGridDataBindingArgument item)
    {
      List.Remove(item);
    }
  }

  #endregion
}
