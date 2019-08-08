codeunit 60658 "Upgrade Project Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin

    end;

    trigger OnInstallAppPerDatabase()
    var
        ADVUpgradeProject: Record "Upgrade Project";
        InstallationMgt: Codeunit "Upgrade Installation Mgt.";
    begin
        if ADVUpgradeProject.IsEmpty() then begin
            NavApp.LoadPackageData(Database::"Upgrade Project");
            NavApp.LoadPackageData(Database::"Upgrade Project Table");
            NavApp.LoadPackageData(Database::"Upgrade Project App Field");
            NavApp.LoadPackageData(Database::"Upgrade Project Field");
        end;

        InstallationMgt.AddUpdateProfile();
    end;
}