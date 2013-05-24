using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;

namespace MetraTech.UI.Controls
{
  public class MTGridDataElementCollection : ArrayList, IComparer // IList
  {/*
    public MTGridDataElement this[int index]
    {
      get
      {
        return ((MTGridDataElement)List[index]);
      }
      set
      {
        List[index] = value;
      }
    }
    */
    public MTGridDataElement GetColumnByDataIndex(string dataIndex)
    {
      foreach (MTGridDataElement elt in this)
      {
        if (elt.DataIndex.ToLower() == dataIndex.ToLower())
        {
          return elt;
        }
      }

      return null;
    }

    public bool ContainsID(string sItem)
    {
      foreach (MTGridDataElement elt in this)
      {
        if (elt.ID.ToLower() == sItem.ToLower())
        {
          return true;
        }
      }

      return false;
    }
    /*
    public int Add(MTGridDataElement item)
    {
      return (List.Add(item));
    }
    
    public int IndexOf(MTGridDataElement item)
    {
      return (List.IndexOf(item));
    }

    public void Insert(int index, MTGridDataElement item)
    {
      List.Insert(index, item);
    }

    public void Remove(MTGridDataElement item)
    {
      List.Remove(item);
    }
*/
    #region IComparer Members

    public int Compare(object x, object y)
    {
      //throw new Exception("The method or operation is not implemented.");
      return ((MTGridDataElement)x).Position.CompareTo(((MTGridDataElement)y).Position);
    }

    #endregion

    #region IComparer Members

    int IComparer.Compare(object x, object y)
    {
      return ((MTGridDataElement)x).Position.CompareTo(((MTGridDataElement)y).Position);
    }

    #endregion
  }
    
}
