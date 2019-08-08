table 68233 "Data Upgrade Setup"
{
    Caption = 'Data Upgrade Setup';

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(20; "Data Upgrade Tool Enabled"; Boolean)
        {
            Caption = 'Data Upgrade Tool Enabled';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

