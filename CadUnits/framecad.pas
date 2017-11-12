unit frameCad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  unit_m_data, typePaspProp, typePaspBranch, typePaspElem, typePaspObj,
  graphics, StdCtrls;

type
  
  { TFrameCad }

  TFrameCad = class(TFrame)
    ActionTest: TAction;
    ActionInit: TAction;
    ActionClear: TAction;
    ActionListCad: TActionList;
    CadArea: TImage;
    CadCaption: TStaticText;
    PanelCad: TPanel;
    ScrollBox1: TScrollBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure ActionClearExecute(Sender: TObject);
    procedure ActionInitExecute(Sender: TObject);
    procedure ActionTestExecute(Sender: TObject);
    procedure CadAreaDblClick(Sender: TObject);
    procedure CadAreaMouseDown(Sender: TObject; Button: TMouseButton; 
      Shift: TShiftState; X, Y: Integer);
    procedure CadAreaMouseMove(Sender: TObject; Shift: TShiftState; X, 
      Y: Integer);
    procedure FrameResize(Sender: TObject);
  private
    { private declarations }
    moveX:Integer;
    moveY:Integer;
    function  getCaption():string;
    procedure setCaption(Value:string);
  public
    { public declarations }
    CadCanvas:TCanvas;
    CadPen:TPen;
    CadBrush:TBrush;
    passport:TPassProp;
    property Caption:string read getCaption  write setCaption;
    constructor Create(TheOwner: TComponent); //override;
    procedure setPassport(Pas_ID: integer;User_ID: integer = -1);
    procedure resizeCadCanvas(pWidth,pHeight: integer);
  end;

implementation

{$R *.lfm}

{ TFrameCad }

procedure TFrameCad.ActionClearExecute(Sender: TObject);
begin
  resizeCadCanvas(1000,200);  
  CadPen:= CadCanvas.Pen;
  CadPen.Color:=clBlack;
  CadPen.Width:=2;
  CadBrush:= CadCanvas.Brush;
  CadBrush.Color:=clMoneyGreen;
  CadBrush.Style:=bsSolid;
  CadCanvas.Clear;
  CadCanvas.Clear;     
end;

procedure TFrameCad.ActionInitExecute(Sender: TObject);
begin
  CadArea.Left:=     10;
  CadArea.Top:=      10;
  moveX:=0;
  moveY:=0;
 
  ActionClear.Execute;
  end;

procedure TFrameCad.ActionTestExecute(Sender: TObject);
var
  i,j,posY: integer;
  branch:TPassBranch;
begin
  if passport=nil then Exit;
  ActionClear.Execute;
  begin 
    for i:=0 to passport.ComponentCount-1 do 
    try
     resizeCadCanvas(-1,CadArea.Height+100);
     branch:=TPassBranch(Components[i]);
     CadCanvas.MoveTo(10,CadArea.Height-50);
     CadCanvas.MoveTo(20,20);
     CadCanvas.TextOut(CadCanvas.PenPos.X,CadCanvas.PenPos.Y,'Ветка - ID:'+intToStr(branch.branch_id));
     CadCanvas.LineTo(Width,CadCanvas.PenPos.Y);
    except end;
  end;
  j:=0;
  CadPen.Color:=clRed;
  while (j<CadArea.Height) do 
  begin
    CadCanvas.MoveTo(1,j);
    CadCanvas.LineTo(Width,CadCanvas.PenPos.Y);
    j:=j+50;
    CadPen.Color:=clBlack;
  end;

  //Покрытия
  //
  //
  //
end;

procedure TFrameCad.CadAreaDblClick(Sender: TObject);
begin
  CadArea.left:=CadArea.left-20;
  CadArea.Top:=CadArea.Top+3;
  CadArea.Height:=CadArea.Height+100;
  resizeCadCanvas(-1,-1)
end;

procedure TFrameCad.CadAreaMouseDown(Sender: TObject; Button: TMouseButton; 
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button=mbMiddle){ and (move)} then   //для кнопки
  begin
   moveX:=x;
   moveY:=y;
   //toMove:=True;
  end;
  //if (moveX<>x) and  (moveY<>y) then   needRefresh:=true;
end;

procedure TFrameCad.CadAreaMouseMove(Sender: TObject; Shift: TShiftState; X, 
  Y: Integer);
begin
  //if needRefresh then
  //begin
  //  CAD_pas.Refresh;
  //end;
  if (Shift = [ssCtrl]) {or toMove} then
    begin
     CadArea.Left:=Round(CadArea.Left -(moveX-X)/2);
     CadArea.Top :=Round(CadArea.Top  -(moveY-Y)/2);
     if CadArea.Left <PanelCad.Width-CadArea.Width then CadArea.Left:=PanelCad.Width-CadArea.Width;
     if CadArea.Top  <PanelCad.Height-CadArea.Height then CadArea.Top:=PanelCad.Height-CadArea.Height;
     if CadArea.Left >10 then CadArea.Left:=10;
     if CadArea.Top >10 then CadArea.Top:=10;
     //ActionTest.Execute;
     //CadArea.Repaint;
     self.Top:=1;
     //needRefresh:=true;
    end
  else
    begin
     moveX:=x;
     moveY:=y;
    end;
end;

procedure TFrameCad.FrameResize(Sender: TObject);
begin
  ActionTest.Execute;
end;

function TFrameCad.getCaption: string;
begin
    result:= CadCaption.Caption;
end;

procedure TFrameCad.setCaption(Value: string);
begin
   CadCaption.Caption:= Value;
end;

constructor TFrameCad.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  passport:=nil;
end;

procedure TFrameCad.setPassport(Pas_ID: integer; User_ID: integer);
begin
  passport:= TPassProp.Create(Pas_ID,User_ID,DataM.ZConnection1,true);
  ActionInit.Execute;
  ActionTest.Execute; 
end;

procedure TFrameCad.resizeCadCanvas(pWidth, pHeight: integer);
begin
  if pWidth >0 then CadArea.Width :=pWidth;
  if pHeight>0 then CadArea.Height:=pHeight;
  CadCanvas:= CadArea.Canvas;
  CadCanvas.Width;
end;

end.

