using System;

namespace SuperFundCLI
{
    class SuperFundInfo
    {
        [Layout(0, 12)]
        public string ABN;

        [Layout(12, 201)]
        public string FundName;       
        
        [Layout(213, 21)]
        public string USI;       
        
        [Layout(234, 201)]
        public string ProductName;       
        
        [Layout(435, 25)]
        public string ContributionRestrictions;       
        
        [Layout(460, 11)]
        public string FromDate;

        [Layout(471, 11)]
        public string ToDate;
        
        public override String ToString() {
            return String.Format("{0}|{1}|{2}|{3}|{4}|{5}|{6}", ABN, FundName, USI, ProductName, ContributionRestrictions, FromDate, ToDate);
        }
    }
}