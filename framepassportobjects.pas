unit FramePassportObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls, DbCtrls,
  unit_types_and_const, db, KGrids, KFunctions, ZDataset;

type

  { TFramePassportObjects }

  TFramePassportObjects = class(TFrame)
    DSPassObjType: TDataSource;
    DBComboBoxType: TDBLookupComboBox;
    DBComboBoxType1: TDBLookupComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    KGridEl: TKGrid;
    KGridObj: TKGrid;
    Splitter1: TSplitter;
    ZQObjects: TZQuery;
    ZQPassObjType: TZQuery;
    procedure KGridObjEditorCreate(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TWinControl);
  private
    { private declarations }
    procedure AddObject(ARow: integer;obj_type:string;len:integer);
    procedure AddElement(ARow:integer);
    procedure GetObjects();
    procedure GetElements();
    procedure SetObjects();
    procedure SetElements();
  public
    { public declarations }
    pass_id:integer;
    branch_id:integer;
    constructor Create(TheOwner: TComponent;pBranch_id:integer); //override;
  end;

implementation

{$R *.lfm}

{ TFramePassportObjects }

procedure TFramePassportObjects.KGridObjEditorCreate(Sender: TObject; ACol,
  ARow: Integer; var AEditor: TWinControl);
var
  InitialCol, InitialRow: Integer;
begin
 InitialCol := KGridObj.InitialCol(ACol); // map column indexes
 InitialRow := KGridObj.InitialRow(ARow); // map row indexes
 // do not create any editor in the 1.row
 if InitialRow = KGridObj.FixedRows then Exit
 // new feature: create TEdit in the fixed rows!
 else if InitialRow < KGridObj.FixedRows then
 begin
   if gxEditFixedRows in KGridObj.OptionsEx then
     AEditor := TEdit.Create(nil);
   Exit;
 end;
 // create custom editors
 case InitialCol of
   1:
   {begin
     AEditor := TDBLookupComboBox.Create(nil);
     with TDBLookupComboBox(AEditor) do begin
       DataField:='id';
       DataSource:=DSPassObjType;
       KeyField:='id';
       ListField:='obj_type_name';
       ListSource:=DSPassObjType;
     end;
   end; }
   begin
     AEditor := TComboBox.Create(nil);
     TComboBox(AEditor).Style := csDropDown; // cannot set height on Win!
     ZQPassObjType.First;
     while not(ZQPassObjType.EOF) do begin
      //переделать на tStringList
      TComboBox(AEditor).Items.Add(ZQPassObjType.FieldByName('obj_type_name').AsString);
      ZQPassObjType.Next;
     end;
   end;
{   3:
   begin
     AEditor := TButton.Create(nil);
   end;
   4:
   begin
     AEditor := TCheckBox.Create(nil);
     TCheckBox(AEditor).Font.Color := clRed; // applies only without OS themes (in Delphi)
   end;
   5:
   begin
     AEditor := TScrollBar.Create(nil);
     TScrollBar(AEditor).Max := 10;
   end;
   6:
   begin
     AEditor := {$IFDEF FPC}TMemo{$ELSE}TRichEdit{$ENDIF}.Create(nil);
     AEditor.Cursor:= crIBeam;
   end;
   7:
   begin
     AEditor := TMaskEdit.Create(nil);
   end  }
 else
   if gxEditFixedCols in KGridObj.OptionsEx then
     AEditor := TEdit.Create(nil);
 end;
end;

procedure TFramePassportObjects.AddObject(ARow: integer; obj_type: string;
  len: integer);
begin
  KGridObj.Cells[0, ARow] := inttostr(ARow);
//  KGridObj.CellSpan[1, ARow] := MakeCellSpan(3, 1);
  KGridObj.Cells[1, ARow] :=(obj_type);
  KGridObj.Cells[2, ARow] := CurrToStr(len)+' м.';
end;

procedure TFramePassportObjects.AddElement(ARow: integer);
begin
  KGridEl.Cells[0, ARow] := '1';
  KGridEl.CellSpan[1, ARow] := MakeCellSpan(3, 1);
  KGridEl.Cells[1, ARow] := 'Рельса П-65';
  KGridEl.Cells[4, ARow] := '50 м.';
  ARow:=ARow+1;
  KGridEl.Cells[0, ARow] := '2';
  KGridEl.CellSpan[1, ARow] := MakeCellSpan(3, 1);
  KGridEl.Cells[1, ARow] := 'Рельса П-54';
  KGridEl.Cells[4, ARow] := '200 м.';
end;

procedure TFramePassportObjects.GetObjects;
var
  row:integer;
begin
 ZQObjects.Open;
 ZQObjects.First;
 while not(ZQObjects.EOF) do begin
   KGridObj.RowCount:=KGridObj.RowCount+1;
   row:=KGridObj.RowCount-1;
   AddObject(row,ZQObjects.FieldByName('obj_type').AsString,ZQObjects.FieldByName('length').AsInteger);
   ZQObjects.Next;
 end;
 ZQObjects.Close;
end;

procedure TFramePassportObjects.GetElements;
begin

end;

procedure TFramePassportObjects.SetObjects;
begin

end;

procedure TFramePassportObjects.SetElements;
begin

end;

constructor TFramePassportObjects.Create(TheOwner: TComponent;
  pBranch_id: integer);
begin
  inherited Create(TheOwner);
  DBComboBoxType.KeyField:='id';
  DBComboBoxType.ListField:='elem_type_name';
  DBComboBoxType.ListFieldIndex:=0;
  ZQObjects.SQL.Clear;
  Branch_id:=pBranch_id;
  ZQObjects.SQL.Add(GetSQL('objects',branch_id));
  ZQPassObjType.SQL.Clear;
  ZQPassObjType.SQL.Add(GetSQL('objects_type',0));
  ZQPassObjType.Open;
  KGridObj.ColWidths[0]:=30;
  KGridObj.ColWidths[1]:=300;//(KGridObj.Width-70);
  KGridObj.RowCount:=0;
  GetObjects;
  KGridObj.Rows[0].Destroy;
  {
  KGridEl.Cells[0, 0] := '№';
  KGridEl.CellSpan[1, 0] := MakeCellSpan(3, 1);
  KGridEl.Cells[1, 0] := 'Тип';
  KGridEl.Cells[4, 0] := 'Длина';
  AddObject(0,1);
  AddElement(0,2); }
end;

end.

