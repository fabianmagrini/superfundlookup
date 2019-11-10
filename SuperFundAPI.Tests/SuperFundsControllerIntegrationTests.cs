using Microsoft.AspNetCore.Mvc.Testing;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using Xunit;

namespace SuperFundAPI.Tests
{
    public class SuperFundsControllerIntegrationTests  : IClassFixture<WebApplicationFactory<Startup>>
    {
        private readonly HttpClient _client;        
        public SuperFundsControllerIntegrationTests(WebApplicationFactory<Startup> factory)
        {
            _client = factory.CreateClient();
        }
        
        [Fact]
        public async Task CanGetSuperFundsReturnHttpStatusCodeOk()
        {
            var response = await _client.GetAsync("/api/superfunds/");            
            Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        }
    }
}
