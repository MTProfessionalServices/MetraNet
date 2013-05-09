package com.metratech.sdk.utils;

import java.io.*;

/**
 * Helper application for console input.
 */
public class ConsoleApp
{	
	public static String readLine (String prompt) throws IOException
	{
		System.out.print (prompt);
		return BR.readLine();
	}

	static private InputStreamReader ISR = new InputStreamReader(System.in);
	static private BufferedReader BR = new BufferedReader (ISR);
}
