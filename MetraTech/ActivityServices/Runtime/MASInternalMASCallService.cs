using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Activities;

namespace MetraTech.ActivityServices.Runtime
{
  class CMASInternalMASCallService : IMTMASCallService
  {
    #region Members
    private Logger m_Logger = new Logger("Logging\\ActivityServices", "[MASInternalMASCallService]");
    #endregion

    #region IMTMASCallService Members
    public void InvokeMASMethod(string fullTypeName, string methodName, ref Dictionary<string, object> inputsOutputs)
    {
      try
      {
        m_Logger.LogDebug("Invoking ActivityServices method {0} on interface {1}", methodName, fullTypeName);

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
        m_Logger.LogException("Handled exception in InternalMASCallService", masBase);

        throw masBase;
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception in InvokeMASMethod", e);

        throw new MASBasicException(string.Format("Error occured invoking ActivityServices method {0} on interface {1}", methodName, fullTypeName));
      }

    }
    #endregion
  }
}
