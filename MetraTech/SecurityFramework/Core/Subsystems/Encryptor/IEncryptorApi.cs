/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Kyle C. Quest <kquest@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework
{
	public enum EncryptorEngineType
	{
		Unknown,
		RSA,
		Microsoft
	}

	/// <summary>
	/// Represents a public interface for the Encryptor subsystem.
	/// </summary>
	public interface IEncryptorApi : ISubsystemApi
	{
		////EncryptorEngineType EngineType { get; }

		//long CurrentTimeStamp { get; }

		////void Initialize(EncryptorEngineType engineType);
		////void Shutdown();

		//string Encrypt(string keyClass, string input);
		//string Decrypt(string keyClass, string input);
		//string CurrentCryptoKeyId(string keyClass);
		//string GetKeyIdFromEncryptedData(string encrypted);

		//string Hash(string keyClass, string input, string salt);
		//string HashWithKey(string keyClass, string keyId, string input, string salt);
		//string HashWithSaltBytes(string keyClass, string input, byte[] salt);
		//string HashWithKeyAndSaltBytes(string keyClass, string keyId, string input, byte[] salt);
		//bool VerifyHash(string keyClass, string input, string salt, string hash);
		//string CurrentHashKeyId(string keyClass);
		//string GetKeyIdFromHash(string hash);

		//string CreateSignature(string keyClass, string input);
		//bool VerifySignature(string keyClass, string input, string sig);

		//string CreateToken(string valueId, string valueData, string sessionId, long timestamp);
		//bool VerifyToken(string token, string valueId, string sessionId);
		//string GetTokenValue(string token, string valueId, string sessionId);
	}
}
