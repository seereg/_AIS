unit unit_m;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Menus, ActnList, Buttons, StdCtrls, DbCtrls, CheckLst, Grids,
  attabs, rxdbgrid, rxlookup, rxdbcomb, unit_m_data, db, unit_types_and_const;

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
    ActionTabClose: TAction;
    FilterList: TCheckListBox;
    Image1: TImage;
    Image2: TImage;
    MI_Close: TMenuItem;
    PageControl1: TPageControl;
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
    TabSheet2: TTabSheet;
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
    procedure ActionTabCloseExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure PageControlPasportChange(Sender: TObject);
    procedure PanelListClick(Sender: TObject);
    procedure RxDBGrid1AfterQuickSearch(Sender: TObject; Field: TField;
      var AValue: string);
    procedure RxDBGrid1DblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    t0: TATTabs;
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

implementation

{$R *.lfm}

{ TFormM }


procedure TFormM.ActionTabCloseExecute(Sender: TObject);
begin
//  if (Sender is TTabSheet) then   TTabSheet(sender).Free;
end;

procedure TFormM.Button1Click(Sender: TObject);
begin
  //
end;

procedure TFormM.FormShow(Sender: TObject);
begin
 DataM.ZConnection1.Disconnect;
 Caption:=Caption+' - '+GetMyVersion+' - alfa';
 //Firefox rectangle tabs
 t0:= TATTabs.Create(PanelPassport);
 t0.Parent:= PanelPassport;
 t0.Align:= alTop;
 t0.Font.Size:= 8;

 t0.TabShowPlus:= false;
 t0.Height:= 42;
 t0.TabAngle:= 0;
 t0.TabIndentInter:= 2;
 t0.TabIndentInit:= 2;
 t0.TabIndentTop:= 4;
 t0.TabIndentXSize:= 13;
 t0.TabWidthMin:= 18;
 t0.TabDragEnabled:= true;

 t0.Font.Color:= clBlack;
 t0.ColorBg:=PanelPassport.Color;// $F9EADB;
 t0.ColorBorderActive:={PanelPassport.Color;//} $ACA196;
 t0.ColorBorderPassive:= $ACA196;
 t0.ColorTabActive:=PanelPassport.Color;// $FCF5ED;
 t0.ColorTabPassive:= $E0D3C7;
 t0.ColorTabOver:= $F2E4D7;
 t0.ColorCloseBg:= clNone;
 t0.ColorCloseBgOver:= $D5C9BD;
 t0.ColorCloseBorderOver:= $B0B0B0;
 t0.ColorCloseX:= $7B6E60;
 t0.ColorArrow:= $5C5751;
 t0.ColorArrowOver:= t0.ColorArrow;
{
 t0.AddTab(-1, 'Участок №7');
 t0.AddTab(-1, 'Участок №8', nil, false, clGreen);
 t0.AddTab(-1, 'Узел №9', nil, false, clBlue);    }
end;

procedure TFormM.Image1Click(Sender: TObject);
begin

end;

procedure TFormM.PageControlPasportChange(Sender: TObject);
begin

end;

procedure TFormM.PanelListClick(Sender: TObject);
begin

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
 {if  ActionShowList.Checked then
  begin
    DefaultSettings.PanelList_Width:=PanelList.Width;
    PanelList.Width:=0;
  end
  else
  begin
    if DefaultSettings.PanelList_Width<10
     then DefaultSettings.PanelList_Width:=100;
    PanelList.Width:=DefaultSettings.PanelList_Width;
  end;      }
end;

procedure TFormM.ActionShowMapExecute(Sender: TObject);
begin
  PanelCAD.Align:=alRight;
  PanelMap.Align:=alRight;
 { if not(ActionShowMap.Checked and ActionShowMap.Checked)
   then PanelPassport.Align:=alLeft
   else PanelPassport.Align:=alClient; }
  PanelCAD.Visible:=ActionShowCad.Checked;
  PanelMap.Visible:=ActionShowMap.Checked;
  PanelCAD.Align:=alClient;
  PanelMap.Align:=alClient;
end;

procedure TFormM.ActionShowCadExecute(Sender: TObject);
begin
  PanelCAD.Align:=alRight;
  PanelMap.Align:=alRight;
 { if not(ActionShowMap.Checked and ActionShowMap.Checked)
   then PanelPassport.Align:=alLeft
   else PanelPassport.Align:=alClient; }
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
     ActionShowCadExecute(nil);
     ActionShowCadExecute(nil);
   end;
end;

procedure TFormM.ActionOpenPaspExecute(Sender: TObject);
begin
  if ActivPaspID=const_pasNew
  then  begin
    t0.AddTab(-1, 'Новый паспорт');
    t0.TabIndex:=t0.TabCount-1;
  end
  else begin
    t0.AddTab(-1, DataM.ZQPasspList.FieldByName('pass_name').AsString);
    t0.TabIndex:=t0.TabCount-1;
  end;
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

