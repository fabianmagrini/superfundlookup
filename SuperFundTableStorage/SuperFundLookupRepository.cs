using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Auth;
using Microsoft.WindowsAzure.Storage.Table;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SuperFundTableStorage
{
    public class SuperFundLookupRepository<T> : ISuperFundLookupRepository<T>
        where T : SuperFundEntity, new()
    {
        #region " Public "

        public SuperFundLookupRepository(SuperFundTableSettings settings)
        {
            this.settings = settings;
        }

        public async Task<List<T>> GetList()
        {
            //Table
            CloudTable table = await GetTableAsync();

            //Query
            TableQuery<T> query = new TableQuery<T>();

            List<T> results = new List<T>();
            TableContinuationToken continuationToken = null;
            do
            {
                TableQuerySegment<T> queryResults =
                    await table.ExecuteQuerySegmentedAsync(query, continuationToken);

                continuationToken = queryResults.ContinuationToken;
                results.AddRange(queryResults.Results);

            } while (continuationToken != null);

            return results;
        }
        
        public async Task<List<T>> GetList(string partitionKey)
        {
            //Table
            CloudTable table = await GetTableAsync();

            //Query
            TableQuery<T> query = new TableQuery<T>()
                                        .Where(TableQuery.GenerateFilterCondition("PartitionKey", 
                                                QueryComparisons.Equal, partitionKey));

            List<T> results = new List<T>();
            TableContinuationToken continuationToken = null;
            do
            {
                TableQuerySegment<T> queryResults =
                    await table.ExecuteQuerySegmentedAsync(query, continuationToken);

                continuationToken = queryResults.ContinuationToken;

                results.AddRange(queryResults.Results);

            } while (continuationToken != null);

            return results;
        }
        
        public async Task<T> GetItem(string partitionKey, string rowKey)
        {
            //Table
            CloudTable table = await GetTableAsync();

            //Operation
            TableOperation operation = TableOperation.Retrieve<T>(partitionKey, rowKey);

            //Execute
            TableResult result = await table.ExecuteAsync(operation);

            return (T)(dynamic)result.Result;
        }

        #endregion

        #region " Private "

        private readonly SuperFundTableSettings settings;

        private async Task<CloudTable> GetTableAsync()
        {
            //Account
            CloudStorageAccount storageAccount = new CloudStorageAccount(
                new StorageCredentials(this.settings.StorageAccount, this.settings.StorageKey), false);

            //Client
            CloudTableClient tableClient = storageAccount.CreateCloudTableClient();

            //Table
            CloudTable table = tableClient.GetTableReference(this.settings.TableName);
            await table.CreateIfNotExistsAsync();

            return table;
        }
        
        #endregion
    }
}