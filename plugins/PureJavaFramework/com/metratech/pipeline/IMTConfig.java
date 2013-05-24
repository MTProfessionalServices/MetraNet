package com.metratech.pipeline;

/**
 * COM Interface 'IMTConfig'. Generated 7/24/00 5:03:12 PM
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
public interface IMTConfig {
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
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * newConfiguration. method NewConfiguration
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet newConfiguration  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
              boolean[] apChecksumMatch) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * isAutoEnumConversion. property AutoEnumConversion
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean isAutoEnumConversion  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setAutoEnumConversion. property AutoEnumConversion
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setAutoEnumConversion  (
              boolean apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getUsername. property Username
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getUsername  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setUsername. property Username
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setUsername  (
              String apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getPassword. property Password
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getPassword  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setPassword. property Password
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setPassword  (
              String apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * isSecureFlag. property SecureFlag
   *
   * @return    return value.  The apConvert
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean isSecureFlag  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setSecureFlag. property SecureFlag
   *
   * @param     apConvert The apConvert (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setSecureFlag  (
              boolean apConvert) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getPort. property Port
   *
   * @return    return value.  The apPort
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getPort  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setPort. property Port
   *
   * @param     apPort The apPort (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setPort  (
              int apPort) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID9adcd81d_35fd_11d2_a1c4_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTConfigProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "9adcd81d-35fd-11d2-a1c4-006008c0e24a";
  String DISPID_1_NAME = "readConfiguration";
  String DISPID_2_NAME = "newConfiguration";
  String DISPID_3_NAME = "readConfigurationFromHost";
  String DISPID_4_NAME = "readConfigurationFromURL";
  String DISPID_5_NAME = "readConfigurationFromString";
  String DISPID_6_GET_NAME = "isAutoEnumConversion";
  String DISPID_6_PUT_NAME = "setAutoEnumConversion";
  String DISPID_7_GET_NAME = "getUsername";
  String DISPID_7_PUT_NAME = "setUsername";
  String DISPID_8_GET_NAME = "getPassword";
  String DISPID_8_PUT_NAME = "setPassword";
  String DISPID_9_GET_NAME = "isSecureFlag";
  String DISPID_9_PUT_NAME = "setSecureFlag";
  String DISPID_10_GET_NAME = "getPort";
  String DISPID_10_PUT_NAME = "setPort";
}
