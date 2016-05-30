using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace RDOSWebAPI.Models
{
    public class HVServer
    {
        [Key]
        public string HostName {
            get
            {
                return _hostname.ToUpper();
            }

            
            set{
                _hostname = value.ToUpper();
            } 
        }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string SwitchName { get; set; }
        public string VMAdminRoot { get;set; }
        public string VMRoot{get;set;}
        public string VMVHDRoot {get;set;}
        public string VMSnapshotRoot {get;set;}
        public string RDOSVHDRoot { get; set; }
        public string NICElementName { get; set; }
        public string KDNICElementName { get; set; }
        public bool Locked { get; set; }
        private string _hostname;
    }
}