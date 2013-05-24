package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTConfigFile'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigFile Interface</B>'
 *
 * Generator Options:
 * PromptForTypeLibraries = True
 * AttemptNonDual = True
 * ClashPrefix = zz_
 * LowerCaseMemberNames = True
 * IDispatchOnly = False
 * RetryOnReject = True
 * GenerateDeprecatedConstructors = True
 * ArraysAsObjects = False
 * DontGenerateDisp = False
 * DontRenameSameMethods = False
 * IgnoreConflictingInterfaces = True
 */
public class IMTConfigFileProxy extends com.linar.jintegra.Dispatch implements IMTConfigFile, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTConfigFile.class;

  public IMTConfigFileProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfigFile.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTConfigFileProxy() {}

  public IMTConfigFileProxy(Object obj) throws java.io.IOException {
    super(obj, IMTConfigFile.IID);
  }

  protected IMTConfigFileProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTConfigFileProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfigFile.IID, host, null);
  }

  protected IMTConfigFileProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
    super(CLSID, iid, host, authInfo);
  }

  public void addListener(String iidStr, Object theListener, Object theSource) throws java.io.IOException {
    super.addListener(iidStr, theListener, theSource);
  }

  public void removeListener(String iidStr, Object theListener) throws java.io.IOException {
    super.removeListener(iidStr, theListener);
  }

  /**
   * getPropertyByName. Get the value of a property dynamically at run-time, based on its name
   *
   * @return    return value.  The value of the property.
   * @param     name. The name of the property to get.
   * @exception java.lang.NoSuchFieldException If the property does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getPropertyByName(String name) throws NoSuchFieldException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant parameters[] = {};
    return super.invoke(name, super.getDispatchIdOfName(name), 2, parameters).getVARIANT();
  }

  /**
   * getPropertyByName. Get the value of a property dynamically at run-time, based on its name and a parameter value
   *
   * @return    return value.  The value of the property.
   * @param     name. The name of the property to get.
   * @param     rhs. Parameter used when getting the property.
   * @exception java.lang.NoSuchFieldException If the property does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getPropertyByName(String name, Object rhs) throws NoSuchFieldException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant parameters[] = {rhs == null ? new Variant("rhs", 10, 0x80020004L) : new Variant("rhs", 12, rhs)};
    return super.invoke(name, super.getDispatchIdOfName(name), 2, parameters).getVARIANT();
  }

  /**
   * invokeMethodByName. Invoke a method dynamically at run-time
   *
   * @return    return value.  The value returned by the method (null if none).
   * @param     name. The name of the method to be invoked
   * @param     parameters.  One element for each parameter.  Use primitive type wrappers
   *            to pass primitive types (eg Integer to pass an int).
   * @exception java.lang.NoSuchMethodException If the method does not exit.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object invokeMethodByName(String name, Object[] parameters) throws NoSuchMethodException, java.io.IOException, com.linar.jintegra.AutomationException {
    com.linar.jintegra.Variant variantParameters[] = new com.linar.jintegra.Variant[parameters.length];
    for(int i = 0; i < parameters.length; i++) {
      variantParameters[i] = parameters[i] == null ? new Variant("p" + i, 10, 0x80020004L) :
	                                                   new Variant("p" + i, 12, parameters[i]);
    }
    try {
      return super.invoke(name, super.getDispatchIdOfName(name), 1, variantParameters).getVARIANT();
    } catch(NoSuchFieldException nsfe) {
      throw new NoSuchMethodException("There is no method called " + name);
    }
  }

  /**
   * getConfigData. property ConfigData
   *
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getConfigData  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getConfigData", 7, zz_parameters);
        return (IMTConfigPropSet)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setConfigData. property ConfigData
   *
   * @param     apVal An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setConfigData  (
              IMTConfigPropSet apVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apVal, zz_retVal };
        vtblInvoke("setConfigData", 8, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getEffectDate. property EffectDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getEffectDate  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getEffectDate", 9, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setEffectDate. property EffectDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEffectDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(apVal), zz_retVal };
        vtblInvoke("setEffectDate", 10, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getExpireDate. property ExpireDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getExpireDate  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getExpireDate", 11, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setExpireDate. property ExpireDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setExpireDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(apVal), zz_retVal };
        vtblInvoke("setExpireDate", 12, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getDismissDate. property DismissDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getDismissDate  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getDismissDate", 13, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setDismissDate. property DismissDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDismissDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(apVal), zz_retVal };
        vtblInvoke("setDismissDate", 14, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getLingerDate. property LingerDate
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getLingerDate  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getLingerDate", 15, zz_parameters);
        return zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setLingerDate. property LingerDate
   *
   * @param     apVal The apVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setLingerDate  (
              int apVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(apVal), zz_retVal };
        vtblInvoke("setLingerDate", 16, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getMainConfigData. property MainConfigData
   *
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getMainConfigData  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getMainConfigData", 17, zz_parameters);
        return (IMTConfigPropSet)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setMainConfigData. property MainConfigData
   *
   * @param     apVal An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setMainConfigData  (
              IMTConfigPropSet apVal) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apVal, zz_retVal };
        vtblInvoke("setMainConfigData", 18, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * getConfigFilename. property ConfigFilename
   *
   * @return    return value.  The apFilename
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getConfigFilename  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getConfigFilename", 19, zz_parameters);
        return (String)zz_retVal[0];
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /**
   * setConfigFilename. property ConfigFilename
   *
   * @param     apFilename The apFilename (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setConfigFilename  (
              String apFilename) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apFilename, zz_retVal };
        vtblInvoke("setConfigFilename", 20, zz_parameters);
        return;
      } catch(com.linar.jintegra.AutomationException automationException) {
        if(automationException.getCode() != 0x80010001L) {
          throw automationException;
        }
      }
      try {
        Thread.sleep(2000);
      } catch(InterruptedException interrupedException) {}
    }
  }

  /** Dummy reference from interface to proxy to make sure proxy gets compiled */
  static final int xxDummy = 0;

  static {
    com.linar.jintegra.InterfaceDesc.add("20021548-741f-11d2-80fc-006008c0e8b7", IMTConfigFileProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("getConfigData",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("setConfigData",
            new Class[] { IMTConfigPropSet.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 29, 2, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getEffectDate",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setEffectDate",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getExpireDate",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setExpireDate",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getDismissDate",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setDismissDate",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getLingerDate",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setLingerDate",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 3, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getMainConfigData",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("setMainConfigData",
            new Class[] { IMTConfigPropSet.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apVal", 29, 2, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getConfigFilename",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apFilename", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setConfigFilename",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
});  }
}
