using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Reflection;
using System.Linq.Expressions;
 
namespace SuperFundCLI
{
    public class FixedWidthStreamReader<T> : StreamReader where T : class
    {
        private List<Tuple<int, int, Action<T, string>>> propertySetters = new List<Tuple<int, int, Action<T, string>>>();
        
        public FixedWidthStreamReader( Stream stream ) : base( stream ) { GetSetters(); }
        public FixedWidthStreamReader( string path ) : base( path ) { GetSetters(); }
        
        private void GetSetters() 
        {
            var myType = typeof( T );
            var instance = Expression.Parameter( myType );
            var value = Expression.Parameter( typeof( object ) );
            var changeType = typeof( Convert ).GetMethod( "ChangeType", new[] { typeof( object ), typeof( Type ) } );
    
            /* Should probably do Properties here too, if I change AttributeUsage for LayoutAttribute I would */
            foreach ( var fi in myType.GetFields() )
            {
                var la = fi.GetCustomAttribute<LayoutAttribute>();
                if ( la != null )
                {
                    var convertedObject = Expression.Call( changeType, value, Expression.Constant( fi.FieldType ) );
    
                    var setter = Expression.Lambda<Action<T, string>>(
                        Expression.Assign( Expression.Field( instance, fi ), Expression.Convert( convertedObject, fi.FieldType ) ),
                        instance, value
                    );
                    
                    var prop = setter.Compile() as Action<T, string>;
                    propertySetters.Add( Tuple.Create( la.Index, la.Length, prop ) );
                }
            }
        }
    
        public new T ReadLine()
        {
            if ( Peek() < 0 ) return (T)null;
            
            return ReadT( base.ReadLine() );
        }
        
        private T ReadT( string line )
        {
            if ( string.IsNullOrEmpty( line ) ) return null;
            
            var t = Activator.CreateInstance<T>();
    
            foreach( var s in propertySetters )
            {
                var l = line.Length;
                
                if ( l > s.Item1 )
                {
                    s.Item3( t, line.Substring( s.Item1, Math.Min( s.Item2, l - s.Item1 ) ).Trim() );
                }
            }
            return t;
        }
        
        public IEnumerable<T> ReadAllLines()
        {
            string line = null;
            
            while ( !string.IsNullOrEmpty( ( line = base.ReadLine() ) ) )
            {
                yield return ReadT( line );   
            }
        }
    }
}