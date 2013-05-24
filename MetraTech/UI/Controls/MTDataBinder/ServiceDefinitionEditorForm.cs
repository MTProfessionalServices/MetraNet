using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

using MetraTech;
using MetraTech.Xml;
using MetraTech.Pipeline;

namespace MetraTech.UI.Controls
{
  public partial class ServiceDefinitionEditorForm : Form
  {
    ServiceDefinitionCollection mSDCol = new ServiceDefinitionCollection();

    private string mServiceDefinition = "";
    public string ServiceDefinition
    {
      get { return ddServiceDefinition.SelectedValue as string; }
      set { mServiceDefinition = value; }
    }

    public ServiceDefinitionEditorForm()
    {
      InitializeComponent();
    }

    private void ServiceDefinitionEditorForm_Load(object sender, EventArgs e)
    {
      // Get the list of available serfice definitions
      // and bind to dropdown.
      List<string> list = new List<string>();
      foreach (string s in mSDCol.SortedNames)
      {
        list.Add(s);
      }
      BindingSource bs = new BindingSource();
      bs.DataSource = list;
      ddServiceDefinition.DataSource = bs;

      // Set default value if one exists
      if ((mServiceDefinition != null) && (mServiceDefinition != String.Empty))
      {
        int index = ddServiceDefinition.FindString(mServiceDefinition);
        ddServiceDefinition.SelectedIndex = index;
      }
    }
	
  }
}