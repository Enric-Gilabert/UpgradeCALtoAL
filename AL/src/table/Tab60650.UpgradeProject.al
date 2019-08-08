table 60650 "Upgrade Project"
{

    Caption = 'Upgrade Project';
    DataPerCompany = false;
    LookupPageID = "Upgrade Projects";

    fields
    {
        field(1; "App Id"; Guid)
        {
            Caption = 'App Id';
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "NAV App Installed App";
            trigger OnValidate()
            var
                InstalledApps: Record "NAV App Installed App";
            begin
                InstalledApps.Get("App Id");
                Description := InstalledApps.Name;
                "App Package Id" := InstalledApps."Package ID";
            end;
        }
        field(2; "Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "App Package Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }

    }

    keys
    {
        key(Key1; "App Id")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Description)
        {
        }
        fieldgroup(Brick; Description)
        {
        }
    }


    trigger OnInsert()
    begin

    end;

    trigger OnDelete()
    var
        ADVUpgradeProjTable: Record "Upgrade Project Table";
        ActivityLog: Record "Activity Log";
    begin
        ADVUpgradeProjTable.SetRange("App Package Id", "App Package Id");
        ADVUpgradeProjTable.DeleteAll(true);
        ActivityLog.SetRange("Record ID", RecordId());
        ActivityLog.DeleteAll();
    end;

}

