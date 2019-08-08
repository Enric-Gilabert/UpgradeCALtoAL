table 68240 "Table Version"
{
    // ©Dynamics.is

    Caption = 'Table Version';
    DrillDownPageID = "Table Versions";
    LookupPageID = "Table Versions";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Name"; Text[50])
        {
            Caption = 'Name';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Base Version"; Boolean)
        {
            Caption = 'Base Version';
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                "Base Version Code" := '';
            end;
        }
        field(4; "Base Version Code"; Code[20])
        {
            Caption = 'Base Version Code';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = IF ("Base Version" = CONST (false)) "Table Version".Code where ("Base Version" = const (true));

            trigger OnValidate()
            begin
                if "Base Version Code" = '' then exit;
                TestField("Base Version", false);
            end;
        }
        field(5; "No. of Fields"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count ("Table Version Field" WHERE ("Table Version Code" = FIELD (Code)));
            Caption = 'No. of Fields';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "No. of Key Fields"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count ("Table Version Primary Key" WHERE ("Table Version Code" = FIELD (Code)));
            Caption = 'No. of Key Fields';
            Editable = false;
            FieldClass = FlowField;
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
        DeleteFieldsAndKeys();
    end;

    var
        XMLFileFilterStringTxt: Label 'XML files (*.xml)|*.xml|All Files (*.*)|*.*';
        ExportDialogTitleTxt: Label 'Export XML';
        ImportDialogTitleTxt: Label 'Import XML';

    procedure DeleteFieldsAndKeys()
    var
        TableVersionField: Record "Table Version Field";
        TableVersionKey: Record "Table Version Primary Key";
    begin
        TableVersionField.SetRange("Table Version Code", Code);
        TableVersionField.DeleteAll();
        TableVersionKey.SetRange("Table Version Code", Code);
        TableVersionKey.DeleteAll();
    end;

    procedure ExportVersion()
    var
        TempBlob: Record TempBlob temporary;
        ExportXML: XMLport "Exp/Imp Table Version";
        InStr: InStream;
        OutStr: OutStream;
        FileName: Text;
    begin
        TempBlob.Blob.CreateOutStream(OutStr);
        ExportXML.SetVersion(Code);
        ExportXML.SetDestination(OutStr);
        ExportXML.Export();
        TempBlob.Blob.CreateInStream(InStr);
        FileName := StrSubstNo('Table Version %1.xml', Code);
        DownloadFromStream(InStr, ExportDialogTitleTxt, '', XMLFileFilterStringTxt, FileName);
    end;

    procedure ImportVersion()
    var
        ImportXML: XMLport "Exp/Imp Table Version";
        InStr: InStream;
        FileName: Text;
    begin
        FileName := 'Table Version.xml';
        if not UploadIntoStream(ImportDialogTitleTxt, '', XMLFileFilterStringTxt, FileName, InStr) then exit;
        ImportXML.SetSource(InStr);
        ImportXML.Import();
    end;
}

