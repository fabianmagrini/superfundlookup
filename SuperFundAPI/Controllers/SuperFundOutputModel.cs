using System;

namespace SuperFundAPI.Controllers
{
    public class SuperFundOutputModel 
    {
        public string ABN { get; set; }
        public string FundName { get; set; }
        public string USI { get; set; }
        public string ProductName { get; set; }       
        public string ContributionRestrictions { get; set; }       
        public string From { get; set; }
        public string To { get; set; }
    }
}