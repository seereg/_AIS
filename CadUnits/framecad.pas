unit frameCad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  unit_m_data, framePaint, typePaspProp, typePaspBranch, typePaspElem,
  typePaspObj, graphics, StdCtrls;

type
  
  { TFrameCad }

  TFrameCad = class(TFrame)
    ActionTest: TAction;
    ActionInit: TAction;
    ActionClear: TAction;
    ActionListCad: TActionList;
    CadCaption: TStaticText;
    PanelCad: TPanel;
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
    CadPaint: TFrameCadPaint;
    CadCanvas:TCanvas;
    CadPen:TPen;
    CadBrush:TBrush;
    passport:TPassProp;
    property Caption:string read getCaption  write setCaption;
    constructor Create(TheOwner: TComponent); //override;
    procedure setPassport(Pas_ID: integer;User_ID: integer = -1);
  end;

implementation

{$R *.lfm}

{ TFrameCad }

procedure TFrameCad.ActionClearExecute(Sender: TObject);
begin
  CadPaint.resizeCadCanvas(3000,800);  
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
  //CadArea.Left:=     10;
  //CadArea.Top:=      10;
  //moveX:=0;
  //moveY:=0;
  //
  ActionClear.Execute;
  end;

procedure TFrameCad.ActionTestExecute(Sender: TObject);
var
  i,j,posX,posY,len,spin,p_rad,scale: integer;
  branch:TPassBranch;
  PassObj:TPassObj;
  st:string;
  n:double;
begin
  if passport=nil then Exit;
  ActionClear.Execute;
  posY:=  0;
  p_rad:= 2;
  scale:= 2;
  spin:= 10*scale;
  begin 
    for i:=0 to passport.ComponentCount-1 do
    begin
      try
       CadPen.Width:=2;
       branch:=TPassBranch(passport.Components[i]);
       posX:=20*scale;
       posY:=posY+40*scale;
       CadPaint.paintLine(10*scale,posY,CadCanvas.Width,posY);
       CadPaint.paintText(10*scale,posY,'Ветка '+ branch.branch_name);
       posY:=posY+40*scale;
       if CadCanvas.Height<posY+20*scale then CadPaint.resizeCadCanvas(-1,posY+20*scale);
       CadPen.Width:=1;
       for j:=0 to branch.ComponentCount-1 do 
         try
          PassObj:=TPassObj(branch.Components[j]);
          //st:=StringReplace(PassObj.obj_len, ',', '.', [rfReplaceAll]);
          st:=PassObj.obj_len;
          len:=round(StrToCurrDef(st,0))*scale;
          CadPaint.paintPoint(posX,posY,p_rad);
          if CadCanvas.Width<posX+len+20*scale then CadPaint.resizeCadCanvas(posX+len+20*scale,-1);
          if PassObj.obj_type = '1' then //прямой
          begin
            CadPaint.paintText(round(posX+len*0.45),posY-20,'L= '+ CurrToStr((StrToCurrDef(st,0)))+'м.');
            CadPaint.paintLine(posX,posY,posX+len,posY);
            posX:=posX+len;
          end else
          if PassObj.obj_type = '2' then //лево
          begin
            CadPaint.paintLine(posX,posY,posX,posY-spin);
            CadPaint.paintText(round(posX+len*0.45),posY-20-spin,'L= '+ CurrToStr((StrToCurrDef(st,0)))+'м.');
            CadPaint.paintLine(posX,posY-spin,posX+len,posY-spin);
            CadPaint.paintLine(posX+len,posY-spin,posX+len,posY);
            posX:=posX+len;
          end else
          if PassObj.obj_type = '3' then //право
          begin
            CadPaint.paintLine(posX,posY,posX,posY+spin);
            CadPaint.paintText(round(posX+len*0.45),posY-20+spin,'L= '+ CurrToStr((StrToCurrDef(st,0)))+'м.');
            CadPaint.paintLine(posX,posY+spin,posX+len,posY+spin);
            CadPaint.paintLine(posX+len,posY+spin,posX+len,posY);
            posX:=posX+len;
          end else
          begin
            posX:=posX+len;
          end;
         except end;      
      except end;
      CadPaint.paintPoint(posX,posY,p_rad);
    end;
  end;
  CadPen.Color:=clRed;
  
  //Покрытия
  //
  //
  //
end;

procedure TFrameCad.CadAreaDblClick(Sender: TObject);
begin
  //CadArea.left:=CadArea.left-20;
  //CadArea.Top:=CadArea.Top+3;
  //CadArea.Height:=CadArea.Height+100;
  //resizeCadCanvas(-1,-1)
end;

procedure TFrameCad.CadAreaMouseDown(Sender: TObject; Button: TMouseButton; 
  Shift: TShiftState; X, Y: Integer);
begin
  //if (Button=mbMiddle){ and (move)} then   //для кнопки
  //begin
  // moveX:=x;
  // moveY:=y;
  // //toMove:=True;
  //end;
  ////if (moveX<>x) and  (moveY<>y) then   needRefresh:=true;
end;

procedure TFrameCad.CadAreaMouseMove(Sender: TObject; Shift: TShiftState; X, 
  Y: Integer);
begin
  //if needRefresh then
  //begin
  //  CAD_pas.Refresh;
  //end;
  //if (Shift = [ssCtrl]) {or toMove} then
  //  begin
  //   CadArea.Left:=Round(CadArea.Left -(moveX-X)/2);
  //   CadArea.Top :=Round(CadArea.Top  -(moveY-Y)/2);
  //   if CadArea.Left <PanelCad.Width-CadArea.Width then CadArea.Left:=PanelCad.Width-CadArea.Width;
  //   if CadArea.Top  <PanelCad.Height-CadArea.Height then CadArea.Top:=PanelCad.Height-CadArea.Height;
  //   if CadArea.Left >10 then CadArea.Left:=10;
  //   if CadArea.Top >10 then CadArea.Top:=10;
  //   //ActionTest.Execute;
  //   //CadArea.Repaint;
  //   self.Top:=1;
  //   //needRefresh:=true;
  //  end
  //else
  //  begin
  //   moveX:=x;
  //   moveY:=y;
  //  end;
end;

procedure TFrameCad.FrameResize(Sender: TObject);
begin
  //ActionTest.Execute;
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
  //frame.Parent:=TheOwner;
  CadPaint:= TFrameCadPaint.Create(PanelCad);
  CadPaint.Parent:= PanelCad;
  CadCanvas:=CadPaint.paintbmp.Canvas;
  passport:=nil;
end;

procedure TFrameCad.setPassport(Pas_ID: integer; User_ID: integer);
begin
  passport:= TPassProp.Create(Pas_ID,User_ID,DataM.ZConnection1,true);
  ActionInit.Execute;
  ActionTest.Execute; 
end;

end.

