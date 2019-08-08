codeunit 60690 "Upgrade Project Tests"
{
    Subtype = Test;

    trigger OnRun()
    begin

    end;

    [Test]
    procedure TestXmlImport()
    var
        UpgradeProject: Record "Upgrade Project";
        Tempblob: Record Tempblob;
        XmlImport: XmlPort "Upgrade Project XmlPort";
        InStr: InStream;
    begin
        // [SCENARIO] Read a given Xml file and verify that project is created

        // [GIVEN] Get Demo Xml 
        Tempblob.WriteAsText(GetDemoXml(), TextEncoding::UTF8);

        // [WHEN] Xml read via Xml Port
        Tempblob.Blob.CreateInStream(InStr);
        XmlImport.SetSource(InStr);
        XmlImport.Import();

        // [THEN] Upgrade Project should Exist
        Evaluate(UpgradeProject."App Id", '{2cb085a3-1b88-4191-a986-db816f637ff5}');
        UpgradeProject.SetRange("App Id", UpgradeProject."App Id");
        Assert.RecordCount(UpgradeProject, 1);

    end;

    local procedure GetDemoXml(): Text
    var
        Tempblob: Record Tempblob;
    begin
        Tempblob.FromBase64String('PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxVcGdyYWRlUHJvamVjdCB4bWxucz0iaHR0cDovL25hdmlzaW9uLmd1cnUiPgogIDxBRFZVcGdyYWRlUHJvamVjdD4KICAgIDxBcHBJZD57MmNiMDg1YTMtMWI4OC00MTkxLWE5ODYtZGI4MTZmNjM3ZmY1fTwvQXBwSWQ+CiAgPC9BRFZVcGdyYWRlUHJvamVjdD4KPC9VcGdyYWRlUHJvamVjdD4K');
        exit(Tempblob.ReadAsTextWithCRLFLineSeparator());
    end;

    var
        Assert: Codeunit Assert;
}