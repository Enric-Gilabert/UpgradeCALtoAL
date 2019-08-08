codeunit 60659 "Upgrade Project Upgrade"
{
    Subtype = Upgrade;

    trigger OnCheckPreconditionsPerCompany()
    begin

    end;

    trigger OnCheckPreconditionsPerDatabase()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin

    end;

    trigger OnUpgradePerDatabase()
    var
        InstallationMgt: Codeunit "Upgrade Installation Mgt.";
    begin
        InstallationMgt.AddUpdateProfile();
    end;

    trigger OnValidateUpgradePerCompany()
    begin

    end;

    trigger OnValidateUpgradePerDatabase()
    begin

    end;

}