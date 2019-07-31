using Microsoft.Azure.EventHubs;
using Microsoft.Extensions.Configuration;
using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using SuperFundBlobStorage;
using Newtonsoft.Json;

namespace SuperFundEventHubPublisher
{
    class Program
    {

        private static void Main()
        {
            var builder = new ConfigurationBuilder()
               .SetBasePath(Directory.GetCurrentDirectory())
               .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
               .AddUserSecrets<Program>(); 
 
            IConfigurationRoot configuration = builder.Build();
            var eventHubConfig = new EventHubConfig();
            configuration.GetSection("EventHubConfig").Bind(eventHubConfig);

            var blobStorageConnectionString = configuration.GetSection("SuperFundBlobStorage:ConnectionString").Value;
            repository = new SuperFundBlobStorageRespository(new SuperFundBlobStorageSettings(blobStorageConnectionString));
            
            MainAsync(eventHubConfig).GetAwaiter().GetResult();
        }

        private static EventHubClient eventHubClient;
        private static SuperFundBlobStorageRespository repository;

        private static async Task MainAsync(EventHubConfig eventHubConfig)
        {
            // Creates an EventHubsConnectionStringBuilder object from the connection string, and sets the EntityPath.
            // Typically, the connection string should have the entity path in it, but this simple scenario
            // uses the connection string from the namespace.
            var connectionStringBuilder = new EventHubsConnectionStringBuilder(eventHubConfig.ConnectionString)
            {
                EntityPath = eventHubConfig.Name
            };

            eventHubClient = EventHubClient.CreateFromConnectionString(connectionStringBuilder.ToString());

            var blob = repository.GetStringFromBlobStorage("superfundcontainer", "SflUsiExtract.csv");

            int lineCount = 0;  
            foreach (string row in blob.Split('\n'))  
            {  
                if (!string.IsNullOrEmpty(row))  
                {  
                     if (lineCount > 0) {
                        string[] cells = row.Split('|');

                        var superFund = new SuperFund();
                        superFund.ABN = cells[0];
                        superFund.FundName = cells[1];
                        superFund.USI = cells[2];
                        superFund.ProductName = cells[3];
                        superFund.ContributionRestrictions = cells[4];
                        superFund.FromDate = cells[5];
                        superFund.ToDate = cells[6];
                        
                        Console.WriteLine(superFund.ToString());

                        await SendMessagesToEventHub(JsonConvert.SerializeObject(superFund));
                     }

                     lineCount++;
                }  
            }
            
            await eventHubClient.CloseAsync();

            Console.WriteLine("Press ENTER to exit.");
            Console.ReadLine();
        }

        // Creates an event hub client and sends 100 messages to the event hub.
        private static async Task SendMessagesToEventHub(string message)
        {
            try
            {
                await eventHubClient.SendAsync(new EventData(Encoding.UTF8.GetBytes(message)));
            }
            catch (Exception exception)
            {
                Console.WriteLine($"{DateTime.Now} > Exception: {exception.Message}");
            }
        }
    }
}
