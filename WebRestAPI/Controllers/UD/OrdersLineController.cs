using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebRest.EF.Data;
using WebRest.EF.Models;

namespace WebRestAPI.Controllers.UD;

[ApiController]
[Route("api/[controller]")]
public class OrdersLineController : ControllerBase, iController<OrdersLine>
{
    private WebRestOracleContext _context;
    // Create a field to store the mapper object
    private readonly IMapper _mapper;

    public OrdersLineController(WebRestOracleContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    [HttpGet]
    [Route("Get")]
    public async Task<IActionResult> Get()
    {

        List<OrdersLine>? lst = null;
        lst = await _context.OrdersLines.ToListAsync();
        return Ok(lst);
    }


    [HttpGet]
    [Route("Get/{ID}")]
    public async Task<IActionResult> Get(string ID)
    {
        var itm = await _context.OrdersLines.Where(x => x.OrdersLineId == ID).FirstOrDefaultAsync();
        return Ok(itm);
    }


    [HttpDelete]
    [Route("Delete/{ID}")]
    public async Task<IActionResult> Delete(string ID)
    {
        var itm = await _context.OrdersLines.Where(x => x.OrdersLineId == ID).FirstOrDefaultAsync();
#pragma warning disable CS8604 // Possible null reference argument.
        _ = _context.OrdersLines.Remove(itm);
#pragma warning restore CS8604 // Possible null reference argument.
        await _context.SaveChangesAsync();
        return Ok();
    }

    [HttpPut]
    public async Task<IActionResult> Put([FromBody] OrdersLine _OrdersLine)
    {
        var trans = _context.Database.BeginTransaction();

        try
        {
            var itm = await _context.OrdersLines.AsNoTracking()
            .Where(x => x.OrdersLineId == _OrdersLine.OrdersLineId)
            .FirstOrDefaultAsync();


            if (itm != null)
            {
                itm = _mapper.Map<OrdersLine>(_OrdersLine);

                
                        // itm.AddressFirstName = _Address.AddressFirstName;
                        // itm.AddressMiddleName = _Address.AddressMiddleName;
                        // itm.AddressLastName = _Address.AddressLastName;
                        // itm.AddressDateOfBirth = _Address.AddressDateOfBirth;
                        // itm.AddressOrderLineId = _Address.AddressOrderLineId;

                _context.OrdersLines.Update(itm);
                await _context.SaveChangesAsync();
                trans.Commit();

            }
        }
        catch (Exception ex)
        {
            trans.Rollback();
            return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
        }

        return Ok();

    }

    [HttpPost]
    public async Task<IActionResult> Post([FromBody] OrdersLine _OrdersLine)
    {
        var trans = _context.Database.BeginTransaction();

        try
        {
            _OrdersLine.OrdersLineId = Guid.NewGuid().ToString().ToUpper().Replace("-", "");
            _context.OrdersLines.Add(_OrdersLine);
            await _context.SaveChangesAsync();
            trans.Commit();
        }
        catch (Exception ex)
        {
            trans.Rollback();
            return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
        }

        return Ok();
    }

}