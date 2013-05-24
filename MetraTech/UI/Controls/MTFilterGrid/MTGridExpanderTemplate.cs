using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel;
using System.Web.UI;
using MetraTech.UI.Controls;
using MetraTech.UI.Common;


namespace MetraTech.UI.Controls
{

  public class Field
  {
    private string  name = "";

    public string  Name
    {
      get { return name; }
      set { name = value; }
    }

    private String label;

    public String Label
    {
      get
      {
        
        return label;
      }
      set { label = value; }
    }

    private string alignment = "Left";

    public string Alignment
    {
      get { return alignment; }
      set { alignment = value; }
    }
	
  }

  public class Column
  {
    private List<Field> fields;
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
    [PersistenceMode(PersistenceMode.InnerProperty)]
    [NotifyParentProperty(true)]
    public List<Field> Fields
    {
      get
      {
        if (fields == null)
        {
          fields = new List<Field>();
        }
        return fields;
      }
    }
  }

  public class MTGridExpanderSection
  {
    private string name = "";
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    private String title;
    public String Title
    {
      get
      {
        
        return title;
      }

      set { title = value; }
    }

    private List<Column> columns ;

    [DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
    [PersistenceMode(PersistenceMode.InnerProperty)]
    [NotifyParentProperty(true)]
    public List<Column> Columns
    {
      get
      {
        if (columns == null)
        {
          columns = new List<Column>();
        }
        return columns;
      }
    }
  }
}

