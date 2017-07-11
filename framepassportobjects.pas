unit FramePassportObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls, DbCtrls,
  ActnList, Menus, unit_types_and_const, db, KGrids, KFunctions, ZDataset;

type

  { TFramePassportObjects }

  TFramePassportObjects = class(TFrame)
    ActionObjDel: TAction;
    ActionObjAdd: TAction;
    ActionListObjElem: TActionList;
    DSPassObjType: TDataSource;
    DBComboBoxTypeEl: TDBLookupComboBox;
    DBComboBoxTypeObj: TDBLookupComboBox;
    DSElemType: TDataSource;
    GroupBoxObjProp: TGroupBox;
    GroupBoxObj: TGroupBox;
    GroupBoxElem: TGroupBox;
    KGridEl: TKGrid;
    KGridObj: TKGrid;
    KGridObjProp: TKGrid;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PopupMenuObj: TPopupMenu;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ZQObjects: TZQuery;
    ZQElements: TZQuery;
    ZQPassObjType: TZQuery;
    ZQElemType: TZQuery;
    procedure ActionObjAddExecute(Sender: TObject);
    procedure ActionObjDelExecute(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure DBComboBoxTypeObjChange(Sender: TObject);
    procedure KGridObjCellChanging(Sender: TObject; AOldCol, AOldRow, ANewCol,
      ANewRow: Integer);
    procedure KGridObjChanged(Sender: TObject; ACol, ARow: Integer);
    procedure KGridObjClick(Sender: TObject);
    procedure KGridObjEditorCreate(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TWinControl);
    procedure KGridObjRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
  private
    { private declarations }
    procedure AddObject(ARow: integer;obj:TPassObj);
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
   begin
     AEditor := TComboBox.Create(nil);
     TComboBox(AEditor).Style := csDropDownList; // cannot set height on Win!
     TComboBox(AEditor).OnChange:=DBComboBoxTypeObj.OnChange;
     ZQPassObjType.First;
     while not(ZQPassObjType.EOF) do begin
      //переделать на tStringList, чтобы не гонять в цикле
      TComboBox(AEditor).Items.Add(ZQPassObjType.FieldByName('obj_type_name').AsString);
      ZQPassObjType.Next;
     end;
   end;
 else
   if gxEditFixedCols in KGridObj.OptionsEx then
     AEditor := TEdit.Create(nil);
 end;
end;

procedure TFramePassportObjects.KGridObjRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var
  i,count:integer;
begin
 if  FromIndex > ToIndex
 then count := FromIndex
 else count := ToIndex;
  for i:=0 to count do
  begin
    KGridObj.Cells[0,i]:=inttostr(i+1);
  end;
end;

procedure TFramePassportObjects.KGridObjClick(Sender: TObject);
begin
  GroupBoxObjProp.Caption:='Объект №'+KGridObj.Cells[0,KGridObj.Row]+': '+KGridObj.Cells[1,KGridObj.Row];
  //надо обновить свойства GroupBoxObjProp
end;

procedure TFramePassportObjects.ActionObjDelExecute(Sender: TObject);
begin
   KGridObj.DeleteRow(KGridObj.Row);
   //Здесь удаляем объект и все элеметы
end;

procedure TFramePassportObjects.ComboBox1Change(Sender: TObject);
begin
end;

procedure TFramePassportObjects.DBComboBoxTypeObjChange(Sender: TObject);
var
 InRow,InCol:integer;
begin
if sender is TComboBox then
 begin
  InCol := KGridObj.Selection.Col1; // map column indexes
  InRow := KGridObj.Selection.Row1; // map row indexes
  KGridObj.Cells[InCol,InRow]:= TComboBox(sender).Text;
 end;
 KGridObjProp.SetFocus;
 KGridObjClick(Sender);
end;

procedure TFramePassportObjects.KGridObjCellChanging(Sender: TObject; AOldCol,
  AOldRow, ANewCol, ANewRow: Integer);
begin
end;

procedure TFramePassportObjects.KGridObjChanged(Sender: TObject; ACol,
  ARow: Integer);
begin
    caption:='ok';

end;

procedure TFramePassportObjects.ActionObjAddExecute(Sender: TObject);
var
  obj:TPassObj;
begin
 //нужно реализовать добавку нового объекта
 obj.obj_type:=KGridObj.Cells[1,KGridObj.Row];
 obj.len:=0;
 //PassObjList.Add(obj)
 AddObject(-1,obj);
end;

procedure TFramePassportObjects.AddObject(ARow: integer; obj:TPassObj);
begin
  if  KGridObj.Cells[1, 0]=''
   then ARow:=0
  else
   begin
     KGridObj.RowCount:=KGridObj.RowCount+1;
     ARow:=KGridObj.RowCount-1;
   end;
  with obj do begin
    KGridObj.Cells[0, ARow] := inttostr(ARow+1);
    KGridObj.Cells[1, ARow] :=(obj_type);
    KGridObj.Cells[2, ARow] := CurrToStr(len)+' м.';
  end;
//  if ARow=0 then  KGridObj.Rows[0].Destroy; //пустая строка
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
  obj:TPassObj;
  row:integer;
begin
 ZQObjects.Open;
 ZQObjects.First;
 row:=0;
 ActionObjAddExecute(nil);//пустой
// AddObject(0,obj);
 KGridObj.Rows[0].Destroy; //пустая строка неформатированная
 while not(ZQObjects.EOF) do begin
   obj.obj_type:=ZQObjects.FieldByName('obj_type').AsString;
   obj.len:=ZQObjects.FieldByName('length').AsInteger;
   AddObject(row,obj);
   row:=row-1;
   ZQObjects.Next;
 end;
 ZQObjects.Close;
end;

procedure TFramePassportObjects.GetElements;
var
  elem:TPassElem;
  row:integer;
begin
 ZQElements.Open;
 ZQElements.First;
 row:=0;
 ActionObjAddExecute(nil);//пустая для пустого списка
// !!! дальше не формат
 KGridEl.Rows[0].Destroy; //пустая строка неформатированная
 while not(ZQElements.EOF) do begin
   elem.elem_type:=ZQElements.FieldByName('elem_type').AsString;
   elem.len:=ZQElements.FieldByName('length').AsInteger;
   AddElement(row{,elem});
   row:=row-1;
   ZQElements.Next;
 end;
 ZQElements.Close;
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
  DBComboBoxTypeEl.KeyField:='id';
  DBComboBoxTypeEl.ListField:='elem_type_name';
  DBComboBoxTypeEl.ListFieldIndex:=0;
  ZQObjects.SQL.Clear;
  Branch_id:=pBranch_id;
  ZQObjects.SQL.Add(GetSQL('objects',branch_id));
  ZQPassObjType.SQL.Clear;
  ZQPassObjType.SQL.Add(GetSQL('objects_type',0));
  ZQPassObjType.Open;
  KGridObj.ColWidths[0]:=30;
  KGridObj.ColWidths[1]:=300;
  KGridObj.RowCount:=0;
  GetObjects;
  KGridObjClick(nil);//показать свойства
end;

end.

