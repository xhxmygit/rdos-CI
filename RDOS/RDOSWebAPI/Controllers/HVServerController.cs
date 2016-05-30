using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;
using RDOSWebAPI.Models;

namespace RDOSWebAPI.Controllers
{
    public class HVServerController : ApiController
    {
        private RDOSWebAPIContext db = new RDOSWebAPIContext();
        private Object _locker = new Object();

        /// <summary>
        /// Get all HVServer
        /// </summary>
        /// <returns></returns>
        public IQueryable<HVServer> GetHVServers()
        {
            return db.HVServers;
        }

        /// <summary>
        /// Find HVServer by hostname
        /// </summary>
        /// <param name="hostname"></param>
        /// <returns></returns>
        [ResponseType(typeof(HVServer))]
        public IHttpActionResult GetHVServer(string hostname)
        {
            HVServer hvserver = db.HVServers.Find(hostname);
            if (hvserver == null)
            {
                return NotFound();
            }

            return Ok(hvserver);
        }

        /// <summary>
        /// Get NICElementName of given server
        /// </summary>
        /// <param name="hostname"></param>
        /// <returns></returns>
        [ResponseType(typeof(string))]
        public IHttpActionResult GetHVServerNIC(string NICHost)
        {
            HVServer hvserver = db.HVServers.Find(NICHost);
            if (hvserver == null)
            {
                return NotFound();
            }

            return Ok(hvserver.NICElementName);
        }

        /// <summary>
        /// Find an unlocked HVServer
        /// </summary>
        /// <param name="Lock"></param>
        /// <returns></returns>
        [ResponseType(typeof(HVServer))]
        public IHttpActionResult GetHVServerAndLock(bool Lock)
        {
            HVServer hvserver = null;
            lock(_locker)
            {
                hvserver = db.HVServers.FirstOrDefault(p => p.Locked == false);
  
                if (hvserver == null)
                {
                    return NotFound();
                }
                hvserver.Locked = true;
                db.SaveChanges();
            }
            return Ok(hvserver);
        }

        
        /// <summary>
        /// PUT api/HVServer/[HostName], to release an locked HVServer
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public IHttpActionResult PutHVServer(string hostname)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            HVServer hvserver = null;
            hvserver = db.HVServers.FirstOrDefault(p => p.HostName.ToUpper() == hostname.ToUpper());
            if (hvserver == null)
            {
                return NotFound();
            }
            hvserver.Locked = false;
            
            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!HVServerExists(hostname))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return StatusCode(HttpStatusCode.NoContent);
        }

        /// <summary>
        /// Update HV Server Lock status
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public IHttpActionResult PutHVServer(string hostname, bool lockServer)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            HVServer hvserver = null;
            hvserver = db.HVServers.FirstOrDefault(p => p.HostName.ToUpper() == hostname.ToUpper());
            if (hvserver == null)
            {
                return NotFound();
            }
            hvserver.Locked = lockServer;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!HVServerExists(hostname))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return StatusCode(HttpStatusCode.NoContent);
        }

        /// <summary>
        /// Update HVServer
        /// </summary>
        /// <param name="id"></param>
        /// <param name="hvserver"></param>
        /// <returns></returns>
        public IHttpActionResult PutHVServer(string id, HVServer hvserver)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (id != hvserver.HostName)
            {
                return BadRequest();
            }

            db.Entry(hvserver).State = EntityState.Modified;

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!HVServerExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return StatusCode(HttpStatusCode.NoContent);
        }

        /// <summary>
        /// Add new HVServer
        /// </summary>
        /// <param name="hvserver"></param>
        /// <returns></returns>
        [ResponseType(typeof(HVServer))]
        public IHttpActionResult PostHVServer(HVServer hvserver)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            db.HVServers.Add(hvserver);

            try
            {
                db.SaveChanges();
            }
            catch (DbUpdateException)
            {
                if (HVServerExists(hvserver.HostName))
                {
                    return Conflict();
                }
                else
                {
                    throw;
                }
            }

            return CreatedAtRoute("DefaultApi", new { id = hvserver.HostName }, hvserver);
        }

        /// <summary>
        /// Delete HVServer
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        [ResponseType(typeof(HVServer))]
        public IHttpActionResult DeleteHVServer(string id)
        {
            HVServer hvserver = db.HVServers.Find(id);
            if (hvserver == null)
            {
                return NotFound();
            }

            db.HVServers.Remove(hvserver);
            db.SaveChanges();

            return Ok(hvserver);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }

        private bool HVServerExists(string id)
        {
            return db.HVServers.Count(e => e.HostName == id) > 0;
        }
    }
}