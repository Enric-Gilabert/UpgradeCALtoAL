table 68241 "Table Version Field"
{
    // ©Dynamics.is

    Caption = 'Table Version Field';
    DrillDownPageID = "Table Version Fields";
    LookupPageID = "Table Version Fields";

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
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
        }
        field(4; "Field Type"; Text[30])
        {
            Caption = 'Field Type';
            DataClassification = SystemMetadata;
        }
        field(6; "Table Name"; Text[50])
        {
            Caption = 'Table Name';
            DataClassification = SystemMetadata;
        }
        field(7; "Field Name"; Text[50])
        {
            Caption = 'Field Name';
            DataClassification = SystemMetadata;
        }
        field(8; "Option String 1"; Text[250])
        {
            Caption = 'Option String 1';
            DataClassification = SystemMetadata;
        }
        field(9; "Option String 2"; Text[250])
        {
            Caption = 'Option String 2';
            DataClassification = SystemMetadata;
        }
        field(10; "Option String 3"; Text[250])
        {
            Caption = 'Option String 3';
            DataClassification = SystemMetadata;
        }
        field(11; "Option String 4"; Text[250])
        {
            Caption = 'Option String 4';
            DataClassification = SystemMetadata;
        }
        field(12; "Auto Increment"; Boolean)
        {
            Caption = 'Auto Increment';
            DataClassification = SystemMetadata;
        }
        field(13; "Data Per Company"; Boolean)
        {
            Caption = 'Data Per Company';
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                TableProperty: Record "Table Version Field";
            begin
                TableProperty.SetRange("Table Version Code", "Table Version Code");
                TableProperty.SetRange("Table No.", "Table No.");
                TableProperty.SetFilter("Field No.", '<>%1', "Field No.");
                if not TableProperty.IsEmpty() then
                    TableProperty.ModifyAll("Data Per Company", "Data Per Company");
            end;
        }
        field(14; "SubType"; Option)
        {
            Caption = 'Sub Type';
            DataClassification = SystemMetadata;
            OptionCaption = ' ,User-Defined,Bitmap,Memo,Json', Locked = true;
            OptionMembers = " ","User-Defined",Bitmap,Memo,Json;
        }
        field(15; "Compressed"; Boolean)
        {
            Caption = 'Compressed';
            DataClassification = SystemMetadata;
        }
        field(16; "SQL Data Type"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'SQL Data Type';
        }
    }

    keys
    {
        key(Key1; "Table Version Code", "Table No.", "Field No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetFieldDetails(var FieldDetails: array[3] of Text)
    begin
        FieldDetails[1] := "Field Name";
        FieldDetails[2] := "Field Type";
        FieldDetails[3] := GetOptionString();
    end;

    procedure GetUpgradeTempTableName() TempTableName: Text[30]
    var
        TableVersionField: Record "Table Version Field";
        TempNo: Integer;
        ConflictFound: Boolean;
    begin
        TempTableName := CopyStr('UPG ' + Format("Table No.", 0, 9) + "Table Name", 1, 30);
        ConflictFound := true;
        TempNo := 1;
        TableVersionField.SetCurrentKey("Table Version Code", "Table Name");
        while ConflictFound do begin
            TableVersionField.SetRange("Table Version Code", "Table Version Code");
            TableVersionField.SetRange("Table Name", TempTableName);
            ConflictFound := TableVersionField.FindFirst();
            if ConflictFound then begin
                TempTableName := CopyStr(TempTableName, 1, 28) + Format(TempNo, 2, '<Integer,2><Filler Character,0>');
                TempNo += 1;
            end;
        end;
    end;

    procedure SetOptionString(NewOptionString: Text)
    begin
        "Option String 1" := CopyStr(NewOptionString, 1, 250);
        "Option String 2" := CopyStr(NewOptionString, 251, 250);
        "Option String 3" := CopyStr(NewOptionString, 501, 250);
        "Option String 4" := CopyStr(NewOptionString, 751, 250);
    end;

    procedure GetOptionString(): Text[1000]
    begin
        exit("Option String 1" + "Option String 2" + "Option String 3" + "Option String 4");
    end;

    procedure BuildVersionTableList(VersionCode: Code[20]; var TempVersionTable: Record "Table Version Field")
    var
        TableVersion: Record "Table Version Field";
    begin
        TableVersion.SetRange("Table Version Code", VersionCode);
        if TableVersion.Find('-') then
            repeat
                TempVersionTable := TableVersion;
                TempVersionTable.Insert();
                TableVersion.SetRange("Table No.", TableVersion."Table No.");
                TableVersion.FindLast();
                TableVersion.SetRange("Table No.");
            until TableVersion.Next() = 0;
    end;

    procedure HasBlobField(VersionCode: Code[20]; TableNo: Integer): Boolean
    var
        TableVersion: Record "Table Version Field";
    begin
        TableVersion.SetRange("Table Version Code", VersionCode);
        TableVersion.SetRange("Table No.", TableNo);
        TableVersion.SetRange("Field Type", 'BLOB');
        exit(not TableVersion.IsEmpty());
    end;

    procedure IsCompatableType(SourceType: Text[30]; DestinationType: Text[30]): Boolean
    var
        SourceTypeLength: Integer;
        DestinationTypeLength: Integer;
    begin
        SplitType(SourceType, SourceTypeLength);
        SplitType(DestinationType, DestinationTypeLength);
        case true of
            (SourceType in ['Code', 'Text']) and (DestinationType in ['Code', 'Text']):
                exit(true);
            (SourceType = 'Integer') and (DestinationType = 'BigInteger'):
                exit(true);
            (SourceType = 'Option') and (DestinationType = 'Option'):
                exit(true);
            (SourceType = 'Option') and (DestinationType = 'Integer'):
                exit(true);
        end;
    end;

    local procedure SplitType(var FieldType: Text[30]; var FieldLength: Integer)
    begin
        if CopyStr(FieldType, 1, 4) in ['Code', 'Text'] then begin
            Evaluate(FieldLength, CopyStr(FieldType, 5));
            FieldType := CopyStr(FieldType, 1, 4);
        end;
    end;

    procedure AddProperty(FieldName: Text; FieldValue: Variant)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(Rec);
        DataTypeManagement.FindFieldByName(RecRef, FieldRef, FieldName);
        FieldRef.Value := FieldValue;
        RecRef.SetTable(Rec);
    end;

    procedure GetOptionStringFromField(FieldName: Text): Text
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open(DATABASE::"Table Version Field");
        DataTypeManagement.FindFieldByName(RecRef, FieldRef, FieldName);
        exit(FieldRef.OptionMembers());
    end;
}

