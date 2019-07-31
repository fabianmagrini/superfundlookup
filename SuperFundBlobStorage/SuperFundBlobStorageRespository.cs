using System;    
using System.Collections.Generic;    
using System.Configuration;    
using System.Linq;    
using System.Text;    
using System.Threading.Tasks;    
using Microsoft.Azure.Storage;
using Microsoft.Azure.Storage.Blob; 
namespace SuperFundBlobStorage    
{    
    public class SuperFundBlobStorageRespository    
    {    
        private readonly SuperFundBlobStorageSettings settings;

        public CloudBlobClient BlobClient    
        {    
            get;    
            set;    
        }    
        public CloudBlobContainer BlobContainer    
        {    
            get;    
            set;    
        }    
        public SuperFundBlobStorageRespository(SuperFundBlobStorageSettings settings)
        {
            this.settings = settings;
        }   
        private void GetContainer(string ContainerName)    
        {      
            var storageAccount = CloudStorageAccount.Parse(settings.ConnectionString);    
            BlobClient = storageAccount.CreateCloudBlobClient();    
            // Retrieve a reference to a container.    
            BlobContainer = BlobClient.GetContainerReference(ContainerName);    
            // Create the container if it doesn't already exist.    
            BlobContainer.CreateIfNotExists();    
        }    
        public string AddToBlobStorage(string ContainerName, byte[] FileStream)    
        {    
            GetContainer(ContainerName);    
            string blobName = Guid.NewGuid().ToString();    
            CloudBlockBlob blockBlob = BlobContainer.GetBlockBlobReference(blobName);    
            blockBlob.UploadFromByteArray(FileStream, 0, FileStream.Length);    
            return blobName;    
        }    
        public string AddToBlobStorage(string ContainerName, string Text)    
        {    
            GetContainer(ContainerName);    
            string blobName = Guid.NewGuid().ToString();    
            CloudBlockBlob blockBlob = BlobContainer.GetBlockBlobReference(blobName);    
            blockBlob.UploadText(Text);    
            return blobName;    
        }    
        public byte[] GetBytesFromBlobStorage(string ContainerName, string BlobName)    
        {    
            GetContainer(ContainerName);    
            CloudBlockBlob blockBlob = BlobContainer.GetBlockBlobReference(BlobName);    
            blockBlob.FetchAttributes();    
            byte[] byteArray = new byte[blockBlob.Properties.Length];    
            blockBlob.DownloadToByteArray(byteArray, 0);    
            return byteArray;    
        }    
        public string GetStringFromBlobStorage(string ContainerName, string BlobName)    
        {    
            GetContainer(ContainerName);    
            CloudBlockBlob blockBlob = BlobContainer.GetBlockBlobReference(BlobName);    
            blockBlob.FetchAttributes();    
            return blockBlob.DownloadText();    
        }    
    }  
}