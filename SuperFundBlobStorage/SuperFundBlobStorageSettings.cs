using System;

namespace SuperFundBlobStorage
{
    public class SuperFundBlobStorageSettings
    {
        public SuperFundBlobStorageSettings(string connectionString)
        {
            if (string.IsNullOrEmpty(connectionString))
                throw new ArgumentNullException("ConnectionString");

            this.ConnectionString = connectionString;
        }

        public string ConnectionString { get; }
    }
}