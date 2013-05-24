package com.metratech.pipeline;

import com.linar.jintegra.*;
/**
 * Proxy for COM Interface 'IEnumConfig'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IEnumConfig Interface</B>'
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
public class IEnumConfigProxy extends com.linar.jintegra.Dispatch implements IEnumConfig, java.io.Serializable {

  protected String getJintegraVersion() { return "1.3.4 SB002"; }

  static { JIntegraInit.init(); }

  public static final Class targetClass = com.metratech.pipeline.IEnumConfig.class;

  public IEnumConfigProxy(String CLSID, String host, AuthInfo authInfo) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IEnumConfig.IID, host, authInfo);
  }

  /** For internal use only */
  public IEnumConfigProxy() {}

  public IEnumConfigProxy(Object obj) throws java.io.IOException {
    super(obj, IEnumConfig.IID);
  }

  protected IEnumConfigProxy(Object obj, String iid) throws java.io.IOException {
    super(obj, iid);
  }

  public IEnumConfigProxy(String CLSID, String host, boolean deferred) throws java.net.UnknownHostException, java.io.IOException{
    super(CLSID, IEnumConfig.IID, host, null);
  }

  protected IEnumConfigProxy(String CLSID, String iid, String host, AuthInfo authInfo) throws java.io.IOException {
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
   * initialize. method Initialize
   *
   * @param     config_path A Variant (in, optional, pass null if not required)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initialize  (
              Object config_path) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { config_path, zz_retVal };
        vtblInvoke("initialize", 7, zz_parameters);
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
   * getEnumWithValue. method GetEnumWithValue
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_name The enum_name (in)
   * @param     enum_value The enum_value (in)
   * @return    return value.  The name
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumWithValue  (
              String enum_space,
              String enum_name,
              String enum_value) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { enum_space, enum_name, enum_value, zz_retVal };
        vtblInvoke("getEnumWithValue", 8, zz_parameters);
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
   * getEnumSpace. method GetEnumSpace
   *
   * @param     __MIDL_0023 The __MIDL_0023 (in)
   * @return    return value.  An reference to a IMTEnumSpace
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumSpace getEnumSpace  (
              String __MIDL_0023) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTEnumSpace zz_retVal[] = { null };
        Object zz_parameters[] = { __MIDL_0023, zz_retVal };
        vtblInvoke("getEnumSpace", 9, zz_parameters);
        return (IMTEnumSpace)zz_retVal[0];
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
   * writeNewEnumSpaceWithFileName. method WriteNewEnumSpaceWithFileName
   *
   * @param     file The file (in)
   * @param     enum_space An reference to a IMTEnumSpace (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeNewEnumSpaceWithFileName  (
              String file,
              IMTEnumSpace enum_space) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { file, enum_space, zz_retVal };
        vtblInvoke("writeNewEnumSpaceWithFileName", 10, zz_parameters);
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
   * getFQN. method GetFQN
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_name The enum_name (in)
   * @param     enum_value The enum_value (in)
   * @return    return value.  The name
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getFQN  (
              String enum_space,
              String enum_name,
              String enum_value) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { enum_space, enum_name, enum_value, zz_retVal };
        vtblInvoke("getFQN", 11, zz_parameters);
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
   * updateEnumSpace. method UpdateEnumSpace
   *
   * @param     enum_space An reference to a IMTEnumSpace (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void updateEnumSpace  (
              IMTEnumSpace enum_space) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { enum_space, zz_retVal };
        vtblInvoke("updateEnumSpace", 12, zz_parameters);
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
   * getEnumSpaces. method GetEnumSpaces
   *
   * @return    return value.  An reference to a IMTEnumSpaceCollection
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumSpaceCollection getEnumSpaces  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTEnumSpaceCollection zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("getEnumSpaces", 13, zz_parameters);
        return (IMTEnumSpaceCollection)zz_retVal[0];
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
   * writeNewEnumSpace. method WriteNewEnumSpace
   *
   * @param     enum_space An reference to a IMTEnumSpace (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeNewEnumSpace  (
              IMTEnumSpace enum_space) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { enum_space, zz_retVal };
        vtblInvoke("writeNewEnumSpace", 14, zz_parameters);
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
   * validEnumSpace. method ValidEnumSpace
   *
   * @param     name The name (in)
   * @return    return value.  The ret
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int validEnumSpace  (
              String name) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { name, zz_retVal };
        vtblInvoke("validEnumSpace", 15, zz_parameters);
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
   * validEnumType. method ValidEnumType
   *
   * @param     __MIDL_0025 The __MIDL_0025 (in)
   * @param     __MIDL_0026 The __MIDL_0026 (in)
   * @return    return value.  The ret
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int validEnumType  (
              String __MIDL_0025,
              String __MIDL_0026) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { __MIDL_0025, __MIDL_0026, zz_retVal };
        vtblInvoke("validEnumType", 16, zz_parameters);
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
   * getEnumType. method GetEnumType
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_type The enum_type (in)
   * @return    return value.  An reference to a IMTEnumType
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumType getEnumType  (
              String enum_space,
              String enum_type) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTEnumType zz_retVal[] = { null };
        Object zz_parameters[] = { enum_space, enum_type, zz_retVal };
        vtblInvoke("getEnumType", 17, zz_parameters);
        return (IMTEnumType)zz_retVal[0];
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
   * getEnumerators. method GetEnumerators
   *
   * @param     enum_space The enum_space (in)
   * @param     enum_type The enum_type (in)
   * @return    return value.  An reference to a IMTEnumeratorCollection
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumeratorCollection getEnumerators  (
              String enum_space,
              String enum_type) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        IMTEnumeratorCollection zz_retVal[] = { null };
        Object zz_parameters[] = { enum_space, enum_type, zz_retVal };
        vtblInvoke("getEnumerators", 18, zz_parameters);
        return (IMTEnumeratorCollection)zz_retVal[0];
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
   * initializeFromHost. method InitializeFromHost
   *
   * @param     host The host (in)
   * @param     relative_path The relative_path (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initializeFromHost  (
              String host,
              String relative_path) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { host, relative_path, zz_retVal };
        vtblInvoke("initializeFromHost", 19, zz_parameters);
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
   * read. method Read
   *
   * @param     file The file (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void read  (
              String file) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { file, zz_retVal };
        vtblInvoke("read", 20, zz_parameters);
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
   * loadEnumeration. method LoadEnumeration
   *
   * @param     from_file_path The from_file_path (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void loadEnumeration  (
              String from_file_path) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { from_file_path, zz_retVal };
        vtblInvoke("loadEnumeration", 21, zz_parameters);
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
   * initializeWithFileName. method InitializeWithFileName
   *
   * @param     master_file_full_path The master_file_full_path (in)
   * @param     host_name A Variant (in, optional, pass null if not required)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initializeWithFileName  (
              String master_file_full_path,
              Object host_name) throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { master_file_full_path, host_name, zz_retVal };
        vtblInvoke("initializeWithFileName", 22, zz_parameters);
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
   * enumerateFQN. method EnumerateFQN
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void enumerateFQN  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        Object zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("enumerateFQN", 23, zz_parameters);
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
   * nextFQN. method NextFQN
   *
   * @return    return value.  The fQN
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String nextFQN  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        String zz_retVal[] = { null };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("nextFQN", 24, zz_parameters);
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
   * fQNCollectionEnd. method FQNCollectionEnd
   *
   * @return    return value.  The ret
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int fQNCollectionEnd  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("fQNCollectionEnd", 25, zz_parameters);
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
   * fQNCount. method FQNCount
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int fQNCount  () throws java.io.IOException, com.linar.jintegra.AutomationException{
    while(true) {
      try {
        int zz_retVal[] = { 0 };
        Object zz_parameters[] = { zz_retVal };
        vtblInvoke("fQNCount", 26, zz_parameters);
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

  /** Dummy reference from interface to proxy to make sure proxy gets compiled */
  static final int xxDummy = 0;

  static {
    com.linar.jintegra.InterfaceDesc.add("3ada858d-01c6-11d4-95a0-00b0d025b121", IEnumConfigProxy.class, null, 7, new com.linar.jintegra.MemberDesc[] {
        new com.linar.jintegra.MemberDesc("initialize",
            new Class[] { Object.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("config_path", 12, 10, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getEnumWithValue",
            new Class[] { String.class, String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_space", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_name", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_value", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("name", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getEnumSpace",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("__MIDL_0023", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_space", 29, 20, 4, IMTEnumSpace.IID, IMTEnumSpaceProxy.class) }),
        new com.linar.jintegra.MemberDesc("writeNewEnumSpaceWithFileName",
            new Class[] { String.class, IMTEnumSpace.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("file", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_space", 29, 2, 4, IMTEnumSpace.IID, IMTEnumSpaceProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getFQN",
            new Class[] { String.class, String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_space", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_name", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_value", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("name", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("updateEnumSpace",
            new Class[] { IMTEnumSpace.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_space", 29, 2, 4, IMTEnumSpace.IID, IMTEnumSpaceProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getEnumSpaces",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("__MIDL_0024", 29, 20, 4, IMTEnumSpaceCollection.IID, IMTEnumSpaceCollectionProxy.class) }),
        new com.linar.jintegra.MemberDesc("writeNewEnumSpace",
            new Class[] { IMTEnumSpace.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_space", 29, 2, 4, IMTEnumSpace.IID, IMTEnumSpaceProxy.class), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("validEnumSpace",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("name", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("ret", 22, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("validEnumType",
            new Class[] { String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("__MIDL_0025", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("__MIDL_0026", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("ret", 22, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("getEnumType",
            new Class[] { String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_space", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_type", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("pEnumType", 29, 20, 4, IMTEnumType.IID, IMTEnumTypeProxy.class) }),
        new com.linar.jintegra.MemberDesc("getEnumerators",
            new Class[] { String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("enum_space", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("enum_type", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("coll", 29, 20, 4, IMTEnumeratorCollection.IID, IMTEnumeratorCollectionProxy.class) }),
        new com.linar.jintegra.MemberDesc("initializeFromHost",
            new Class[] { String.class, String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("host", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("relative_path", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("read",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("file", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("loadEnumeration",
            new Class[] { String.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("from_file_path", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("initializeWithFileName",
            new Class[] { String.class, Object.class, },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("master_file_full_path", 8, 2, 8, null, null), 
              new com.linar.jintegra.Param("host_name", 12, 10, 8, null, null), 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("enumerateFQN",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("", 24, 0, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("nextFQN",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("fQN", 8, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("fQNCollectionEnd",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("ret", 22, 20, 8, null, null) }),
        new com.linar.jintegra.MemberDesc("fQNCount",
            new Class[] { },
            new com.linar.jintegra.Param[] { 
              new com.linar.jintegra.Param("pVal", 22, 20, 8, null, null) }),
});  }
}
