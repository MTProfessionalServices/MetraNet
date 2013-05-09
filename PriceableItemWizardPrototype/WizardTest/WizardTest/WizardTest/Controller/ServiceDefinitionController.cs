using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using WizardTest.Interfaces;
using WizardTest.Model;

namespace WizardTest
{
    class ServiceDefinitionController
    {
        readonly IServiceDefinition _sdView;

        public ServiceDefinitionController(IServiceDefinition sdView)
        {
          _sdView = sdView;
          PIModel.Instance.ServiceDefinition =  new ServiceDefinitionModel();

        }

        public void Load()
        {
          _sdView.Name = PIModel.Instance.ServiceDefinition.Name;
          _sdView.Description = PIModel.Instance.ServiceDefinition.Description;
        }

        public void Save()
        {
          PIModel.Instance.ServiceDefinition.Name = _sdView.Name;
          PIModel.Instance.ServiceDefinition.Description = _sdView.Description;
          PIModel.Instance.ServiceDefinition.Element = "ServiceDefinition";
          PIModel.Instance.ServiceDefinition.TableName = String.Format("t_svc_{0}", _sdView.Name);
        }
    }
}
