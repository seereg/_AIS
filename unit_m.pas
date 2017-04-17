unit unit_m;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Menus, ActnList, Buttons, StdCtrls, attabs;

type

  { TForm1 }

  TForm1 = class(TForm)
    ActionShowMap: TAction;
    ActionShowCad: TAction;
    ActionShowPasp: TAction;
    ActionList1: TActionList;
    ActionShowList: TAction;
    ActionTabClose: TAction;
    MI_Close: TMenuItem;
    PageControl1: TPageControl;
    PanelTool: TPanel;
    PanelCAD: TPanel;
    PanelList: TPanel;
    PanelPassport: TPanel;
    PopupMenuTabs: TPopupMenu;
    SpeedButtonSearch: TSpeedButton;
    SpeedButtonMap: TSpeedButton;
    SpeedButtonCad: TSpeedButton;
    SpeedButtonPassp: TSpeedButton;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure ActionShowListExecute(Sender: TObject);
    procedure ActionShowPaspExecute(Sender: TObject);
    procedure ActionTabCloseExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure PageControlPasportChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    t0: TATTabs;
  end;

var
  Form1: TForm1;
  DefaultSettings:record
   PanelList_Show:boolean;
   PanelList_Width:integer;
  end;

implementation

{$R *.lfm}

{ TForm1 }


procedure TForm1.ActionTabCloseExecute(Sender: TObject);
begin
//  if (Sender is TTabSheet) then   TTabSheet(sender).Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
 //Firefox rectangle tabs
 t0:= TATTabs.Create(PanelPassport);
 t0.Parent:= PanelPassport;
 t0.Align:= alTop;
 t0.Font.Size:= 8;

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

 t0.AddTab(-1, 'Участок №7');
 t0.AddTab(-1, 'Участок №8', nil, false, clGreen);
 t0.AddTab(-1, 'Узел №9', nil, false, clBlue);
end;

procedure TForm1.Image1Click(Sender: TObject);
begin

end;

procedure TForm1.PageControlPasportChange(Sender: TObject);
begin

end;

procedure TForm1.ActionShowListExecute(Sender: TObject);
begin
 if  ActionShowList.Checked then
  begin
    DefaultSettings.PanelList_Width:=PanelList.Width;
    PanelList.Width:=0;
  end
  else
  begin
    if DefaultSettings.PanelList_Width<10
     then DefaultSettings.PanelList_Width:=100;
    PanelList.Width:=DefaultSettings.PanelList_Width;
  end;
  ActionShowList.Checked:=not(ActionShowList.Checked);
  SpeedButtonSearch.Down:=ActionShowList.Checked;
end;

procedure TForm1.ActionShowPaspExecute(Sender: TObject);
begin
  try
  tSpeedButton(Sender).Down:=not(tSpeedButton(Sender).Down);
  finally
  end;
end;



end.

