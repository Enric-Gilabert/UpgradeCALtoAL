table 68244 "Compare Table Result"
{
    // ©Dynamics.is

    Caption = 'Compare Table Result';
    DrillDownPageID = "Version Compare Table Res.";
    LookupPageID = "Version Compare Table Res.";

    fields
    {
        field(1; "Compare Version Code"; Code[20])
        {
            Caption = 'Compare Version Code';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Version Comparison";
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
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
        field(5; "Step 1 Action"; Option)
        {
            Caption = 'Step 1 Action';
            DataClassification = SystemMetadata;
            OptionCaption = 'Ignore,Copy,Move,Force,Check,Use Source Id';
            OptionMembers = Ignore,Copy,Move,Force,Check,"Use Source Id";

            trigger OnValidate()
            begin
                if Result = Result::New then
                    Error(NoStep1ActionAvailableForNewTablesTxt);

                if "Step 1 Action" in ["Step 1 Action"::Copy, "Step 1 Action"::Move] then
                    "Upgrade Table ID" := GetNextUpgradeTableID(CurrFieldNo <> FieldNo("Step 1 Action"))
                else
                    if "Step 1 Action" = "Step 1 Action"::"Use Source Id" then
                        "Upgrade Table ID" := "Table No."
                    else
                        "Upgrade Table ID" := 0;
            end;
        }
        field(6; "Step 2 Action"; Option)
        {
            Caption = 'Step 2 Action';
            DataClassification = SystemMetadata;
            OptionCaption = 'Ignore,Copy,Move';
            OptionMembers = Ignore,Copy,Move;

            trigger OnValidate()
            begin
                if "Upgrade Table ID" = 0 then
                    Error(Step2ActionOnliValidForUpgradeTablesTxt);
            end;
        }
        field(7; "Step 2 Transfer Fields"; Boolean)
        {
            Caption = 'Step 2 Transfer Fields';
            DataClassification = SystemMetadata;
        }
        field(10; "Upgrade Table ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Upgrade Table ID';
            DataClassification = SystemMetadata;

            trigger OnLookup()
            begin
                Validate("Upgrade Table ID", DestinationTableLookup("Upgrade Table ID"));
            end;
        }
        field(11; "Upgrade Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Upgrade Codeunit ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Compare Version Code", "Table No.", Result)
        {
        }
        key(Key2; "Compare Version Code", "Upgrade Table ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        CompareFieldResult.SetRange("Compare Version Code", "Compare Version Code");
        CompareFieldResult.SetRange("Table No.", "Table No.");
        if not CompareFieldResult.IsEmpty() then
            CompareFieldResult.DeleteAll();
    end;

    var
        VersionCompare: Record "Version Comparison";
        TableVersion: Record "Table Version Field";
        TableAlreadyDeletedErr: Label 'Table is already deleted in Step 1 and can''t be handled in Step 2';
        UpgradeTableIdMissingErr: Label 'Upgrade Table ID is missing';
        NoStep1ActionAvailableForNewTablesTxt: Label 'Now Step 1 Action is valid for a new table';
        Step2ActionOnliValidForUpgradeTablesTxt: Label 'Step 2 Actions is only valid with upgrade tables';
        CopyActionNotValidForChangedPrimaryKeyTxt: Label 'Copy Action is not valid when the primary key changes from source to destination version';

    local procedure GetVersion()
    begin
        if VersionCompare.Code <> "Compare Version Code" then
            VersionCompare.Get("Compare Version Code");
    end;

    procedure GetSourceTableName(): Text
    begin
        FilterSourceTable();
        if TableVersion.FindFirst() then
            exit(TableVersion."Table Name")
        else
            exit('');
    end;

    procedure GetSourceTempTableName(): Text[50]
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        FilterSourceTable();
        if (Result <> Result::New) and TableVersion.FindFirst() then
            exit(TableVersion.GetUpgradeTempTableName())
        else begin
            CompareTableResult.SetRange("Compare Version Code", "Compare Version Code");
            CompareTableResult.SetRange(Result, Result::Modified, Result::Deleted);
            CompareTableResult.SetRange("Upgrade Table ID", "Upgrade Table ID");
            if CompareTableResult.FindFirst() then
                exit(CompareTableResult.GetSourceTempTableName())
            else
                exit('');
        end;
    end;

    procedure GetDestinationTableName(): Text
    begin
        FilterDestinationTable();
        if TableVersion.FindFirst() then
            exit(TableVersion."Table Name")
        else
            exit('');
    end;

    procedure GetNextUpgradeTableID(BulkModify: Boolean) NextAvailableTableID: Integer
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        GetVersion();
        VersionCompare.TestField("First Upgrade Table ID");
        NextAvailableTableID := VersionCompare."First Upgrade Table ID";
        CompareTableResult.SetCurrentKey("Compare Version Code", "Upgrade Table ID");
        CompareTableResult.SetRange("Compare Version Code", "Compare Version Code");
        if BulkModify then begin
            CompareTableResult.SetFilter("Upgrade Table ID", '>%1', NextAvailableTableID);
            if CompareTableResult.FindLast() then
                exit(CompareTableResult."Upgrade Table ID" + 1);
        end;
        CompareTableResult.SetRange("Upgrade Table ID", NextAvailableTableID);
        while not CompareTableResult.IsEmpty() do begin
            NextAvailableTableID += 1;
            CompareTableResult.SetRange("Upgrade Table ID", NextAvailableTableID);
        end;
    end;

    procedure GetUpgradeTableSourceID(): Integer
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        TestField("Upgrade Table ID");
        if Result in [Result::New, Result::Modified] then begin
            FindUpgradeTableSource(CompareTableResult);
            exit(CompareTableResult."Table No.");
        end else
            exit("Table No.");
    end;

    procedure GetUpgradeTableStep1Action(): Integer
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        TestField("Upgrade Table ID");
        if Result in [Result::New, Result::Modified] then begin
            FindUpgradeTableSource(CompareTableResult);
            exit(CompareTableResult."Step 1 Action");
        end else
            exit(CompareTableResult."Step 1 Action"::Ignore);
    end;

    local procedure FindUpgradeTableSource(var CompareTableResult: Record "Compare Table Result")
    begin
        TestField("Upgrade Table ID");
        CompareTableResult.SetRange("Compare Version Code", "Compare Version Code");
        CompareTableResult.SetRange(Result, Result::Modified, Result::Deleted);
        CompareTableResult.SetRange("Step 1 Action", CompareTableResult."Step 1 Action"::Copy, CompareTableResult."Step 1 Action"::Move);
        CompareTableResult.SetRange("Upgrade Table ID", "Upgrade Table ID");
        CompareTableResult.FindFirst();
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

    local procedure FilterSourceTable()
    begin
        GetVersion();
        TableVersion.FilterGroup(2);
        TableVersion.SetRange("Table Version Code", VersionCompare."Source Version Code");
        TableVersion.SetRange("Table No.", "Table No.");
        TableVersion.SetRange("Field No.");
        TableVersion.FilterGroup(0);
        TableVersion.SetRange("Field No.");
    end;

    procedure DestinationTableLookup(CurrentTableNo: Integer): Integer
    var
        TempTableVersion: Record "Table Version Field" temporary;
    begin
        if "Step 2 Action" = "Step 2 Action"::Ignore then begin
            GetVersion();
            TableVersion.BuildVersionTableList(VersionCompare."Destination Version Code", TempTableVersion);
        end else
            if Result in [Result::New, Result::Modified] then
                BuildUpgradeTableList(TempTableVersion);

        if not TempTableVersion.IsEmpty() then begin
            TempTableVersion."Table No." := CurrentTableNo;
            if PAGE.RunModal(PAGE::"Table Version List", TempTableVersion) = ACTION::LookupOK then
                exit(TempTableVersion."Table No.")
            else
                exit(CurrentTableNo);
        end;
        exit(0);
    end;

    local procedure BuildUpgradeTableList(var TempTableVersion: Record "Table Version Field")
    var
        UpgradeTableVersion: Record "Table Version Field";
        CompareTableResult: Record "Compare Table Result";
    begin
        GetVersion();
        CompareTableResult.SetRange("Compare Version Code", "Compare Version Code");
        CompareTableResult.SetRange(Result, Result::Modified, Result::Deleted);
        CompareTableResult.SetFilter("Upgrade Table ID", '<>%1', 0);
        if CompareTableResult.FindSet() then
            repeat
                UpgradeTableVersion.SetRange("Table Version Code", VersionCompare."Destination Version Code");
                UpgradeTableVersion.SetRange("Table No.", CompareTableResult."Upgrade Table ID");
                if UpgradeTableVersion.FindFirst() then
                    TempTableVersion := UpgradeTableVersion
                else begin
                    TempTableVersion.Init();
                    TempTableVersion."Table Version Code" := VersionCompare."Source Version Code";
                    TempTableVersion."Table No." := CompareTableResult."Upgrade Table ID";
                    TempTableVersion."Table Name" := CompareTableResult.GetSourceTempTableName();
                end;
                if TempTableVersion.Insert() then;
            until CompareTableResult.Next() = 0;
    end;

    procedure VerifyTableActions(Suffix: Text) ErrorText: Text
    begin
        if ("Step 1 Action" = "Step 1 Action"::Force) and
           ("Step 2 Action" in ["Step 2 Action"::Copy, "Step 2 Action"::Move])
        then
            ErrorText += TableAlreadyDeletedErr + Suffix + VersionCompare.GetCrLf();
        if ("Step 1 Action" in ["Step 1 Action"::Copy, "Step 1 Action"::Move]) and ("Upgrade Table ID" = 0) then
            ErrorText += UpgradeTableIdMissingErr + Suffix + VersionCompare.GetCrLf();
        if ("Step 2 Action" in ["Step 2 Action"::Copy, "Step 2 Action"::Move]) and ("Upgrade Table ID" = 0) then
            ErrorText += UpgradeTableIdMissingErr + Suffix + VersionCompare.GetCrLf();
        if ("Step 2 Action" in ["Step 2 Action"::Copy, "Step 2 Action"::Move]) and not ("Step 2 Action" in ["Step 2 Action"::Copy, "Step 2 Action"::Move]) then
            ErrorText += Step2ActionOnliValidForUpgradeTablesTxt + Suffix + VersionCompare.GetCrLf();
        if (("Step 1 Action" = "Step 1 Action"::Copy) or ("Step 2 Action" = "Step 2 Action"::Copy)) and PrimaryKeyModified() then
            ErrorText += CopyActionNotValidForChangedPrimaryKeyTxt + Suffix + VersionCompare.GetCrLf();
    end;

    procedure VerifyFieldsActions(Suffix: Text) ErrorText: Text
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        CompareFieldResult.SetRange("Compare Version Code", "Compare Version Code");
        CompareFieldResult.SetRange("Table No.", "Table No.");
        CompareFieldResult.SetFilter("Copy Value From Field No.", '>%1', 0);
        CompareFieldResult.FilterGroup(2);
        CompareFieldResult.SetRange("Table Result Filter", Result);
        CompareFieldResult.FilterGroup(0);
        if CompareFieldResult.FindSet() then
            repeat
                ErrorText += CompareFieldResult.VerifyFieldActions(Suffix);
            until CompareFieldResult.Next() = 0;
    end;

    procedure SetSelectedLinesStepAction(var SelectedCompareTableResult: Record "Compare Table Result"; StepNo: Integer; StepAction: Option Ignore,Copy,Move,Force,Check,"Use Source Id")
    begin
        SelectedCompareTableResult.FindSet();
        repeat
            case StepNo of
                1:
                    SelectedCompareTableResult.Validate("Step 1 Action", StepAction);
                2:
                    SelectedCompareTableResult.Validate("Step 2 Action", StepAction);
            end;
            SelectedCompareTableResult.Modify();
        until SelectedCompareTableResult.Next() = 0;
    end;

    procedure SplitModifiedResult()
    var
        NewCompareTableResult: Record "Compare Table Result";
        DeletedCompareTableResult: Record "Compare Table Result";
    begin
        TestField(Result, Result::Modified);
        NewCompareTableResult := Rec;
        NewCompareTableResult.Result := NewCompareTableResult.Result::New;
        NewCompareTableResult."Step 1 Action" := NewCompareTableResult."Step 1 Action"::Ignore;
        NewCompareTableResult.Insert();
        DeletedCompareTableResult := Rec;
        DeletedCompareTableResult.Result := DeletedCompareTableResult.Result::Deleted;
        DeletedCompareTableResult."Step 2 Action" := DeletedCompareTableResult."Step 2 Action"::Ignore;
        DeletedCompareTableResult.Insert();
        Delete();
        Commit();
        NewCompareTableResult.SetRange("Compare Version Code", "Compare Version Code");
        NewCompareTableResult.SetRange("Table No.", "Table No.");
        PAGE.RunModal(PAGE::"Version Compare Table Res.", NewCompareTableResult);
    end;

    procedure PrimaryKeyModified() IsModifiedPrimary: Boolean
    var
        SrcTblPrimaryKeyChanged: Query "Src. Tbl. Prim. Key Chen.";
        DstTblPrimaryKeyChanged: Query "Dst. Tbl. Prim. Key Chan.";
    begin
        SrcTblPrimaryKeyChanged.SetRange(Code_Filter, "Compare Version Code");
        SrcTblPrimaryKeyChanged.SetRange(Table_No_Filter, "Table No.");
        if SrcTblPrimaryKeyChanged.Open() then
            IsModifiedPrimary := SrcTblPrimaryKeyChanged.Read();

        DstTblPrimaryKeyChanged.SetRange(Code_Filter, "Compare Version Code");
        DstTblPrimaryKeyChanged.SetRange(Table_No_Filter, "Table No.");
        if DstTblPrimaryKeyChanged.Open() then
            IsModifiedPrimary := IsModifiedPrimary or DstTblPrimaryKeyChanged.Read();
    end;

    procedure GetLineStyle() LineStyle: Text
    begin
        if ("Step 1 Action" <> "Step 1 Action"::Ignore) then
            exit('Standard');
        GetVersion();
        VersionCompare.SetRange("Table No. Filter", "Table No.");
        VersionCompare.CalcFields("No. of Modifed Fields", "No. of Deleted Fields");
        if (VersionCompare."No. of Modifed Fields" > 0) or (VersionCompare."No. of Deleted Fields" > 0) then
            exit('Strong')
        else
            exit('Standard');
    end;
}

