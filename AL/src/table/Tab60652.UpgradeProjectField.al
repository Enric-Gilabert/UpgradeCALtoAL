table 60652 "Upgrade Project Field"
{
    Caption = 'Upgrade Project Field';
    DataPerCompany = false;
    LookupPageId = "Upgrade Project Fields";

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
            TableRelation = "Upgrade Project App Field"."App Field ID" where ("App Package Id" = field ("App Package Id"), "App Table Id" = field ("App Table Id"));
            NotBlank = true;
            trigger OnValidate()
            begin
                CalcFields("App Field Name");
            end;

        }
        field(4; "Upgrade Table Id"; Integer)
        {
            Caption = 'Upgrade Table Id';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = AllObj."Object ID" WHERE ("Object Type" = CONST (Table));
            trigger OnValidate()
            begin
                CalcFields("Upgrade Table Name");
            end;
        }
        field(6; "Upgrade Field ID"; Integer)
        {
            Caption = 'Upgrade Field ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Field."No." WHERE (TableNo = FIELD ("Upgrade Table ID"));
            trigger OnValidate()
            begin
                CalcFields("Upgrade Field Name");
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
            CalcFormula = Lookup (Field.FieldName WHERE (TableNo = FIELD ("App Table ID"), "No." = FIELD ("App Field ID")));
            Caption = 'App Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Upgrade Table Name"; Text[250])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE ("Object Type" = CONST (Table), "Object ID" = FIELD ("Upgrade Table ID")));
            Caption = 'Upgrade Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Upgrade Field Name"; Text[250])
        {
            CalcFormula = Lookup (Field."FieldName" WHERE (TableNo = FIELD ("Upgrade Table ID"), "No." = FIELD ("Upgrade Field ID")));
            Caption = 'Upgrade Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Transformation Rule"; Code[20])
        {
            Caption = 'Transformation Rule';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Transformation Rule";
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

    procedure GetWarning(): Text
    var
        ADVUpgradeProjAppField: Record "Upgrade Project App Field";
        AppFld: Record Field;
        UpgFld: Record Field;
    begin
        if "Upgrade Field ID" = 0 then exit(FieldDefMismatchMsg);
        if GetIsPrimaryKeyField() then exit;
        if not AppFld.Get("App Table Id", "App Field ID") then
            exit(ExternalFieldMsg);
        if not ADVUpgradeProjAppField.Get("App Package Id", "App Table Id", "App Field ID") then
            exit(ExternalFieldMsg);
        UpgFld.Get("Upgrade Table Id", "Upgrade Field ID");
        if AppFld.Enabled <> UpgFld.Enabled then exit(FieldDefMismatchMsg);
        if AppFld.Class < UpgFld.Class then exit(FieldDefMismatchMsg);
        if "Transformation Rule" <> '' then exit;
        if AppFld.Len < UpgFld.Len then exit(FieldMismatchMsg);
        if AppFld.Type <> UpgFld.Type then exit(FieldMismatchMsg);
    end;

    procedure GetIsPrimaryKeyField(): Boolean
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        PrimaryKeyRef: KeyRef;
        FieldIndex: Integer;
    begin
        RecRef.Open("App Table Id");
        PrimaryKeyRef := RecRef.KeyIndex(1);
        for FieldIndex := 1 to PrimaryKeyRef.FieldCount() do begin
            FldRef := PrimaryKeyRef.FieldIndex(FieldIndex);
            if FldRef.Number() = "App Field ID" then exit(true);
        end;
    end;

    var
        FieldMismatchMsg: Label 'Field Type Mismatch';
        FieldDefMismatchMsg: Label 'Field Definition Mismatch';
        ExternalFieldMsg: Label 'Field not part of this App';

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}