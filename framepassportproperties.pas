unit FramePassportProperties;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ValEdit, StdCtrls, ExtCtrls,
  DbCtrls, DBGrids, ComCtrls, Menus, ActnList, unit_m_data,
  unit_types_and_const, FramePassportObjects, typepaspprop, typepaspBranch,
  ZDataset, ZSqlUpdate, rxdbgrid, rxdbcurredit, db;

type

  { TFramePassportProperties }

  TFramePassportProperties = class(TFrame)
    ActionAddBranch: TAction;
    ActionDeleteBranch: TAction;
    ActionList: TActionList;
    DBComboBoxType: TDBLookupComboBox;
    DSProp: TDataSource;
    DSBranches: TDataSource;
    DBGridBranches: TDBGrid;
    EdName: TEdit;
    EdYearBuilt: TEdit;
    GroupBox1: TGroupBox;
    Lab2: TLabel;
    Lab4: TLabel;
    Lab3: TLabel;
    Lab1: TLabel;
    MemoComment: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    PanelL: TPanel;
    PanelV: TPanel;
    PanelVL: TPanel;
    PPMGridBranches: TPopupMenu;
    Splitter1: TSplitter;
    SplitterVL: TSplitter;
    ZQProp: TZQuery;
    ZTBranches: TZTable;
    ZTBranchesid: TLargeintField;
    ZTBranchesname: TStringField;
    ZTBranchespass_id: TStringField;
    ZTBranchespos: TFloatField;
    procedure ActionDeleteBranchExecute(Sender: TObject);
    procedure DBComboBoxTypeChange(Sender: TObject);
    procedure EdNameChange(Sender: TObject);
    procedure EdYearBuiltChange(Sender: TObject);
    procedure MemoCommentChange(Sender: TObject);
    procedure ZTBranchesAfterRefresh(DataSet: TDataSet);
    procedure ZTBranchesBeforePost(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
    PageControlPassport:TPageControl;
    pass_id:integer;
    PassProp:TPassProp;
    procedure getDate;
    procedure AddBranchSheet(branch_id:integer;branch_name:string);
    procedure ClearBranchSheet();
  end;

implementation

{$R *.lfm}
var
  FPassportObjects   :TFramePassportObjects;
{ TFramePassportProperties }

procedure TFramePassportProperties.ZTBranchesBeforePost(DataSet: TDataSet);
begin
//  if pass_id<0 then exit;
  ZTBranches.FieldByName('pass_id').AsInteger:=pass_id;
  if    ZTBranches.FieldByName('branch_name').AsString=''
   then ZTBranches.FieldByName('branch_name').AsString:='Новый путь';
end;

procedure TFramePassportProperties.ZTBranchesAfterRefresh(DataSet: TDataSet);
begin
  ZTBranches.First;
  ClearBranchSheet;
  while not ZTBranches.EOF do begin
   AddBranchSheet(ZTBranches.FieldByName('id').AsInteger,ZTBranches.FieldByName('branch_name').AsString);
   ZTBranches.Next;
  end;
end;

procedure TFramePassportProperties.EdNameChange(Sender: TObject);
begin
 PassProp.pass_name:=EdName.Text;
 pass_id:=StrToIntDef(PassProp.pass_id,-1);
end;

procedure TFramePassportProperties.EdYearBuiltChange(Sender: TObject);
begin
  PassProp.year_built:=EdYearBuilt.Text;
end;

procedure TFramePassportProperties.MemoCommentChange(Sender: TObject);
begin
  PassProp.comment:=MemoComment.Text;
end;

procedure TFramePassportProperties.ActionDeleteBranchExecute(Sender: TObject);
begin
  //удаляем объекты
    //элементы
  //Удаляем ветку
  ZTBranches.Delete;
end;

procedure TFramePassportProperties.DBComboBoxTypeChange(Sender: TObject);
begin
  PassProp.pass_type:=DBComboBoxType.KeyValue;
  pass_id:=StrToIntDef(PassProp.pass_id,-1);
end;

procedure TFramePassportProperties.getDate;
begin
{  ZQBranches.Close;
  ZQBranches.SQL.Clear;
  ZQBranches.SQL.Add(GetSQL('branchs', pass_id));
  ZQBranches.Open;   }
  PassProp:=TPassProp.Create(pass_id,DataM.ZConnection1);

  ZTBranches.Filter:='pass_id='+inttostr(pass_id);
  ZTBranches.Open;
  DBComboBoxType.KeyField:='id';
  DBComboBoxType.ListField:='pass_type_name';
  DBComboBoxType.KeyValue:=StrToIntDef(PassProp.pass_type,-1);
  EdName     .Text:=PassProp.pass_name;
  EdYearBuilt.Text:=PassProp.year_built;
  MemoComment.Text:=PassProp.comment;
  ZTBranchesAfterRefresh(nil);
end;

procedure TFramePassportProperties.AddBranchSheet(branch_id: integer;
  branch_name: string);
var
  i:integer;
  TabSheet:TTabSheet;
begin
  for i:=0 to PageControlPassport.PageCount-1 do
  begin
   if PageControlPassport.Page[i].Tag=branch_id then
   begin
     PageControlPassport.Page[i].Caption:=branch_name;
     exit;
   end;
  end;
  TabSheet:=PageControlPassport.AddTabSheet;
  TabSheet.Caption:=branch_name;
  TabSheet.Tag:=branch_id;
  FPassportObjects:=TFramePassportObjects.Create(TabSheet,branch_id);
  FPassportObjects.Name:='ObjectsBranch'+inttostr(branch_id);
  FPassportObjects.pass_id:=pass_id;
  FPassportObjects.Parent:=TabSheet;
end;

procedure TFramePassportProperties.ClearBranchSheet;
var i:integer;
begin
  for i:=PageControlPassport.PageCount-1 downto 1 do
  begin
   PageControlPassport.Page[i].Destroy;
  end;
end;

end.

