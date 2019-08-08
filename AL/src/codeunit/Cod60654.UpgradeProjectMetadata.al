codeunit 60654 "Upgrade Project Metadata"
{
    trigger OnRun()
    begin

    end;

    procedure GetMetadataFields(ADVUpgradeProjTable: Record "Upgrade Project Table"): Boolean
    var
        TempBlob: Record TempBlob;
        InStr: InStream;
        XmlDoc: XmlDocument;
        XmlNds: XmlNodeList;
        XmlNd: XmlNode;
        XmlAtt: XmlAttribute;
    begin
        TempBlob.Blob := ADVUpgradeProjTable."Table Extension Metadata";
        if not TempBlob.Blob.HasValue() then exit;

        TempBlob.Blob.CreateInStream(InStr);
        XmlDocument.ReadFrom(InStr, XmlDoc);
        XmlDoc.SelectNodes('//*[local-name()=''FieldAdd'']', XmlNds);
        foreach XmlNd in XmlNds do begin
            XmlNd.AsXmlElement().Attributes().Get(2, XmlAtt);
            InsertAppField(ADVUpgradeProjTable."App Package Id", ADVUpgradeProjTable."App Table Id", XmlAtt.Value());
        end;
        exit(true);

    end;

    procedure GetAppTableFields(ADVUpgradeProjTable: Record "Upgrade Project Table")
    var
        Fld: Record Field;
    begin
        with Fld do begin
            SetRange(TableNo, ADVUpgradeProjTable."App Table Id");
            SetRange(Enabled, true);
            SetRange(Class, Class::Normal);
            if FindSet() then
                repeat
                    InsertAppField(ADVUpgradeProjTable."App Package Id", ADVUpgradeProjTable."App Table Id", format("No.", 0, 9));
                until Next() = 0;
        end;
    end;

    local procedure InsertAppField(AppPackageId: Guid; AppTableId: Integer; AppFieldNo: Text)
    var
        ADVUpgradeProjAppField: Record "Upgrade Project App Field";
    begin
        with ADVUpgradeProjAppField do begin
            Init();
            "App Package Id" := AppPackageId;
            "App Table Id" := AppTableId;
            evaluate("App Field ID", AppFieldNo);
            Insert(true);
        end;
    end;

}