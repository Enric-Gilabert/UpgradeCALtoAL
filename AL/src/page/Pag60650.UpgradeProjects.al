page 60650 "Upgrade Projects"
{

    ApplicationArea = All;
    Caption = 'Upgrade Projects';
    PageType = List;
    SourceTable = "Upgrade Project";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("App Id"; "App Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Select from a list of installed Apps';

                    trigger OnValidate()
                    begin
                        InitTableList();
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a upgrade project.';
                }

            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Tables")
            {
                ApplicationArea = All;
                Caption = 'Tables';
                Image = Table;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                RunObject = Page "Upgrade Project Tables";
                RunPageLink = "App Package Id" = field ("App Package Id");
                ToolTip = 'Select or set up tables for data upgrade.';
            }
            action("ExportXml")
            {
                ApplicationArea = All;
                Caption = 'Export Xml';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                ToolTip = 'Export the selected upgrade project configuration to Xml file.';

                trigger OnAction()
                var
                    TempBlob: Record TempBlob;
                    UpgradeProject: Record "Upgrade Project";
                    FileMgt: Codeunit "File Management";
                    Xml: XmlPort "Upgrade Project XmlPort";
                    OutStr: OutStream;
                begin
                    UpgradeProject.Copy(Rec);
                    UpgradeProject.SetRecFilter();
                    TempBlob.Blob.CreateOutStream(OutStr);
                    Xml.SetTableView(UpgradeProject);
                    xml.SetDestination(OutStr);
                    Xml.Export();
                    FileMgt.BLOBExport(TempBlob, StrSubstNo('%1.xml', Description), true);
                end;
            }
            action("ImportXml")
            {
                ApplicationArea = All;
                Caption = 'Import Xml';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Page";
                ToolTip = 'Import an upgrade project configuration from an Xml file.';

                trigger OnAction()
                var
                    TempBlob: Record TempBlob;
                    FileMgt: Codeunit "File Management";
                    Xml: XmlPort "Upgrade Project XmlPort";
                    InStr: InStream;
                    DefaultFileNameTxt: Label 'UpgradeProject.xml';
                begin
                    FileMgt.BLOBImport(TempBlob, DefaultFileNameTxt);
                    TempBlob.Blob.CreateInStream(InStr);
                    xml.SetSource(InStr);
                    Xml.Import();
                end;
            }
            action("ActivityLog")
            {
                ApplicationArea = All;
                Caption = 'Activity Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                ToolTip = 'See the data upgrade history for this upgrade project.';

                trigger OnAction()
                var
                    ActivityLog: Record "Activity Log";
                begin
                    ActivityLog.ShowEntries(Rec);
                end;
            }
        }
    }
    local procedure InitTableList()
    var
        ADVUpgradeProjTableMgt: Codeunit "Upgrade Project Table Mgt.";
    begin
        ADVUpgradeProjTableMgt.InitTableList(Rec);
    end;

}

