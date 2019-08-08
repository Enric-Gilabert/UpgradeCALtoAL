query 68241 "Dst. Tbl. Prim. Key Chan."
{
    Caption = 'Dst. Tbl. Prim. Key Change';

    elements
    {
        dataitem(ADV_Version_Comparison; "Version Comparison")
        {
            filter(Code_Filter; "Code")
            {
            }
            dataitem(ADV_Compare_Table_Result; "Compare Table Result")
            {
                DataItemLink = "Compare Version Code" = ADV_Version_Comparison.Code;
                SqlJoinType = InnerJoin;
                filter(Table_No_Filter; "Table No.")
                {
                }
                dataitem(ADV_Compare_Field_Result; "Compare Field Result")
                {
                    DataItemLink = "Compare Version Code" = ADV_Compare_Table_Result."Compare Version Code", "Table No." = ADV_Compare_Table_Result."Table No.";
                    SqlJoinType = InnerJoin;
                    DataItemTableFilter = Result = FILTER (> Identical);
                    dataitem(ADV_Table_Version_Primary_Key; "Table Version Primary Key")
                    {
                        DataItemLink = "Table Version Code" = ADV_Version_Comparison."Destination Version Code", "Table No." = ADV_Compare_Field_Result."Table No.", "Field No." = ADV_Compare_Field_Result."Field No.";
                        SqlJoinType = InnerJoin;
                        column(Field_No; "Field No.")
                        {
                        }
                    }
                }
            }
        }
    }
}

