
reportextension 50103 "ADC Sales Invoice NA Extends" extends "Sales Invoice NA"
{
    RDLCLayout = './src/reportextension/SMBSalesInvoiceNA.rdl';
    dataset
    {

        add("Sales Invoice Header")
        {
            column(ADCTotalHrsCaption; TotalHrsCaptionLbl)
            { }
            column(ADCWorkTypeCaption; WorkTypeCaptionLbl)
            { }
            column(ADCItemDescriptionExtCaption; ItemDescriptionExtCaptionLbl)
            { }
            column(ADCWorkDescExtCaption; WorkDescExtCaptionLbl)
            { }
            column(ADCPlanningDueDateCaption; PlanningDueDateCaptionLbl)
            { }
            column(ADCInvoiceFooterTextLbl; InvoiceFooterTextLbl)
            {

            }
            column(ADCQuantityCaptionLbl; QtyCaptionLbl)
            {

            }
        }

        add(SalesInvLine)
        {
            column(ADCTotalQty; TotalQty)
            { }
            column(ADCWorkTypeCode; TempSalesInvoiceLineRec."Work Type Code")
            { }
            column(ADCJobPlanningLine_PlanningDueDate; JobPlanningLine."Planning Date")
            { }
        }

        modify(copyloop)
        {
            trigger OnAfterAfterGetRecord()
            begin
                TotalQty := 0;
            end;
        }

        modify(SalesLineComments)
        {
            trigger OnAfterAfterGetRecord()
            begin
                with TempSalesInvoiceLineRec do begin
                    Init;
                    "Document No." := "Sales Invoice Header"."No.";
                    "Line No." := HighestLineNoExt + 10;
                    HighestLineNoExt := "Line No.";
                end;
                if StrLen(Comment) <= MaxStrLen(TempSalesInvoiceLineRec.Description) then begin
                    TempSalesInvoiceLineRec.Description := Comment;
                    TempSalesInvoiceLineRec."Description 2" := '';
                end else begin
                    SpacePointerExt := MaxStrLen(TempSalesInvoiceLineRec.Description) + 1;
                    while (SpacePointerExt > 1) and (Comment[SpacePointerExt] <> ' ') do
                        SpacePointerExt := SpacePointerExt - 1;
                    if SpacePointerExt = 1 then
                        SpacePointerExt := MaxStrLen(TempSalesInvoiceLineRec.Description) + 1;
                    TempSalesInvoiceLineRec.Description := CopyStr(Comment, 1, SpacePointerExt - 1);
                    TempSalesInvoiceLineRec."Description 2" :=
                      CopyStr(CopyStr(Comment, SpacePointerExt + 1), 1, MaxStrLen(TempSalesInvoiceLineRec."Description 2"));
                end;
                TempSalesInvoiceLineRec.Insert();
            end;
        }

        modify("Sales Invoice Line")
        {
            trigger OnAfterAfterGetRecord()
            begin
                TempSalesInvoiceLineRec := "Sales Invoice Line";
                TempSalesInvoiceLineRec.Insert();

                HighestLineNoExt := "Line No.";
            end;

            trigger OnAfterPreDataItem()
            begin
                TempSalesInvoiceLineRec.Reset();
                TempSalesInvoiceLineRec.DeleteAll();
            end;
        }
        modify("Sales Comment Line")
        {
            trigger OnAfterAfterGetRecord()
            begin
                with TempSalesInvoiceLineRec do begin
                    Init;
                    "Document No." := "Sales Invoice Header"."No.";
                    "Line No." := HighestLineNoExt + 1000;
                    HighestLineNoExt := "Line No.";
                end;
                if StrLen(Comment) <= MaxStrLen(TempSalesInvoiceLineRec.Description) then begin
                    TempSalesInvoiceLineRec.Description := Comment;
                    TempSalesInvoiceLineRec."Description 2" := '';
                end else begin
                    SpacePointerExt := MaxStrLen(TempSalesInvoiceLineRec.Description) + 1;
                    while (SpacePointerExt > 1) and (Comment[SpacePointerExt] <> ' ') do
                        SpacePointerExt := SpacePointerExt - 1;
                    if SpacePointerExt = 1 then
                        SpacePointerExt := MaxStrLen(TempSalesInvoiceLineRec.Description) + 1;
                    TempSalesInvoiceLineRec.Description := CopyStr(Comment, 1, SpacePointerExt - 1);
                    TempSalesInvoiceLineRec."Description 2" :=
                      CopyStr(CopyStr(Comment, SpacePointerExt + 1), 1, MaxStrLen(TempSalesInvoiceLineRec."Description 2"));
                end;
                TempSalesInvoiceLineRec.Insert();
            end;

            trigger OnAfterPreDataItem()
            begin
                with TempSalesInvoiceLineRec do begin
                    Init;
                    "Document No." := "Sales Invoice Header"."No.";
                    "Line No." := HighestLineNoExt + 1000;
                    HighestLineNoExt := "Line No.";
                end;
                TempSalesInvoiceLineRec.Insert();
            end;
        }

        modify(SalesInvLine)
        {
            trigger OnAfterAfterGetRecord()
            begin
                OnLineNumberExt := OnLineNumberExt + 1;

                with TempSalesInvoiceLineRec do begin
                    if OnLineNumberExt = 1 then
                        Find('-')
                    else
                        Next;

                    TotalQty += TempSalesInvoiceLineRec.Quantity;

                    JobPlanningLine.Reset();
                    JobPlanningLine.SetRange("Job No.", TempSalesInvoiceLineRec."Job No.");
                    JobPlanningLine.SetRange("Job Task No.", TempSalesInvoiceLineRec."Job Task No.");
                    JobPlanningLine.SetRange("Job Contract Entry No.", TempSalesInvoiceLineRec."Job Contract Entry No.");
                    if TempSalesInvoiceLineRec.Type = TempSalesInvoiceLineRec.Type::Item then
                        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
                    if TempSalesInvoiceLineRec.Type = TempSalesInvoiceLineRec.Type::Resource then
                        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
                    JobPlanningLine.SetRange("No.", TempSalesInvoiceLineRec."No.");
                    if not JobPlanningLine.FindLast() then
                        JobPlanningLine.Init();

                end;
            end;

            trigger OnAfterPreDataItem()
            begin
                NumberOfLinesExt := TempSalesInvoiceLineRec.Count();
                SetRange(Number, 1, NumberOfLinesExt);
                OnLineNumberExt := 0;
            end;
        }
    }
    var
        TotalQty: Decimal;
        SpacePointerExt: Integer;
        HighestLineNoExt: Integer;
        OnLineNumberExt: Integer;
        NumberOfLinesExt: Integer;
        TotalHrsCaptionLbl: Label 'Total Hrs.';
        WorkTypeCaptionLbl: Label 'Work Type';
        ItemDescriptionExtCaptionLbl: Label 'Name';
        WorkDescExtCaptionLbl: Label 'Work Description';
        TempSalesInvoiceLineRec: Record "Sales Invoice Line" temporary;
        JobPlanningLine: Record "Job Planning Line";
        PlanningDueDateCaptionLbl: Label 'Work Date';
        QtyCaptionLbl: Label 'Quantity/Hrs.';
        InvoiceFooterTextLbl: Label '<p>Thank you for your business.</br> You can pay this invoice online. <a href=https://adcirrus.connectboosterportal.com/platform/paynow/invoice/>Here</a></p>';
}
