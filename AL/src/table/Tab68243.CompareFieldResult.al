table 68243 "Compare Field Result"
{
    // ©Dynamics.is

    Caption = 'Compare Field Result';
    DrillDownPageID = "Version Compare Field Res.";
    LookupPageID = "Version Compare Field Res.";

    fields
    {
        field(1; "Compare Version Code"; Code[20])
        {
            Caption = 'Compare Version Code';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = "Version Comparison";
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(4; "Result"; Option)
        {
            Caption = 'Result';
            DataClassification = SystemMetadata;
            Editable = false;
            OptionCaption = 'Identical,New,Modified,Deleted';
            OptionMembers = Identical,New,Modified,Deleted;
        }
        field(5; "Copy Value From Field No."; Integer)
        {
            BlankZero = true;
            Caption = 'Copy Value From Field No.';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnLookup()
            begin
                FilterSourceTable();
                if TableVersion.FindFirst() then
                    if PAGE.RunModal(PAGE::"Table Version Fields", TableVersion) = ACTION::LookupOK then
                        Validate("Copy Value From Field No.", TableVersion."Field No.");
            end;

            trigger OnValidate()
            begin
                if "Copy Value From Field No." = 0 then exit;
                TestField(Result, Result::New);
                FilterSourceTable();
                TableVersion.SetRange("Field No.", "Copy Value From Field No.");
                TableVersion.FindFirst();
            end;
        }
        field(6; "Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Table Result Filter"; Option)
        {
            Caption = 'Table Result Filter';
            Editable = false;
            FieldClass = FlowFilter;
            OptionCaption = 'Identical,New,Modified,Deleted';
            OptionMembers = Identical,New,Modified,Deleted;
        }
    }

    keys
    {
        key(Key1; "Compare Version Code", "Table No.", "Field No.")
        {
        }
        key(Key2; Result, "Compare Version Code")
        {

        }
    }

    fieldgroups
    {
    }

    var
        VersionCompare: Record "Version Comparison";
        TableVersion: Record "Table Version Field";
        CompareTableResult: Record "Compare Table Result";
        CopyFromFieldNotFoundErr: Label 'Copy From Field %2 is not available in table %1';


    local procedure GetVersion()
    begin
        if VersionCompare.Code <> "Compare Version Code" then
            VersionCompare.Get("Compare Version Code");
        GetCompareTableResult();
    end;

    local procedure GetCompareTableResult()
    begin
        FilterGroup(2);
        if (CompareTableResult."Compare Version Code" <> "Compare Version Code") or (CompareTableResult."Table No." <> "Table No.") then
            if GetFilter("Table Result Filter") <> '' then
                CompareTableResult.Get("Compare Version Code", "Table No.", GetRangeMax("Table Result Filter"))
            else begin
                CompareTableResult.SetRange("Compare Version Code", "Compare Version Code");
                CompareTableResult.SetRange("Table No.", "Table No.");
                CompareTableResult.FindFirst();
            end;
        FilterGroup(0);
    end;

    procedure GetSourceTableName(): Text[50]
    begin
        FilterSourceTable();
        if TableVersion.FindFirst() then
            exit(TableVersion."Table Name")
        else
            exit('');
    end;

    procedure GetDestinationTableName(): Text[50]
    begin
        FilterDestinationTable();
        if TableVersion.FindFirst() then
            exit(TableVersion."Table Name")
        else
            exit('');
    end;

    procedure GetSourceFieldName(): Text[50]
    begin
        FilterSourceTableField();
        if TableVersion.FindFirst() then
            exit(TableVersion."Field Name")
        else
            exit('');
    end;

    procedure GetDestinationFieldName(): Text[50]
    begin
        FilterDestinationTableField();
        if TableVersion.FindFirst() then
            exit(TableVersion."Field Name")
        else
            exit('');
    end;

    procedure GetSourceFieldType(): Text[30]
    begin
        FilterSourceTableField();
        if TableVersion.FindFirst() then
            exit(TableVersion."Field Type")
        else
            exit('');
    end;

    procedure GetDestinationFieldType(): Text[30]
    begin
        FilterDestinationTableField();
        if TableVersion.FindFirst() then
            exit(TableVersion."Field Type")
        else
            exit('');
    end;

    procedure GetSourceFieldDetails(var SourceFieldDetails: array[3] of Text)
    begin
        FilterSourceTableField();
        if TableVersion.FindFirst() then
            TableVersion.GetFieldDetails(SourceFieldDetails)
        else
            Clear(SourceFieldDetails);
    end;

    procedure GetDestinationFieldDetails(var DestinationFieldDetails: array[3] of Text)
    begin
        FilterDestinationTableField();
        if TableVersion.FindFirst() then
            TableVersion.GetFieldDetails(DestinationFieldDetails)
        else
            Clear(DestinationFieldDetails);
    end;

    local procedure FilterDestinationTable()
    begin
        GetVersion();
        VersionCompare.TestField("Destination Version Code");
        TableVersion.FilterGroup(2);
        TableVersion.SetRange("Table Version Code", VersionCompare."Destination Version Code");
        TableVersion.SetRange("Table No.", "Table No.");
        TableVersion.SetRange("Field No.");
        TableVersion.FilterGroup(0);
    end;

    local procedure FilterDestinationTableField()
    begin
        FilterDestinationTable();
        TableVersion.FilterGroup(2);
        TableVersion.SetRange("Field No.", "Field No.");
        TableVersion.FilterGroup(0);
    end;

    local procedure FilterSourceTable()
    begin
        GetVersion();
        TableVersion.FilterGroup(2);
        TableVersion.SetRange("Table Version Code", VersionCompare."Source Version Code");

        if (CompareTableResult.Result in [CompareTableResult.Result::New, CompareTableResult.Result::Modified]) and (CompareTableResult."Upgrade Table ID" <> 0) then
            TableVersion.SetRange("Table No.", CompareTableResult.GetUpgradeTableSourceID())
        else
            TableVersion.SetRange("Table No.", "Table No.");

        TableVersion.SetRange("Field No.");
        TableVersion.FilterGroup(0);
        TableVersion.SetRange("Field No.");
    end;

    local procedure FilterSourceTableField()
    begin
        FilterSourceTable();
        TableVersion.FilterGroup(2);
        TableVersion.SetRange("Field No.", "Field No.");
        TableVersion.FilterGroup(0);
    end;

    procedure VerifyFieldActions(Suffix: Text) ErrorText: Text
    begin
        if "Copy Value From Field No." = 0 then exit('');
        FilterSourceTable();
        TableVersion.SetRange("Field No.", "Copy Value From Field No.");
        if TableVersion.IsEmpty() then
            ErrorText += StrSubstNo(CopyFromFieldNotFoundErr, "Table No.", "Copy Value From Field No.") + Suffix + VersionCompare.GetCrLf();
    end;

    procedure LookupTableResult()
    begin
        GetVersion();
        PAGE.Run(PAGE::"Version Compare Table Res.", CompareTableResult);
    end;
}

