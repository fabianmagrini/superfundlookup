namespace SuperFundEventHubConsumer
{
    public class EventHubConfig
    {
        public string ConnectionString { get; set; }
        public string Name { get; set; }
        public string StorageContainerName { get; set; }
        public string StorageAccountName { get; set; }
        public string StorageAccountKey { get; set; }
    }
}