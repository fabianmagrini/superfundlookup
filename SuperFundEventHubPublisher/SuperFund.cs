using System;

namespace SuperFundEventHubPublisher
{
    class SuperFund
    {
        public string ABN;

        public string FundName;       
        
        public string USI;       
        
        public string ProductName;       
        
        public string ContributionRestrictions;       

        public string FromDate;

        public string ToDate;
        
        public override String ToString() {
            return String.Format("{0}|{1}|{2}|{3}|{4}|{5}|{6}", ABN, FundName, USI, ProductName, ContributionRestrictions, FromDate, ToDate);
        }
    }
}