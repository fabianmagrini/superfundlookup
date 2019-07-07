using System;

namespace SuperFundCLI
{
    [AttributeUsage(AttributeTargets.Field)]
    class LayoutAttribute : Attribute
    {
        public int Index { get; private set; }
        public int Length { get; private set; }
        
        public LayoutAttribute( int index, int length )
        {
            Index = index;
            Length = length;
        }
    }
}