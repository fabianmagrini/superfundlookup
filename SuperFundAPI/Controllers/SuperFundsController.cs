using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using SuperFundTableStorage;

namespace SuperFundAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SuperFundsController : ControllerBase
    {
        private readonly ISuperFundLookupRepository<SuperFundEntity> repository;

        public SuperFundsController(ISuperFundLookupRepository<SuperFundEntity> repository)
        {
            this.repository = repository;
        }

        /// <summary>
        /// List all superfunds sorted by most recently updated.
        /// </summary>
        /// <remarks>add pagination</remarks>
        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var model = await this.repository.GetList();

            var outputModel = ToOutputModel(model);
            return Ok(outputModel);
        }

        /// <summary>
        /// Get a single superfund.
        /// </summary>
        /// <param name="id">The id of the superfund</param>
        [HttpGet("{id}")]
        public async Task<ActionResult<SuperFundOutputModel>> Get(string id)
        {
            var model = await this.repository.GetItem("DefaultPartitionKey", id);

            var outputModel = ToOutputModel(model);
            return Ok(outputModel);
        }

        #region " Mappings "

        private SuperFundOutputModel ToOutputModel(SuperFundEntity model)
        {
            return new SuperFundOutputModel
            {
                ABN = model.ABN,
                FundName = model.FundName,
                USI = model.USI,
                ProductName = model.ProductName,
                ContributionRestrictions = model.ContributionRestrictions,
                From = model.From,
                To = model.To
            };
        }

        private List<SuperFundOutputModel> ToOutputModel(List<SuperFundEntity> model)
        {
            return model.Select(item => ToOutputModel(item))
                        .ToList();
        }

        #endregion
    }
}
