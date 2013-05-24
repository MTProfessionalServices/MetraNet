using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;

namespace MetraTech.DomainModel.Common
{
  [DataContract]
  [Serializable]
  public class MTTemporalList<T>
  {
    static DateTime METRATIME_MAX = new DateTime(2038, 1, 1, 0, 0, 0);

    #region Members
    private List<T> m_Items = new List<T>();

    private string m_StartDateProperty;
    private string m_EndDateProperty;
    #endregion

    #region Constructors
    public MTTemporalList(string startDateProperty, string endDateProperty)
    {
      m_StartDateProperty = startDateProperty;
      m_EndDateProperty = endDateProperty;

      if (!(typeof(T) is ICloneable))
      {
        throw new ArgumentException("The type contained must implement ICloneable");
      }
    }
    #endregion

    #region Public Methods
    public void Add(T item)
    {
      List<T> toRemove = new List<T>();
      List<T> toAdd = new List<T>();
      toAdd.Add(item);

      PropertyInfo startDateProp = typeof(T).GetProperty(m_StartDateProperty);
      PropertyInfo endDateProp = typeof(T).GetProperty(m_EndDateProperty);

      DateTime itemStartDate = (DateTime)startDateProp.GetValue(item, null);
      itemStartDate = new DateTime(itemStartDate.Year, itemStartDate.Month, itemStartDate.Day, 0, 0, 0);
      startDateProp.SetValue(item, itemStartDate, null);

      DateTime itemEndDate = (DateTime)endDateProp.GetValue(item, null);
      if (itemEndDate != METRATIME_MAX)
      {
        itemEndDate = new DateTime(itemEndDate.Year, itemEndDate.Month, itemEndDate.Day, 23, 59, 59);
        endDateProp.SetValue(item, itemEndDate, null);
      }

      DateTime nodeStartDate, nodeEndDate;

      foreach (T node in m_Items)
      {
        nodeStartDate = (DateTime)startDateProp.GetValue(node, null);
        nodeEndDate = (DateTime)endDateProp.GetValue(node, null);

        if (itemStartDate <= nodeStartDate && itemEndDate >= nodeStartDate && itemEndDate < nodeEndDate ) 
        {
          nodeStartDate = itemEndDate.AddSeconds(1);
          startDateProp.SetValue(node, nodeStartDate, null);
        }
        else if (itemStartDate > nodeStartDate && itemStartDate <= nodeEndDate && itemEndDate >= nodeEndDate)
        {
          nodeEndDate = itemStartDate.AddSeconds(-1);
          endDateProp.SetValue(node, nodeEndDate, null);
        }
        else if (itemStartDate <= nodeStartDate && itemEndDate >= nodeEndDate)
        {
          toRemove.Add(node);
        }
        else if (itemStartDate > nodeStartDate && itemEndDate < nodeEndDate)
        {
          T split = (T)((ICloneable)node).Clone();
          
          nodeStartDate = itemEndDate.AddSeconds(1);
          startDateProp.SetValue(split, nodeStartDate, null);

          toAdd.Add(split);

          nodeEndDate = itemStartDate.AddSeconds(-1);
          endDateProp.SetValue(node, nodeEndDate, null);
        }
      }

      foreach (T node in toRemove)
      {
        m_Items.Remove(node);
      }

      foreach (T node in toAdd)
      {
        m_Items.Add(node);
      }

      ItemComparer<T> comp = new ItemComparer<T>(m_StartDateProperty);
      m_Items.Sort(comp);
    }
    #endregion

    #region Properties
    public List<T> Items
    {
      get { return m_Items; }
    }
    #endregion

    #region Comparer Class
    private class ItemComparer<T2> : IComparer<T2>
    {
      private string m_DatePropName;

      public ItemComparer(string datePropName)
      {
        m_DatePropName = datePropName;
      }

      #region IComparer<T2> Members

      public int Compare(T2 x, T2 y)
      {
        PropertyInfo startDateProp = typeof(T2).GetProperty(m_DatePropName);

        DateTime xDT = (DateTime)startDateProp.GetValue(x, null);
        DateTime yDT = (DateTime)startDateProp.GetValue(y, null);

        return DateTime.Compare(xDT, yDT);
      }

      #endregion
    }
    #endregion
  }
}
