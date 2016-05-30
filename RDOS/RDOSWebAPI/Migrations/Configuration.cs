namespace RDOSWebAPI.Migrations
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Migrations;
    using System.Linq;
    using RDOSWebAPI.Models;

    internal sealed class Configuration : DbMigrationsConfiguration<RDOSWebAPI.Models.RDOSWebAPIContext>
    {
        public Configuration()
        {
            AutomaticMigrationsEnabled = false;
        }

        protected override void Seed(RDOSWebAPI.Models.RDOSWebAPIContext context)
        {
            //  This method will be called after migrating to the latest version.

            //  You can use the DbSet<T>.AddOrUpdate() helper extension method 
            //  to avoid creating duplicate seed data. E.g.
            //
            //    context.People.AddOrUpdate(
            //      p => p.FullName,
            //      new Person { FullName = "Andrew Peters" },
            //      new Person { FullName = "Brice Lambson" },
            //      new Person { FullName = "Rowan Miller" }
            //    );
            //

            context.HVServers.AddOrUpdate(p => p.HostName,
                //new HVServer { HostName = "LISINTER-AZ5", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"f:\vm", VMVHDRoot = @"f:\vm\working_vhd", VMSnapshotRoot = @"f:\VM\Snapshot", RDOSVHDRoot = @"c:\os", Locked = false },
                //new HVServer { HostName = "LISINTER-AZ6", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"f:\vm", VMVHDRoot = @"f:\vm\working_vhd", VMSnapshotRoot = @"f:\VM\Snapshot", RDOSVHDRoot = @"c:\os", Locked = false }
                //RDOSWebAPI7
                //new HVServer { HostName = "433895B01-01L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                //new HVServer { HostName = "433895B01-02L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                //new HVServer { HostName = "433895B01-03L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false }
                //RDOSWebAPI6
                //new HVServer { HostName = "LISINTER-AZ5", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"f:\vm", VMVHDRoot = @"f:\vm\working_vhd", VMSnapshotRoot = @"f:\VM\Snapshot", RDOSVHDRoot = @"c:\os", Locked = false },
                //new HVServer { HostName = "LISINTER-AZ6", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"f:\vm", VMVHDRoot = @"f:\vm\working_vhd", VMSnapshotRoot = @"f:\VM\Snapshot", RDOSVHDRoot = @"c:\os", Locked = false },
                new HVServer { HostName = "433895B01-01L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                new HVServer { HostName = "433895B01-02L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                new HVServer { HostName = "433895B01-03L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                new HVServer { HostName = "433895B01-04L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                new HVServer { HostName = "433895B01-05L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                new HVServer { HostName = "433895B01-06L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"f:\vm", VMVHDRoot = @"f:\vm\working_vhd", VMSnapshotRoot = @"f:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                new HVServer { HostName = "433895B01-07L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false }
                //new HVServer { HostName = "433895B01-08L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                //new HVServer { HostName = "433895B01-09L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false }
                //RDOSWebAPI5
                //new HVServer { HostName = "433895B01-07L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                //new HVServer { HostName = "433895B01-08L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false },
                //new HVServer { HostName = "433895B01-09L", UserName = "administrator", Password = @"PA$$word!!", SwitchName = "CorpNet", VMAdminRoot = @"d:\vmadmin", VMRoot = @"e:\vm", VMVHDRoot = @"e:\vm\working_vhd", VMSnapshotRoot = @"e:\VM\Snapshot", RDOSVHDRoot = @"c:\os", NICElementName = "Mellanox ConnectX-3 Pro Ethernet Adapter", KDNICElementName = "", Locked = false }
                );

        }
    }
}
