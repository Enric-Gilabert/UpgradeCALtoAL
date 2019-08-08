table 68242 "Version Comparison"
{
    // ©Dynamics.is

    Caption = 'Version Comparison';
    DrillDownPageID = "To 2013 Comparisons";
    LookupPageID = "To 2013 Comparisons";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
        }
        field(2; "Name"; Text[50])
        {
            Caption = 'Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Source Version Code"; Code[20])
        {
            Caption = 'Source Version Code';
            TableRelation = "Table Version";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Destination Version Code"; Code[20])
        {
            Caption = 'Destination Version Code';
            TableRelation = "Table Version";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "First Upgrade Table ID"; Integer)
        {
            Caption = 'First Upgrade Table ID';
            DataClassification = EndUserIdentifiableInformation;
            InitValue = 50000;
        }
        field(6; "First Upgrade Codeunit ID"; Integer)
        {
            Caption = 'First Upgrade Codeunit ID';
            DataClassification = EndUserIdentifiableInformation;
            InitValue = 50000;
        }
        field(7; "No. of Tables Compared"; Integer)
        {
            CalcFormula = Count ("Compare Table Result" WHERE ("Compare Version Code" = FIELD (Code)));
            FieldClass = FlowField;
        }
        field(8; "No. of Fields Compared"; Integer)
        {
            CalcFormula = Count ("Compare Field Result" WHERE ("Compare Version Code" = FIELD (Code)));
            Caption = 'No. of Fields Compared';
            FieldClass = FlowField;
        }
        field(9; "No. of Identical Tables"; Integer)
        {
            CalcFormula = Count ("Compare Table Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  Result = CONST (Identical)));
            Caption = 'No. of Identical Tables';
            FieldClass = FlowField;
        }
        field(10; "No. of New Tables"; Integer)
        {
            CalcFormula = Count ("Compare Table Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  Result = CONST (New)));
            Caption = 'No. of New Tables';
            FieldClass = FlowField;
        }
        field(11; "No. of Modified Tables"; Integer)
        {
            CalcFormula = Count ("Compare Table Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  Result = CONST (Modified)));
            Caption = 'No. of Modified Tables';
            FieldClass = FlowField;
        }
        field(12; "No. of Deleted Tables"; Integer)
        {
            CalcFormula = Count ("Compare Table Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  Result = CONST (Deleted)));
            Caption = 'No. of Deleted Tables';
            FieldClass = FlowField;
        }
        field(13; "No. of Identical Fields"; Integer)
        {
            CalcFormula = Count ("Compare Field Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  "Table No." = FIELD ("Table No. Filter"),
                                                                  Result = CONST (Identical)));
            Caption = 'No. of Identical Fields';
            FieldClass = FlowField;
        }
        field(14; "No. of New Fields"; Integer)
        {
            CalcFormula = Count ("Compare Field Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  "Table No." = FIELD ("Table No. Filter"),
                                                                  Result = CONST (New)));
            Caption = 'No. of New Fields';
            FieldClass = FlowField;
        }
        field(15; "No. of Modifed Fields"; Integer)
        {
            CalcFormula = Count ("Compare Field Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  "Table No." = FIELD ("Table No. Filter"),
                                                                  Result = CONST (Modified)));
            Caption = 'No. of Modifed Fields';
            FieldClass = FlowField;
        }
        field(16; "No. of Deleted Fields"; Integer)
        {
            CalcFormula = Count ("Compare Field Result" WHERE ("Compare Version Code" = FIELD (Code),
                                                                  "Table No." = FIELD ("Table No. Filter"),
                                                                  Result = CONST (Deleted)));
            Caption = 'No. of Deleted Fields';
            FieldClass = FlowField;
        }
        field(20; "Step 1 Tables Object File"; BLOB)
        {
            Caption = 'Step 1 Tables Object File';
            DataClassification = SystemMetadata;
        }
        field(21; "Step 1 Codeunit Object File"; BLOB)
        {
            Caption = 'Step 1 Codeunit Object File';
            DataClassification = SystemMetadata;
        }
        field(22; "Step 1 Delete Object File"; BLOB)
        {
            Caption = 'Step 1 Delete Object File';
            DataClassification = SystemMetadata;
        }
        field(24; "Step 2 Codeunit Object File"; BLOB)
        {
            Caption = 'Step 2 Codeunit Object File';
            DataClassification = SystemMetadata;
        }
        field(25; "Step 2 Mark Tables Object File"; BLOB)
        {
            Caption = 'Step 2 Mark Tables Object File';
            DataClassification = SystemMetadata;
        }
        field(30; "Upgrade Code Version"; Option)
        {
            Caption = 'Upgrade Code Version';
            DataClassification = SystemMetadata;
            OptionCaption = 'To 2013 R2,To 2015,Via SQL To 2013 R2';
            OptionMembers = "To 2013 R2","To 2015","Via SQL To 2013 R2";
        }
        field(31; "Table No. Filter"; Integer)
        {
            Caption = 'Table No. Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DeleteComparation();
    end;

    var
        SaveUpgradeTableObjectFileTxt: Label 'Save Upgrade Tables Object File as...';
        SaveUpgradeCodeunitObjectFileTxt: Label 'Save Upgrade Codeunit Object File as...';
        SaveDeleteOldObjectsFileTxt: Label 'Save Delete Discontinued Tables to be added into Codeunit 104002...';
        XMLFileFilterStringTxt: Label 'XML files (*.xml)|*.xml|All Files (*.*)|*.*';
        TextFileFilterStringTxt: Label 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
        InTableTxt: Label ' in table no. %1';
        ExportDialogTitleTxt: Label 'Export XML';
        ImportDialogTitleTxt: Label 'Import XML';

    procedure DeleteComparation()
    var
        CompareTableResult: Record "Compare Table Result";
        CompareFieldResult: Record "Compare Field Result";
    begin
        CompareFieldResult.SetRange("Compare Version Code", Code);
        CompareFieldResult.DeleteAll();
        CompareTableResult.SetRange("Compare Version Code", Code);
        CompareTableResult.DeleteAll();
    end;

    procedure VerifyTableActions() ErrorText: Text
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        CompareTableResult.SetRange("Compare Version Code", Code);
        CompareTableResult.FindSet();
        repeat
            ErrorText += CompareTableResult.VerifyTableActions(StrSubstNo(InTableTxt, CompareTableResult."Table No."));
        until CompareTableResult.Next() = 0;
    end;

    procedure GetCrLf() CrLf: Text[2]
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
    end;

    procedure SaveStep1TableObjectTextFile(FileName: Text)
    var
        InStr: InStream;
    begin
        CalcFields("Step 1 Tables Object File");
        if not "Step 1 Tables Object File".HasValue() then exit;
        "Step 1 Tables Object File".CreateInStream(InStr);
        SaveStream(InStr, FileName, SaveUpgradeTableObjectFileTxt);
    end;

    procedure SaveStep1CodeunitObjectTextFile(FileName: Text)
    var
        InStr: InStream;
    begin
        CalcFields("Step 1 Codeunit Object File");
        if not "Step 1 Codeunit Object File".HasValue() then exit;
        "Step 1 Codeunit Object File".CreateInStream(InStr);
        SaveStream(InStr, FileName, SaveUpgradeCodeunitObjectFileTxt);
    end;

    procedure SaveStep1DeleteDiscontinuedTablesTextFile(FileName: Text)
    var
        InStr: InStream;
    begin
        CalcFields("Step 1 Delete Object File");
        if not "Step 1 Delete Object File".HasValue() then exit;
        "Step 1 Delete Object File".CreateInStream(InStr);
        SaveStream(InStr, FileName, SaveDeleteOldObjectsFileTxt);
    end;

    procedure SaveStep2CodeunitObjectTextFile(FileName: Text)
    var
        InStr: InStream;
    begin
        CalcFields("Step 2 Codeunit Object File");
        if not "Step 2 Codeunit Object File".HasValue() then exit;
        "Step 2 Codeunit Object File".CreateInStream(InStr);
        SaveStream(InStr, FileName, SaveUpgradeCodeunitObjectFileTxt);
    end;

    procedure SaveStep2MarkTablesTextFile(FileName: Text)
    var
        InStr: InStream;
    begin
        CalcFields("Step 2 Mark Tables Object File");
        if not "Step 2 Mark Tables Object File".HasValue() then exit;
        "Step 2 Mark Tables Object File".CreateInStream(InStr);
        SaveStream(InStr, FileName, SaveDeleteOldObjectsFileTxt);
    end;

    local procedure SaveStream(var InStr: InStream; DefaultFileName: Text; SaveAsPrompth: Text)
    begin
        DownloadFromStream(InStr, SaveAsPrompth, '', TextFileFilterStringTxt, DefaultFileName);
    end;

    procedure ExportResults()
    var
        TempBlob: Record TempBlob temporary;
        TempCompareTable: Record "Compare Table Result" temporary;
        TempCompareField: Record "Compare Field Result" temporary;
        CompareTableResult: Record "Compare Table Result";
        CompareFieldResult: Record "Compare Field Result";
        ExportXML: XMLport "Exp/Imp Comparasion Result";
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
    begin
        CompareTableResult.SetRange("Compare Version Code", Code);
        CopyTableResults(CompareTableResult, TempCompareTable, '');
        CompareFieldResult.SetRange("Compare Version Code", Code);
        CopyFieldResults(CompareFieldResult, TempCompareField, '');
        TempBlob.Blob.CreateOutStream(OutStr);
        ExportXML.SetTables(TempCompareTable, TempCompareField);
        ExportXML.SetDestination(OutStr);
        ExportXML.Export();
        TempBlob.Blob.CreateInStream(InStr);
        FileName := StrSubstNo('Version Comparison Result %1.xml', Code);
        DownloadFromStream(InStr, ExportDialogTitleTxt, '', XMLFileFilterStringTxt, FileName);
    end;

    procedure ImportResults()
    var
        TempCompareTable: Record "Compare Table Result" temporary;
        TempCompareField: Record "Compare Field Result" temporary;
        CompareTableResult: Record "Compare Table Result";
        CompareFieldResult: Record "Compare Field Result";
        ImportXML: XMLport "Exp/Imp Comparasion Result";
        InStr: InStream;
        FileName: Text;
    begin
        FileName := 'Version Comparison Result.xml';
        if not UploadIntoStream(ImportDialogTitleTxt, '', XMLFileFilterStringTxt, FileName, InStr) then exit;
        ImportXML.SetSource(InStr);
        ImportXML.Import();
        ImportXML.GetTables(TempCompareTable, TempCompareField);
        CopyTableResults(TempCompareTable, CompareTableResult, Code);
        CopyFieldResults(TempCompareField, CompareFieldResult, Code);
    end;

    local procedure CopyTableResults(var FromCompareTableResult: Record "Compare Table Result"; var ToCompareTableResult: Record "Compare Table Result"; ToVersionCompareCode: Code[20])
    begin
        if FromCompareTableResult.FindSet(true) then
            repeat
                if ToCompareTableResult.Get(ToVersionCompareCode, FromCompareTableResult."Table No.", FromCompareTableResult.Result) then begin
                    ToCompareTableResult.TransferFields(FromCompareTableResult, false);
                    ToCompareTableResult.Modify();
                end else begin
                    ToCompareTableResult := FromCompareTableResult;
                    ToCompareTableResult."Compare Version Code" := ToVersionCompareCode;
                    ToCompareTableResult.Insert();
                end;
            until FromCompareTableResult.Next() = 0;
    end;

    local procedure CopyFieldResults(var FromCompareFieldResult: Record "Compare Field Result"; var ToCompareFieldResult: Record "Compare Field Result"; ToVersionCompareCode: Code[20])
    begin
        if FromCompareFieldResult.FindSet(true) then
            repeat
                if ToCompareFieldResult.Get(ToVersionCompareCode, FromCompareFieldResult."Table No.", FromCompareFieldResult."Field No.") then begin
                    ToCompareFieldResult.TransferFields(FromCompareFieldResult, false);
                    ToCompareFieldResult.Modify();
                end else begin
                    ToCompareFieldResult := FromCompareFieldResult;
                    ToCompareFieldResult."Compare Version Code" := ToVersionCompareCode;
                    ToCompareFieldResult.Insert();
                end;
            until FromCompareFieldResult.Next() = 0;
    end;
}

