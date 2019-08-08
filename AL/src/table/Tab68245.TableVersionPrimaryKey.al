table 68245 "Table Version Primary Key"
{
    // ©Dynamics.is

    Caption = 'Table Version Primary Key';

    fields
    {
        field(1; "Table Version Code"; Code[20])
        {
            Caption = 'Table Version Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "Table Version";
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Field Index No."; Integer)
        {
            Caption = 'Field Index No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }
        field(6; "Table Name"; Text[50])
        {
            CalcFormula = Lookup ("Table Version Field"."Table Name" WHERE ("Table Version Code" = FIELD ("Table Version Code"),
                                                                               "Table No." = FIELD ("Table No."),
                                                                               "Field No." = FIELD ("Field No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Field Name"; Text[50])
        {
            CalcFormula = Lookup ("Table Version Field"."Field Name" WHERE ("Table Version Code" = FIELD ("Table Version Code"),
                                                                               "Table No." = FIELD ("Table No."),
                                                                               "Field No." = FIELD ("Field No.")));
            Caption = 'Field Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Table Version Code", "Table No.", "Field Index No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetPrimaryKeyList(VersionCode: Code[20]; TableNo: Integer) PrimaryKeyList: Text
    var
        TableVerionPrimaryKey: Record "Table Version Primary Key";
    begin
        TableVerionPrimaryKey.SetRange("Table Version Code", VersionCode);
        TableVerionPrimaryKey.SetRange("Table No.", TableNo);
        TableVerionPrimaryKey.SetAutoCalcFields("Field Name");
        TableVerionPrimaryKey.FindSet();
        repeat
            PrimaryKeyList += StrSubstNo('"%1",', TableVerionPrimaryKey."Field Name");
        until TableVerionPrimaryKey.Next() = 0;
        PrimaryKeyList := DelChr(PrimaryKeyList, '>', ',');
    end;
}

