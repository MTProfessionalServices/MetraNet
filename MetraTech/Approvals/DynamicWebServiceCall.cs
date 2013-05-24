using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Reflection;
using MetraTech.ActivityServices.Common;


//S:\MetraTech\Core\Client\CoreClientConnector.cs
//S:\MetraTech\ActivityServices\Common\MASClientClassFactory.cs
//S:\MetraTech\ActivityServices\Runtime\MASInternalMASCallService.cs

namespace MetraTech.Approvals
{
  class DynamicWebServiceCall
  {
    #region Members
    private Logger mLogger = new Logger("[DynamicWebServiceCall]");
    #endregion

    public void InvokeMASMethod(string fullTypeName, string methodName, ref Dictionary<string, object> inputsOutputs)
    {
      try
      {
        mLogger.LogDebug("Invoking ActivityServices method {0} on interface {1}", methodName, fullTypeName);

        Type svcType = Type.GetType(fullTypeName, true, true);
        object svcClass = svcType.Assembly.CreateInstance(svcType.FullName);

        MethodInfo svcMethodInfo = svcType.GetMethod(methodName);
        ParameterInfo[] parameters = svcMethodInfo.GetParameters();
        object[] paramValues = new object[parameters.Length];

        if (inputsOutputs.Count == parameters.Length)
        {

          int i = 0;
          foreach (ParameterInfo parameter in parameters)
          {
            if (inputsOutputs.ContainsKey(parameter.Name))
            {
              paramValues[i++] = inputsOutputs[parameter.Name];
            }
            else
            {
              throw new MASBasicException(String.Format("Not all the necessary input/output parameters were passed to InvokeMASMethod.  Parameter {0} is missing", parameter.Name));
            }
          }

          svcMethodInfo.Invoke(svcClass, paramValues);

          ParameterInfo paramInfo;
          for (int j = 0; j < parameters.Length; j++)
          {
            paramInfo = parameters[j];

            if (inputsOutputs.ContainsKey(paramInfo.Name))
            {
              inputsOutputs[paramInfo.Name] = paramValues[j];
            }
          }
        }
        else
        {
          throw new MASBasicException("Not all the necessary input/output parameters were passed to InvokeMASMethod");
        }
      }
      catch (TargetInvocationException target)
      {
        Exception e = target.GetBaseException();

        throw e;
      }
      catch (MASBaseException masBase)
      {
        mLogger.LogException("Handled exception in InternalMASCallService", masBase);

        throw masBase;
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception in InvokeMASMethod", e);

        throw new MASBasicException(string.Format("Error occured invoking ActivityServices method {0} on interface {1}", methodName, fullTypeName));
      }

    }

  }

}
