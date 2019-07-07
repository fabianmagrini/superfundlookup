using System;
using System.IO;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Console;
using Serilog;
using Serilog.Events;

namespace SuperFundCLI
{
    class Program
    {
        static void Main(string[] args)
        {
            // Create service collection
            var serviceCollection = new ServiceCollection();
            ConfigureServices(serviceCollection);
 
            // Create service provider
            var serviceProvider = serviceCollection.BuildServiceProvider();
 
            // Run app
            serviceProvider.GetService<App>().Run();
        }
 
        private static void ConfigureServices(IServiceCollection serviceCollection)
        {
 
            // Build configuration
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", false)
                .Build();
 
            serviceCollection.AddLogging(options => 
            {
                if (options == null)
                {
                    throw new ArgumentNullException(nameof(options));
                }

                options.AddFilter((category, logLevel) => logLevel >= LogLevel.Trace);
                options.AddConsole();
                options.AddSerilog();
                options.AddDebug();
            });
 
            // Add Serilog logging           
            Log.Logger = new LoggerConfiguration()
            .ReadFrom.Configuration(configuration)
            .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
            .WriteTo.RollingFile(configuration["Serilog:LogFile"])
            .CreateLogger();
 
            // Add access to generic IConfigurationRoot
            serviceCollection.AddSingleton(configuration);
 
            // Add the App
            serviceCollection.AddTransient<App>();
        }
    }
}
