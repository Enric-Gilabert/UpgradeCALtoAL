report 68241 "Conv. Object File to Code"
{
    // ©Dynamics.is

    Caption = 'Conv. Object File to Code';
    ProcessingOnly = true;
    ShowPrintStatus = false;
    UseRequestPage = false;

    dataset
    {
        dataitem(ReadFile; "Integer")
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            var
                NVInStream: InStream;
                NVOutStream: OutStream;
                InLine: Text;
                OutLine: Text;
                Loop: Integer;
            begin
                Window.Open(ReadingTxt);
                InTempBlob.Blob.CreateInStream(NVInStream);
                OutTempBlob.Blob.CreateOutStream(NVOutStream);
                while not NVInStream.EOS() do begin
                    NVInStream.ReadText(InLine);
                    OutLine := '  ''';
                    for Loop := 1 to StrLen(InLine) do
                        case InLine[Loop] of
                            39:
                                OutLine += '''''';
                            else
                                OutLine += CopyStr(InLine, Loop, 1);
                        end;
                    if NVInStream.EOS() then
                        NVOutStream.WriteText(OutLine + ''' + CrLf;' + CrLf)
                    else
                        NVOutStream.WriteText(OutLine + ''' + CrLf + ' + CrLf);
                end;

                Window.Close();
            end;

            trigger OnPostDataItem()
            var
                NVInStream: InStream;
                FileName: Text;
            begin
                OutTempBlob.Blob.CreateInStream(NVInStream);
                FileName := 'Codeunit.txt';
                DownloadFromStream(NVInStream, ExportTxt, '', TextFileFilterStringTxt, FileName);
            end;

            trigger OnPreDataItem()
            var
                NVInStream: InStream;
                NVOutStream: OutStream;
            begin
                InTempBlob.Init();

                if UploadIntoStream(ImportTxt, '', TextFileFilterStringTxt, FileName, NVInStream) then begin
                    InTempBlob.Blob.CreateOutStream(NVOutStream);
                    CopyStream(NVOutStream, NVInStream);
                end else
                    CurrReport.Break();
                InTempBlob.Insert();
            end;
        }
    }

    requestpage
    {
        Caption = 'Conv. Object File to Code';

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
    end;

    var
        InTempBlob: Record TempBlob temporary;
        OutTempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        Window: Dialog;
        FileName: Text;
        ReadingTxt: Label 'Reading code...';
        TextFileFilterStringTxt: Label 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
        ImportTxt: Label 'Import';
        CrLf: Text[2];
        ExportTxt: Label 'Export';
}

