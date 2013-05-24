using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;

namespace MetraTech.UI.Common
{
  /// <summary>
  /// EnumManager contains an enumerable list of EnumItems, and can be bound to UI elements
  /// through the MTDataBinder
  /// </summary>
  [Serializable]
  public class EnumManager
  {
    private List<EnumListItem> mEnumList;
    public List<EnumListItem> EnumList
    {
      get { return mEnumList; }
      set { mEnumList = value; }
    }

    private EnumListItem mSelectedItem;
    public EnumListItem SelectedItem
    {
      get { return mSelectedItem; }
      set { mSelectedItem = value; }
    }

    private string mSelectedValue;
    public string SelectedValue
    {
      get { return mSelectedItem.Value; }
      set { mSelectedValue = this[value].Value; }
    }

    public void Add(EnumListItem itm)
    {
      mEnumList.Add(itm);
    }

    public void Clear()
    {
      mEnumList.Clear();
    }

    public void Remove(EnumListItem itm)
    {
      mEnumList.Remove(itm);
    }

    public EnumListItem this[string value]
    {
      get 
      {
        EnumListItem returnItem = null;

        foreach (EnumListItem itm in mEnumList)
        {
          if (itm.Value == value)
          {
            returnItem = itm;
            break;
          }
        }

        return returnItem;
      }
    }

    public EnumManager()
    {

    }


  }

  /// <summary>
  /// EnumItem represents an individual item, in a list of items that can be bound to UI elements.
  /// </summary>
  [Serializable]
  public class EnumListItem
  {
    private string mValue;
    public string Value
    {
      get { return mValue; }
      set { mValue = value; }
    }

    private string mDisplayName;
    public string DisplayName
    {
      get { return mDisplayName; }
      set { mDisplayName = value; }
    }

    private string mDescription;
    public string Description
    {
      get { return mDescription; }
      set { mDescription = value; }
    }

    public EnumListItem()
    {

    }

    public EnumListItem(string displayName, string value, string description)
    {
      DisplayName = displayName;
      Value = value;
      Description = description;
    }

  }
}
