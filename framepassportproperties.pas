unit FramePassportProperties;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ValEdit, StdCtrls, ExtCtrls,
  DbCtrls, DBGrids, ComCtrls, unit_m_data, unit_types_and_const,
  FramePassportObjects, ZDataset, ZSqlUpdate, rxdbgrid, rxdbcurredit, db;

type

  { TFramePassportProperties }

  TFramePassportProperties = class(TFrame)
    DBComboBoxType: TDBLookupComboBox;
    DBNavigator1: TDBNavigator;
    DSProp: TDataSource;
    DSBranches: TDataSource;
    DBGridBranches: TDBGrid;
    EdName: TEdit;
    EdYearBuilt: TEdit;
    GroupBox1: TGroupBox;
    Lab2: TLabel;
    Lab4: TLabel;
    Lab3: TLabel;
    Label1: TLabel;
    Lab1: TLabel;
    MemoComment: TMemo;
    PanelL: TPanel;
    PanelV: TPanel;
    PanelVL: TPanel;
    Splitter1: TSplitter;
    SplitterVL: TSplitter;
    ZQProp: TZQuery;
    ZTBranches: TZTable;
    ZTBranchesid: TLargeintField;
    ZTBranchesname: TStringField;
    ZTBranchespass_id: TStringField;
    ZTBranchespos: TFloatField;
    procedure DBGridBranchesEditingDone(Sender: TObject);
    procedure DBGridBranchesSelectEditor(Sender: TObject; Column: TColumn;
      var Editor: TWinControl);
    procedure ZTBranchesAfterPost(DataSet: TDataSet);
    procedure ZTBranchesAfterRefresh(DataSet: TDataSet);
    procedure ZTBranchesBeforePost(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
    PageControlPassport:TPageControl;
    pass_id:integer;
    procedure getDate;
    procedure AddBranchSheet(branch_id:integer;branch_name:string);
  end;

implementation

{$R *.lfm}
var
  FPassportObjects   :TFramePassportObjects;
{ TFramePassportProperties }

procedure TFramePassportProperties.ZTBranchesBeforePost(DataSet: TDataSet);
begin
  ZTBranches.FieldByName('pass_id').AsInteger:=pass_id;
  if    ZTBranches.FieldByName('branch_name').AsString=''
   then ZTBranches.FieldByName('branch_name').AsString:='Новый путь';
end;

procedure TFramePassportProperties.ZTBranchesAfterRefresh(DataSet: TDataSet);
begin
  ZTBranches.First;
  while not ZTBranches.EOF do begin
   AddBranchSheet(ZTBranches.FieldByName('id').AsInteger,ZTBranches.FieldByName('branch_name').AsString);
   ZTBranches.Next;
  end;
end;

procedure TFramePassportProperties.ZTBranchesAfterPost(DataSet: TDataSet);
begin
  ZTBranchesAfterRefresh(DataSet)
end;

procedure TFramePassportProperties.DBGridBranchesSelectEditor(Sender: TObject;
  Column: TColumn; var Editor: TWinControl);
begin

end;

procedure TFramePassportProperties.DBGridBranchesEditingDone(Sender: TObject);
begin

end;

procedure TFramePassportProperties.getDate;
begin
{  ZQBranches.Close;
  ZQBranches.SQL.Clear;
  ZQBranches.SQL.Add(GetSQL('branchs', pass_id));
  ZQBranches.Open;   }
  ZTBranches.Filter:='pass_id='+inttostr(pass_id);
  ZTBranches.Open;
  ZQProp.Close;
  ZQProp.SQL.Clear;
  ZQProp.SQL.Add(GetSQL('prop', pass_id));
  ZQProp.Open;
  DBComboBoxType.KeyField:='id';
  DBComboBoxType.ListField:='pass_type_name';
  DBComboBoxType.KeyValue:=ZQProp.FieldByName('pass_type').AsInteger;
  EdName     .Text:=ZQProp.FieldByName('pass_name') .AsString;
  EdYearBuilt.Text:=ZQProp.FieldByName('year_built').AsString;
  MemoComment.Text:=ZQProp.FieldByName('comment').AsString;
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

end.

