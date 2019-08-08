codeunit 60661 "Upgrade Installation Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure AddUpdateProfile()
    var
        TenantProfile: record "All Profile";
        ProfileIDTxt: Label 'DATAUPGRADETOOLS', MaxLength = 30;
        ProfileDescTxt: Label 'Data Upgrade Tools', MaxLength = 250;
    begin
        TenantProfile.setrange("App ID", GetAppId());
        TenantProfile.setrange("Role Center ID", Page::"Data Upgrade Role Center");
        if not TenantProfile.IsEmpty() then
            TenantProfile.DeleteAll();
        TenantProfile.Init();
        TenantProfile.Scope := TenantProfile.Scope::Tenant;
        TenantProfile."App ID" := GetAppId();
        TenantProfile.Description := ProfileDescTxt;
        TenantProfile."Profile ID" := ProfileIDTxt;
        TenantProfile."Role Center ID" := Page::"Data Upgrade Role Center";
        TenantProfile.Insert(true);
    end;

    procedure GetAppId(): Guid
    var
        module: ModuleInfo;
    begin
        navapp.GetCurrentModuleInfo(module);
        exit(module.Id());
    end;
}