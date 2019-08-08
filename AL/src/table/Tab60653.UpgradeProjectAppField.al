table 60653 "Upgrade Project App Field"
{
    Caption = 'Upgrade Project App Field';
    DataPerCompany = false;
    LookupPageId = "Upgrade Project App Fields";

    fields
    {
        field(1; "App Package Id"; Guid)
        {
            Caption = 'App Package Id';
            DataClassification = SystemMetadata;
            TableRelation = "Upgrade Project"."App Package Id";
        }
        field(2; "App Table Id"; Integer)
        {
            Caption = 'App Table Id';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = "Upgrade Project Table"."App Table Id" where ("App Package Id" = field ("App Package Id"));
            trigger OnValidate()
            begin
                CalcFields("App Table Name");
            end;
        }
        field(3; "App Field ID"; Integer)
        {
            Caption = 'App Field ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Field."No." WHERE (TableNo = FIELD ("App Table ID"));
            NotBlank = true;
            trigger OnValidate()
            begin
                CalcFields("App Field Name");
            end;

        }
        field(7; "App Table Name"; Text[250])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE ("Object Type" = CONST (Table), "Object ID" = FIELD ("App Table ID")));
            Caption = 'App Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(8; "App Field Name"; Text[250])
        {
            CalcFormula = Lookup (Field."FieldName" WHERE (TableNo = FIELD ("App Table ID"), "No." = FIELD ("App Field ID")));
            Caption = 'App Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "App Package Id", "App Table Id", "App Field ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "App Field ID", "App Field Name")
        {
        }
        fieldgroup(Brick; "App Field ID", "App Field Name")
        {
        }
    }
}