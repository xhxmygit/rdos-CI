namespace RDOSWebAPI.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class initial : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                "dbo.HVServers",
                c => new
                    {
                        HostName = c.String(nullable: false, maxLength: 128),
                        UserName = c.String(),
                        Password = c.String(),
                        SwitchName = c.String(),
                        VMAdminRoot = c.String(),
                        VMRoot = c.String(),
                        VMVHDRoot = c.String(),
                        VMSnapshotRoot = c.String(),
                        RDOSVHDRoot = c.String(),
                        NICElementName = c.String(),
                        KDNICElementName = c.String(),
                        Locked = c.Boolean(nullable: false),
                    })
                .PrimaryKey(t => t.HostName);           
        }
        
        public override void Down()
        {
            DropTable("dbo.HVServers");
        }
    }
}
