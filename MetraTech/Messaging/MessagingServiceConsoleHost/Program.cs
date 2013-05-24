using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech;

namespace MetraTech.Messaging.MessagingServiceConsoleHost
{
  using Framework;

  internal class Program
  {
    private static MetraTech.Logger logger = new MetraTech.Logger("[MessagingServiceConsoleHost]");

    private static void Main(string[] args)
    {
      logger.LogInfo("Messaging Service Console Host starting");
      try
      {
        MessageProcessor processor = new MessageProcessor();
        processor.ReadConfigFile();
        ModifyProcessorConfigurationBasedOnCommandLineArguments(processor.Configuration, args);

        processor.Start();
        Console.WriteLine("Messaging Service Console Host is running");
        Console.WriteLine("Press 'Q' to quit");
        while (!Console.KeyAvailable || (Console.ReadKey(true)).Key != ConsoleKey.Q) ;
        Console.WriteLine("Messaging Service Console Host is stopping");
        processor.Stop();
      }
      catch (Exception ex)
      {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine(ex.Message);
        Console.WriteLine("Error when running Messaging Service Console Host. See mtlog for details");
        Console.ResetColor();
        logger.LogException("Error in ConsoleHost", ex);
      }
      logger.LogInfo("Messaging Service Console Host stopped");
    }


    public static void ModifyProcessorConfigurationBasedOnCommandLineArguments(
      MetraTech.Messaging.Framework.Configurations.Configuration config, string[] args)
    {
      // Parse the command line arguments.
      CommandLineParser parser = new CommandLineParser(args, 0, args.Length);

      try
      {
        parser.Parse();

        if (parser.OptionExists("help") || parser.OptionExists("?"))
        {
          DisplayUsage();
          Environment.Exit(0);
        }

        config.Server.Address = parser.GetStringOption("server", config.Server.Address);
        //rabbitMQVirtualHostName = parser.GetStringOption("virtualhost", rabbitMQVirtualHostName);
        config.Server.UserName = parser.GetStringOption("user", config.Server.UserName);
        config.Server.Password = parser.GetStringOption("password", config.Server.Password);
        config.Server.Port = parser.GetIntegerOption("port", config.Server.Port);

        config.MessagingServerUniqueIdentifier = parser.GetStringOption("MachineIdentifier", config.MessagingServerUniqueIdentifier);

        parser.CheckForUnusedOptions(true);
      }
      catch (CommandLineParserException ex)
      {
        Console.WriteLine("An error occurred parsing the command line arguments.");
        Console.WriteLine("{0}", ex.Message);
        DisplayUsage();
        Environment.Exit(1);
      }
    }

    private static void DisplayUsage()
    {
      Console.WriteLine("Usage:");
      Console.WriteLine("  MessagingServerConsoleHost [Parameters]");
      Console.WriteLine("");
      Console.WriteLine("Defaults: If not specified otherwise, defaults come from the MessagingService.xml config file.");
      Console.WriteLine("Parameters:");
      Console.WriteLine("--Server=<string>              Address of RabbitMQ server");
      Console.WriteLine("--User=<string>                RabbitMQ user name");
      Console.WriteLine("--Password=<string>            RabbitMQ password");
      Console.WriteLine("--Port=<integer>               RabbitMQ listenting port");
      Console.WriteLine("--MachineIdentifier=<string>   Unique identifier for this messaging server (must be unique to all running messaging servers)");
      Console.WriteLine("                               Default for this machine is " + System.Net.Dns.GetHostName());
      Console.WriteLine("");
      Console.WriteLine("Examples:");
      Console.WriteLine("    MessagingServerConsoleHost");
      Console.WriteLine("        (send 100 requests to localhost and check for reponse using defaults");
      Console.WriteLine("    MessagingServerConsoleHost --server=localhost --user=mtuser --password=MySecretPassword");
    }

  }
}
