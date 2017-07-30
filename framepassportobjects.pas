unit FramePassportObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls, DbCtrls,
  ActnList, Menus, unit_types_and_const, unit_m_data, typepaspBranch,
  typepaspobj, typePaspElem, db, KGrids, KFunctions, ZDataset, Types;

type

  { TFramePassportObjects }

  TFramePassportObjects = class(TFrame)
    ActionElemDel: TAction;
    ActionElemAdd: TAction;
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
    KGridObj: TKGrid;
    KGridElem: TKGrid;
    KGridObjProp: TKGrid;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuAddElem: TMenuItem;
    MenuDelElem: TMenuItem;
    PopupMenuObj: TPopupMenu;
    PopupMenuElem: TPopupMenu;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ZQObjects: TZQuery;
    ZQElements: TZQuery;
    ZQPassObjType: TZQuery;
    ZQElemType: TZQuery;
    procedure ActionElemAddExecute(Sender: TObject);
    procedure ActionObjAddExecute(Sender: TObject);
    procedure ActionObjDelExecute(Sender: TObject);
    procedure DBComboBoxTypeObjChange(Sender: TObject);
    procedure KGridElemRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure KGridObjClick(Sender: TObject);
    procedure KGridObjEditorCreate(Sender: TObject; ACol, ARow: Integer;
      var AEditor: TWinControl);
    procedure KGridObjRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure MenuAddElemClick(Sender: TObject);
  private
    { private declarations }
    procedure AddObject({ARow: integer;}obj:TPassObj);
    procedure AddElement(elem:TPassElem);
    procedure GetObjects();
    procedure GetElements(obj_id:string);
  public
    { public declarations }
    PassBranch:TPassBranch;
    pass_id:integer;
    function getPasElem(elem_id:integer):TPassElem;
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
  Row,count,obj_id:integer;
  obj:TPassObj;
begin
 if  FromIndex > ToIndex then
 begin
  Row:=ToIndex;
  count:=FromIndex;
 end
 else
 begin
   Row:=FromIndex;
   count:=ToIndex;
 end;
  for Row:=0 to count do
  begin
    KGridObj.Cells[0,Row]:=inttostr(Row+1);
    obj_id:=StrToIntDef(KGridObj.Cells[3,Row],-1);
    obj:=PassBranch.getPasObject(obj_id);
    if obj<>nil
      then  obj.obj_pos:=inttostr(Row+1);
  end;
end;

procedure TFramePassportObjects.MenuAddElemClick(Sender: TObject);
begin

end;

procedure TFramePassportObjects.KGridObjClick(Sender: TObject);
begin
  GroupBoxObjProp.Caption:='Объект №'+KGridObj.Cells[0,KGridObj.Row]+': '+KGridObj.Cells[1,KGridObj.Row];
  GetElements(KGridObj.Cells[3,KGridObj.Row]); //object_id
end;

procedure TFramePassportObjects.ActionObjDelExecute(Sender: TObject);
var
  obj_id:integer;
  obj:TPassObj;
begin
   obj_id:=StrToIntDef(KGridObj.Cells[3,KGridObj.Row],-1);
   obj:=PassBranch.getPasObject(obj_id);
   obj.DelPasObj;
   if  KGridObj.RowCount<2
   then AddObject(nil);
   KGridObj.DeleteRow(KGridObj.Row);
   //Здесь удаляем объект и все элеметы
end;

procedure TFramePassportObjects.DBComboBoxTypeObjChange(Sender: TObject);
var
 InRow,InCol:integer;
 obj_id:integer;
 obj:TPassObj;
begin
if sender is TComboBox then
 begin
  InCol := KGridObj.Selection.Col1; // map column indexes
  InRow := KGridObj.Selection.Row1; // map row indexes
  KGridObj.Cells[InCol,InRow]:= TComboBox(sender).Text;
  obj_id:=StrToIntDef(KGridObj.Cells[3,InRow],-1);
  obj:=PassBranch.getPasObject(obj_id);
  if obj<>nil then
   begin
     obj.obj_type:=inttostr(TComboBox(sender).ItemIndex+1);
     KGridObj.Cells[3,InRow]:=obj.obj_id;
   end;
 end;
 KGridObjProp.SetFocus;
 KGridObjClick(Sender);
end;

procedure TFramePassportObjects.KGridElemRowMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var
  Row,count,elem_id:integer;
  elem:TPassElem;
begin
 if  FromIndex > ToIndex then
 begin
  Row:=ToIndex;
  count:=FromIndex;
 end
 else
 begin
   Row:=FromIndex;
   count:=ToIndex;
 end;
  for Row:=0 to count do
  begin
    KGridElem.Cells[0,Row]:=inttostr(Row+1);
    elem_id:=StrToIntDef(KGridElem.Cells[3,Row],-1);
    elem:=getPasElem(elem_id);
    if elem<>nil
      then  elem.elem_pos:=inttostr(Row+1);
  end;
end;

procedure TFramePassportObjects.ActionObjAddExecute(Sender: TObject);
var
  obj:TPassObj;
begin
 obj:=PassBranch.addPasObject();
 obj.obj_type:=KGridObj.Cells[1,KGridObj.Row];
 AddObject({-1,}obj);
end;

procedure TFramePassportObjects.ActionElemAddExecute(Sender: TObject);
begin
 //
end;

procedure TFramePassportObjects.AddObject({ARow: integer; }obj:TPassObj);
var ARow:integer;
begin
 if  KGridObj.Cells[0, 0]=''
  then ARow:=0
  else
  begin
    KGridObj.RowCount:=KGridObj.RowCount+1;
    ARow:=KGridObj.RowCount-1;
  end;
  if (obj<>nil) and (obj.obj_type<>'') then
  begin
    KGridObj.Cells[0, ARow] := inttostr(ARow+1);
    KGridObj.Cells[1, ARow] :=(obj.obj_type);
    KGridObj.Cells[2, ARow] :=(obj.obj_len)+' м.';
    KGridObj.Cells[3, ARow] :=(obj.obj_id);
  end
  else
  begin
    KGridObj.Cells[0, ARow] :='';
    KGridObj.Cells[1, ARow] :='';
    KGridObj.Cells[2, ARow] :='0 м.';
    KGridObj.Cells[3, ARow] :='-1';
  end;
end;

procedure TFramePassportObjects.AddElement(elem:TPassElem);
  var
    ARow:integer;
begin
 if  KGridElem.Cells[0, 0]=''
  then ARow:=0
  else
  begin
    KGridElem.RowCount:=KGridElem.RowCount+1;
    ARow:=KGridElem.RowCount-1;
  end;
 if (elem<>nil) and (elem.elem_type<>'') then
 begin
   KGridElem.Cells[0, ARow] := inttostr(ARow+1);
   KGridElem.Cells[1, ARow] :=(elem.elem_type);
   KGridElem.Cells[2, ARow] :=(elem.elem_len)+' м.';
   KGridElem.Cells[3, ARow] :=(elem.elem_id);
 end
 else
 begin
   KGridElem.Cells[0, ARow] :='';
   KGridElem.Cells[1, ARow] :='';
   KGridElem.Cells[2, ARow] :='0 м.';
   KGridElem.Cells[3, ARow] :='-1';
 end;
end;

procedure TFramePassportObjects.GetObjects;
var
  obj:TPassObj;
  i:integer;
begin
AddObject(nil); //пустая строка форматированная
KGridObj.Rows[0].Destroy; //пустая строка неформатированная
ZQObjects.SQL.Text:=GetSQL('objects',PassBranch.branch_id);
ZQObjects.Open;
ZQObjects.First;
 if ZQObjects.RecordCount=0
 then   begin
   obj:=PassBranch.addPasObject();
   AddObject(obj);
end;
 while not(ZQObjects.EOF) do begin
   obj:=PassBranch.getPasObject(ZQObjects.FieldByName('id').AsInteger);
   AddObject(obj);
   ZQObjects.Next;
 end;
 ZQObjects.Close;
end;

procedure TFramePassportObjects.GetElements(obj_id: string);
var
  elem:TPassElem;
  row:integer;
begin
 ZQElements.Close;
 ZQElements.SQL.text:=GetSQL('elements',strtoint(obj_id));
 ZQElements.Open;
 row:=0;
 ActionElemAddExecute(nil);//пустая для пустого списка
// !!! дальше не формат
 KGridElem.Rows[0].Destroy; //пустая строка неформатированная
 while not(ZQElements.EOF) do begin
   elem:=TPassElem.Create(self,ZQElements.FieldByName('id').AsInteger,DataM.ZConnection1);
   elem.connecting:=false;
   elem.elem_type:=ZQElements.FieldByName('elem_type').AsString;
   elem.elem_len:=ZQElements.FieldByName('length')    .AsString;
   elem.elem_obj:=ZQElements.FieldByName('object_id') .AsString;
   elem.elem_colour:=ZQElements.FieldByName('colour') .AsString;
   elem.connecting:=true;
   AddElement(elem);
   row:=row-1;
   ZQElements.Next;
 end;
 ZQElements.Close;
end;

function TFramePassportObjects.getPasElem(elem_id: integer): TPassElem;
begin
  result:=nil;
end;

constructor TFramePassportObjects.Create(TheOwner: TComponent;
  pBranch_id: integer);
begin
  inherited Create(TheOwner);
  PassBranch:=TPassBranch.Create(pass_id,pBranch_id,DataM.ZConnection1);
  DBComboBoxTypeEl.KeyField:='id';
  DBComboBoxTypeEl.ListField:='elem_type_name';
  DBComboBoxTypeEl.ListFieldIndex:=0;
  ZQPassObjType.SQL.Clear;
  ZQPassObjType.SQL.Add(GetSQL('objects_type',0));
  ZQPassObjType.Open;

  KGridObj.ColWidths[0]:=30;
  KGridObj.ColWidths[1]:=300;
  KGridObj.Cols[3].Visible:=false;
  KGridObj.RowCount:=0;

  KGridElem.ColWidths[0]:=30;
  KGridElem.ColWidths[1]:=300;
  KGridElem.Cols[3].Visible:=false;
  KGridElem.RowCount:=0;

  GetObjects;
  KGridObjClick(nil);//показать свойства

end;

end.

