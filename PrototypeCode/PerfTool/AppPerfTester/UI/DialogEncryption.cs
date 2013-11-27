using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace BaselineGUI
{
  public partial class DialogEncryption : Form
  {
    public DialogEncryption()
    {
      InitializeComponent();
      pushModelToControl();
    }

    public void pushModelToControl()
    {
      textBoxPassword.Text = PrefRepo.active.Security.encryptionKey;
    }

    public void pushControlToModel()
    {
      PrefRepo.active.Security.encryptionKey = textBoxPassword.Text;
      FCSecurity security = FrameworkComponentFactory.find<FCSecurity>();
      security.security.setPassphrase(PrefRepo.active.Security.encryptionKey);
    }
  }
}
