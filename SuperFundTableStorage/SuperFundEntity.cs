using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.WindowsAzure.Storage.Table; 

namespace SuperFundTableStorage
{
    public class SuperFundEntity : TableEntity
    {
        public SuperFundEntity()
        {
        } 
        public string ABN { get; set; }
        public string FundName { get; set; }
        public string USI { get; set; }
        public string ProductName { get; set; }       
        public string ContributionRestrictions { get; set; }       
        public string From { get; set; }
        public string To { get; set; }
    }
}