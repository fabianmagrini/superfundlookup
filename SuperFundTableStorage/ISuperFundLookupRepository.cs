using System.Collections.Generic;
using System.Threading.Tasks;

namespace SuperFundTableStorage
{
    public interface ISuperFundLookupRepository<T> where T : SuperFundEntity, new()
    {
        //Task Delete(string partitionKey, string rowKey);
        Task<T> GetItem(string partitionKey, string rowKey);
        Task<List<T>> GetList();
        Task<List<T>> GetList(string partitionKey);
        //Task Insert(T item);
        //Task Update(T item);
    }
}