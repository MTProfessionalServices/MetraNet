using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace MetraTech.ICE.ExpressionEngine
{
  public partial class frmRefactor : Form
  {
    #region Constructor
    public frmRefactor()
    {
      InitializeComponent();
    }
    #endregion

    private void btnSearch_Click(object sender, EventArgs e)
    {
      var refactor = new RefactorProperties();
      var entities = refactor.GetEntitiesMatchingProperty(txtOldName.Text);
      foreach (var entity in entities)
      {
        lstElements.Items.Add(entity);
      }
    }
  }
}
