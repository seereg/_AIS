unit unit_m;

//{$mode objfpc}{$H+}
{$mode delphi}{$H+} //для TabCloseEvent

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Menus, ActnList, Buttons, StdCtrls, DbCtrls, CheckLst,
  attabs, rxdbgrid, unit_m_data, db,
  unit_types_and_const, FramePassport, KGrids, Types;

type

  { TFormM }

  TFormM = class(TForm)
    ActionNewPassport: TAction;
    ActionOpenPasp: TAction;
    ActionReconnect: TAction;
    ActionShowMap: TAction;
    ActionShowCad: TAction;
    ActionShowPasp: TAction;
    ActionList1: TActionList;
    ActionShowList: TAction;
    FilterList: TCheckListBox;
    Image1: TImage;
    Image2: TImage;
    MI_Close: TMenuItem;
    PageControl2: TPageControl;
    Panel1: TPanel;
    PanelMap: TPanel;
    PanelTool: TPanel;
    PanelCAD: TPanel;
    PanelList: TPanel;
    PanelPassport: TPanel;
    PopupMenuTabs: TPopupMenu;
    RxDBGrid1: TRxDBGrid;
    BBNewPassport: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet4: TTabSheet;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure ActionNewPassportExecute(Sender: TObject);
    procedure ActionOpenPaspExecute(Sender: TObject);
    procedure ActionReconnectExecute(Sender: TObject);
    procedure ActionShowCadExecute(Sender: TObject);
    procedure ActionShowListExecute(Sender: TObject);
    procedure ActionShowMapExecute(Sender: TObject);
    procedure ActionShowPaspExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RxDBGrid1AfterQuickSearch(Sender: TObject; Field: TField;
      var AValue: string);
    procedure RxDBGrid1DblClick(Sender: TObject);
  private
    { private declarations }
    {TATTabs}
    procedure TabCloseEvent(Sender: TObject; ATabIndex: Integer; var ACanClose,
         ACanContinue: boolean);
    procedure TabChangeQueryEvent (Sender: TObject; ANewTabIndex: Integer;
    var ACanChange: boolean);
    {TATTabs - end}
  public
    PasTabs: TATTabs;
    { public declarations }
    procedure PasspTypeListAfterUpdate();
  end;

var
  FormM: TFormM;
  FilePath:string;
  ActivPaspID:integer=-1;
  DefaultSettings:record
   PanelList_Show:boolean;
   PanelList_Width:integer;
  end;

  FPassport:TFramePassport;
  PassportsArr:array of TFramePassport;

implementation

{$R *.lfm}

{ TFormM }
uses
  unit_login;

procedure TFormM.FormShow(Sender: TObject);
begin
 DataM.ZConnection1.Disconnect;
 Caption:=Caption+' - '+GetMyVersion+' - alfa';
 //Firefox rectangle tabs
 PasTabs:= TATTabs.Create(PanelPassport);
 PasTabs.Parent:= PanelPassport;
 PasTabs.Align:= alTop;
 PasTabs.OnTabClose:= TabCloseEvent;
 PasTabs.OnTabChangeQuery:= TabChangeQueryEvent;
 PasTabs.Font.Size:= 8;

 PasTabs.TabShowPlus:= false;
 PasTabs.Height:= 42;
 PasTabs.TabAngle:= 0;
 PasTabs.TabIndentInter:= 2;
 PasTabs.TabIndentInit:= 2;
 PasTabs.TabIndentTop:= 4;
 PasTabs.TabIndentXSize:= 13;
 PasTabs.TabWidthMin:= 18;
 PasTabs.TabDragEnabled:= false;

 PasTabs.Font.Color:= clBlack;
 PasTabs.ColorBg:=PanelPassport.Color;// $F9EADB;
 PasTabs.ColorBorderActive:={PanelPassport.Color;//} $ACA196;
 PasTabs.ColorBorderPassive:= $ACA196;
 PasTabs.ColorTabActive:=PanelPassport.Color;// $FCF5ED;
 PasTabs.ColorTabPassive:= $E0D3C7;
 PasTabs.ColorTabOver:= $F2E4D7;
 PasTabs.ColorCloseBg:= clNone;
 PasTabs.ColorCloseBgOver:= $D5C9BD;
 PasTabs.ColorCloseBorderOver:= $B0B0B0;
 PasTabs.ColorCloseX:= $7B6E60;
 PasTabs.ColorArrow:= $5C5751;
 PasTabs.ColorArrowOver:= PasTabs.ColorArrow;

 SetLength(PassportsArr,0);
 if FormLogin.ShowModal<>mrOK then Close;
end;

procedure TFormM.RxDBGrid1AfterQuickSearch(Sender: TObject; Field: TField;
  var AValue: string);
begin
end;

procedure TFormM.RxDBGrid1DblClick(Sender: TObject);
begin
 ActivPaspID:=DataM.ZQPasspList.FieldByName('id').AsInteger;
 ActionOpenPaspExecute(Sender)
end;

procedure TFormM.TabCloseEvent(Sender: TObject; ATabIndex: Integer;
    var ACanClose, ACanContinue: boolean);
var
  i,i2:integer;
begin
 for i:=0 to High(PassportsArr) do
   if PassportsArr[i]<>nil then
    if ATabIndex=PassportsArr[i].TabIndex then
     begin
      PassportsArr[i].Destroy;
      PassportsArr[i]:=nil;
      for i2:=i to  High(PassportsArr) do
       if PassportsArr[i2]<>nil then
        PassportsArr[i2].TabIndex:=PassportsArr[i2].TabIndex-1;
      exit;
     end;
end;

procedure TFormM.TabChangeQueryEvent(Sender: TObject; ANewTabIndex: Integer;
  var ACanChange: boolean);
var
  i:integer;
begin
 for i:=0 to High(PassportsArr) do
    if PassportsArr[i]<>nil then begin
     if ANewTabIndex=PassportsArr[i].TabIndex
     then PassportsArr[i].Show
     else PassportsArr[i].Hide;
    end;
 ACanChange:=true;
end;

procedure TFormM.PasspTypeListAfterUpdate;
begin
  DataM.ZQPasspTypeList.First;
  FilterList.Items.Clear;
  While not(DataM.ZQPasspTypeList.EOF) do begin
   FilterList.Items.Add(DataM.ZQPasspTypeList.FieldByName('pass_type_name').AsString);
   DataM.ZQPasspTypeList.Next;
   FilterList.Checked[FilterList.Items.Count-1]:=true;
  end;
end;

procedure TFormM.ActionShowListExecute(Sender: TObject);
begin
   PanelList.Visible:=ActionShowList.Checked;
end;

procedure TFormM.ActionShowMapExecute(Sender: TObject);
begin
  PanelCAD.Align:=alRight;
  PanelMap.Align:=alRight;
  PanelCAD.Visible:=ActionShowCad.Checked;
  PanelMap.Visible:=ActionShowMap.Checked;
  PanelCAD.Align:=alClient;
  PanelMap.Align:=alClient;
end;

procedure TFormM.ActionShowCadExecute(Sender: TObject);
begin
  PanelCAD.Align:=alRight;
  PanelMap.Align:=alRight;
  PanelCAD.Visible:=ActionShowCad.Checked;
  PanelMap.Visible:=ActionShowMap.Checked;
  PanelCAD.Align:=alClient;
  PanelMap.Align:=alClient;
end;

procedure TFormM.ActionReconnectExecute(Sender: TObject);
  var
    filepath:string;
begin
    filepath:= ExtractFilePath(ParamStr(0));
   with DataM do
   begin
     ZConnection1.Disconnect;
     ZConnection1.Database:=filepath+'db\tramways.db';
     ZConnection1.LibraryLocation:=filepath+'dll\sqlite3.dll';
     ZConnection1.Connect;
     ZQPasspList.Open;
     ZQPasspTypeList.Open;
     ZQPasspElType.Open;
     ActionShowCadExecute(nil);
     ActionShowCadExecute(nil);
   end;
end;

procedure TFormM.ActionOpenPaspExecute(Sender: TObject);
var
  i:integer;
  passpAlreadyExist:boolean=false;
begin
 for i:=0 to High(PassportsArr) do
   if PassportsArr[i]<>nil then begin
    if PassportsArr[i].PasspID=ActivPaspID
    then
    begin
     PassportsArr[i].Show;
     PasTabs.TabIndex:=PassportsArr[i].TabIndex;
     passpAlreadyExist:=true;
    end
    else PassportsArr[i].Hide;
   end;
 if passpAlreadyExist then exit;
 SetLength(PassportsArr,Length(PassportsArr)+1);
 PassportsArr[High(PassportsArr)]:=TFramePassport.Create(PanelPassport,PasTabs,ActivPaspID);
end;

procedure TFormM.ActionNewPassportExecute(Sender: TObject);
begin
   ActivPaspID:=const_pasNew;
   ActionOpenPaspExecute(Sender);
end;

procedure TFormM.ActionShowPaspExecute(Sender: TObject);
begin
   PanelPassport.Visible:=ActionShowPasp.Checked;
end;
end.

