package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IMTConfig'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfig Interface</B>'
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
public class IMTConfigProxy extends com.linar.jintegra.Dispatch implements IMTConfig, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IMTConfig.class;

  public IMTConfigProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfig.IID, host, authInfo);
  }

  /** For internal use only */
  public IMTConfigProxy() {}

  public IMTConfigProxy(Object obj) throws java.io.IOException {
    super(obj, IMTConfig.IID);
  }

  protected IMTConfigProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IMTConfigProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IMTConfig.IID, host, null);
  }

  protected IMTConfigProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
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
   * readConfiguration. method ReadConfiguration
   *
   * @param     aFilename The aFilename (in)
   * @param     apChecksumMatch The apChecksumMatch (out: use single element array)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet readConfiguration  (
              String aFilename,
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aFilename, apChecksumMatch, zz_retVal };
        vtblInvoke("readConfiguration", 7, zz_parameters);
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
   * newConfiguration. method NewConfiguration
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet newConfiguration  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aName, zz_retVal };
        vtblInvoke("newConfiguration", 8, zz_parameters);
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
   * readConfigurationFromHost. method ReadConfigurationFromHost
   *
   * @param     aHostName The aHostName (in)
   * @param     aRelativePath The aRelativePath (in)
   * @param     aSecure The aSecure (in)
   * @param     apChecksumMatch The apChecksumMatch (out: use single element array)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet readConfigurationFromHost  (
              String aHostName,
              String aRelativePath,
              boolean aSecure,
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aHostName, aRelativePath, new Boolean(aSecure), apChecksumMatch, zz_retVal };
        vtblInvoke("readConfigurationFromHost", 9, zz_parameters);
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
   * readConfigurationFromURL. method ReadConfigurationFromURL
   *
   * @param     aURL The aURL (in)
   * @param     apChecksumMatch The apChecksumMatch (out: use single element array)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet readConfigurationFromURL  (
              String aURL,
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aURL, apChecksumMatch, zz_retVal };
        vtblInvoke("readConfigurationFromURL", 10, zz_parameters);
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
   * readConfigurationFromString. method ReadConfigurationFromString
   *
   * @param     aConfigBuffer The aConfigBuffer (in)
   * @param     apChecksumMatch The apChecksumMatch (out: use single element array)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet readConfigurationFromString  (
              String aConfigBuffer,
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTConfigPropSet zz_retVal[] = { null };
        Object zz_parameters[] = { aConfigBuffer, apChecksumMatch, zz_retVal };
        vtblInvoke("readConfigurationFromString", 11, zz_parameters);
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
   * isAutoEnumConversion. property AutoEnumConversion
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean isAutoEnumConversion  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("isAutoEnumConversion", 12, zz_parameters);
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
   * setAutoEnumConversion. property AutoEnumConversion
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setAutoEnumConversion  (
              boolean apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Boolean(apConvert), zz_retVal };
        vtblInvoke("setAutoEnumConversion", 13, zz_parameters);
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
   * getUsername. property Username
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getUsername  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getUsername", 14, zz_parameters);
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
   * setUsername. property Username
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setUsername  (
              String apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apConvert, zz_retVal };
        vtblInvoke("setUsername", 15, zz_parameters);
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
   * getPassword. property Password
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getPassword  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getPassword", 16, zz_parameters);
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
   * setPassword. property Password
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setPassword  (
              String apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { apConvert, zz_retVal };
        vtblInvoke("setPassword", 17, zz_parameters);
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
   * isSecureFlag. property SecureFlag
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean isSecureFlag  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        boolean zz_retVal[] = { false };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("isSecureFlag", 18, zz_parameters);
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
   * setSecureFlag. property SecureFlag
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setSecureFlag  (
              boolean apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Boolean(apConvert), zz_retVal };
        vtblInvoke("setSecureFlag", 19, zz_parameters);
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
   * getPort. property Port
   *
   * @return    return value.  The apPort
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getPort  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getPort", 20, zz_parameters);
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
   * setPort. property Port
   *
   * @param     apPort The apPort (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setPort  (
              int apPort) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { new Integer(apPort), zz_retVal };
        vtblInvoke("setPort", 21, zz_parameters);
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
    com.linar.jintegra.InterfaceDesc.add("9adcd81d-35fd-11d2-a1c4-006008c0e24a", IMTConfigProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("readConfiguration",
            new Class[] { String.class, boolean[].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aFilename", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apChecksumMatch", 16395, 4, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("newConfiguration",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("readConfigurationFromHost",
            new Class[] { String.class, String.class, Boolean.TYPE, boolean[].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aHostName", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aRelativePath", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("aSecure", 11, 2, 8, null, null), 
              new com.linar.jintegra.Param("apChecksumMatch", 16395, 4, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("readConfigurationFromURL",
            new Class[] { String.class, boolean[].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aURL", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apChecksumMatch", 16395, 4, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("readConfigurationFromString",
            new Class[] { String.class, boolean[].class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("aConfigBuffer", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("apChecksumMatch", 16395, 4, 8, null, null), 
              new com.linar.jintegra.Param("apSet", 29, 20, 4, IMTConfigPropSet.IID, IMTConfigPropSetProxy.class) }),
        new com.linar.jintegra.MemberDesc("isAutoEnumConversion",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setAutoEnumConversion",
            new Class[] { Boolean.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 11, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getUsername",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setUsername",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getPassword",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setPassword",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("isSecureFlag",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 11, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setSecureFlag",
            new Class[] { Boolean.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apConvert", 11, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getPort",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apPort", 22, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("setPort",
            new Class[] { Integer.TYPE, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("apPort", 22, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
});  }
}
