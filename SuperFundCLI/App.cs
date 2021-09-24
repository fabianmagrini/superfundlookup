using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
 
namespace SuperFundCLI
{
    public class App
    {
        private readonly ILogger<App> _logger;
        private readonly ILoggerFactory _factory;
        private readonly IConfigurationRoot _config;
 
        public App(ILoggerFactory factory, IConfigurationRoot config)
        {
            _factory = factory;
            _logger = _factory.CreateLogger<App>();
            _config = config;
        }
 
        public void Run()
        {
            try
            {   
                DownloadFile("http://superfundlookup.gov.au/Tools/DownloadUsiList?download=true", "SflUsiExtract.txt");

                using (StreamWriter outputFile = new StreamWriter("SflUsiExtract.csv"))
                {
                    using( var sr = new FixedWidthStreamReader<SuperFundInfo>( "SflUsiExtract.txt") ) 
                    {
                        var info = sr.ReadLine();

                        // header line
                        outputFile.WriteLine(info.ToString());
                        //_logger.LogDebug(info.ToString());

                        // throw away 2nd line
                        info = sr.ReadLine();

                        // the rest
                        while( ( info = sr.ReadLine() ) != null )
                        {
                            outputFile.WriteLine(info.ToString());
                            //_logger.LogDebug(info.ToString());
                        }
                    }
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e.Message);
            }
        }

        private void DownloadFile(string uri, string outputPath)
        {
            using (System.Net.WebClient wc = new System.Net.WebClient())
            {
                try
                {
                    wc.DownloadFile(uri, outputPath); 
                }
                catch (System.Exception e)
                {
                    _logger.LogError(e.Message);
                }
            }

        }
    }
}