using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WizardTest.Interfaces;
using WizardTest.Model;

namespace WizardTest.Controller
{
  class ExtensionController
  {
    private IExtension _extView;
    public ExtensionController (IExtension extView)
    {
      _extView = extView;
      PIModel.Instance.ExtensionModel = new ExtensionModel();
    }

    public void Init()
    {
      FillExistingNamespaces();
    }

    public void Load()
    {
      _extView.Name = PIModel.Instance.ExtensionModel.Name;
      _extView.Namespace = PIModel.Instance.ExtensionModel.Namespace;
      _extView.AuthorName = PIModel.Instance.ExtensionModel.AuthorName;
      _extView.Description = PIModel.Instance.ExtensionModel.Description;
    }

    public void Save()
    {
      PIModel.Instance.ExtensionModel.Name = _extView.Name;
      PIModel.Instance.ExtensionModel.Namespace = _extView.Namespace;
      PIModel.Instance.ExtensionModel.AuthorName = _extView.AuthorName;
      PIModel.Instance.ExtensionModel.Description = _extView.Description;
      PIModel.Instance.ExtensionModel.Element = "Extension";
    }

    public void FillExistingNamespaces()
    {
      _extView.ExistingNamespaces =  new List<string>();
      _extView.ExistingNamespaces.Add("metratech.com");
      _extView.ExistingNamespaces.Add("mt.com");
    }
  }
}
