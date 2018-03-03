unit frameCad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  unit_m_data, framePaint, typePaspProp, typePaspBranch, typePaspElem,
  typePaspObj, Graphics, StdCtrls;

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
      Shift: TShiftState; X, Y: integer);
    procedure CadAreaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure FrameResize(Sender: TObject);
  private
    { private declarations }
    moveX: integer;
    moveY: integer;
    function getCaption(): string;
    procedure setCaption(Value: string);
  public
    { public declarations }
    CadPaint: TFrameCadPaint;
    CadCanvas: TCanvas;
    CadPen: TPen;
    CadBrush: TBrush;
    passport: TPassProp;
    property Caption: string read getCaption write setCaption;
    constructor Create(TheOwner: TComponent); //override;
    procedure setPassport(Pas_ID: integer; User_ID: integer = -1);
  end;

implementation

{$R *.lfm}

{ TFrameCad }

procedure TFrameCad.ActionClearExecute(Sender: TObject);
begin
  CadPaint.resizeCadCanvas(3000, 1000);
  CadPen := CadCanvas.Pen;
  CadPen.Color := clBlack;
  CadPen.Width := 2;
  CadBrush := CadCanvas.Brush;
  CadBrush.Color := backgroundColor;
  CadBrush.Style := bsSolid;
  CadCanvas.Clear;
  CadCanvas.Clear;
end;

procedure TFrameCad.ActionInitExecute(Sender: TObject);
begin
  //CadArea.Left:=     10;
  //CadArea.Top:=      10;
  //moveX:=0;
  //moveY:=0;

  ActionClear.Execute;
end;

procedure TFrameCad.ActionTestExecute(Sender: TObject);
var
  obj, pen: TPoint;
  elem: array of TPoint;
  i, j, k, m, len, spin, p_rad, scale: integer;
  branch: TPassBranch;
  passObj: TPassObj;
  passElem: TPassElem;
  st: string;
  n: double;
  test: array of integer;
begin
  if passport = nil then
    Exit;
  ActionClear.Execute;
  p_rad := 2;
  scale := 2;
  spin := 10 * scale;
  pen.x := 20 * scale;
  pen.y := 0;
  //Определяем кол-во покрытий
  SetLength(elem, passport.getElementGroupsCount);
  for i := 0 to Length(elem) - 1 do
  begin
    elem[i].x := pen.x;
    elem[i].y := pen.y;
    CadPaint.paintText(10 * scale, elem[i].y, 'Покрытие ' +
      IntToStr(passport.getElementGroup(i)));
    //ресуем покрытия вместе с объектами
    pen.y := pen.y + 40 * scale;
  end;

  begin
    for i := 0 to passport.ComponentCount - 1 do
    begin
      try
        CadPen.Width := 2;
        branch := TPassBranch(passport.Components[i]);
        obj.x := pen.x;
        obj.y := pen.y;
        CadPaint.paintLine(10 * scale, obj.y, CadCanvas.Width, obj.y);
        CadPaint.paintText(10 * scale, obj.y, 'Ветка ' + branch.branch_name);
        obj.y := obj.y + 40 * scale;
        if CadCanvas.Height < obj.y + 20 * scale then
          CadPaint.resizeCadCanvas(-1, obj.y + 20 * scale);
        CadPen.Width := 1;
        for j := 0 to branch.ComponentCount - 1 do
          try
            passObj := TPassObj(branch.Components[j]);
            //ресуем покрытия вместе с объектами
            for m := 0 to Length(elem) - 1 do
              elem[m].x := obj.x;
            for k := 0 to passObj.ComponentCount - 1 do
            begin
              passElem := TPassElem(passObj.Components[j]);
              m := StrToInt(passElem.elem_type);
              CadPaint.paintRect(
                elem[m].x,
                elem[m].y,
                elem[m].x + StrToInt(passElem.elem_len),
                elem[m].y+spin);
                elem[m].x:= elem[m].x + StrToInt(passElem.elem_len);
            end;

            st := passObj.obj_len;
            len := round(StrToCurrDef(st, 0)) * scale;
            CadPaint.paintPoint(obj.x, obj.y, p_rad);
            if CadCanvas.Width < obj.x + len + 20 * scale then
              CadPaint.resizeCadCanvas(obj.x + len + 20 * scale, -1);
            if passObj.obj_type = '1' then //прямой
            begin
              CadPaint.paintText(round(obj.x + len * 0.45), obj.y - 20, 'L= ' +
                CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              CadPaint.paintLine(obj.x, obj.y, obj.x + len, obj.y);
              obj.x := obj.x + len;
            end
            else
            if passObj.obj_type = '2' then //лево
            begin
              CadPaint.paintLine(obj.x, obj.y, obj.x, obj.y - spin);
              CadPaint.paintText(round(obj.x + len * 0.45), obj.y - 20 - spin, 'L= ' +
                CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              CadPaint.paintLine(obj.x, obj.y - spin, obj.x + len, obj.y - spin);
              CadPaint.paintLine(obj.x + len, obj.y - spin, obj.x + len, obj.y);
              obj.x := obj.x + len;
            end
            else
            if passObj.obj_type = '3' then //право
            begin
              CadPaint.paintLine(obj.x, obj.y, obj.x, obj.y + spin);
              CadPaint.paintText(round(obj.x + len * 0.45), obj.y - 20 + spin, 'L= ' +
                CurrToStr((StrToCurrDef(st, 0))) + 'м.');
              CadPaint.paintLine(obj.x, obj.y + spin, obj.x + len, obj.y + spin);
              CadPaint.paintLine(obj.x + len, obj.y + spin, obj.x + len, obj.y);
              obj.x := obj.x + len;
            end
            else
            begin
              obj.x := obj.x + len;
            end;
          except
          end;
      except
      end;
      CadPaint.paintPoint(obj.x, obj.y, p_rad);
      pen.y := pen.y + 40 * scale;
      pen.y := pen.y + 40 * scale;
    end;
  end;
  CadPen.Color := clRed;

  //Покрытия

end;

procedure TFrameCad.CadAreaDblClick(Sender: TObject);
begin
  //CadArea.left:=CadArea.left-20;
  //CadArea.Top:=CadArea.Top+3;
  //CadArea.Height:=CadArea.Height+100;
  //resizeCadCanvas(-1,-1)
end;

procedure TFrameCad.CadAreaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  //if (Button=mbMiddle){ and (move)} then   //для кнопки
  //begin
  // moveX:=x;
  // moveY:=y;
  // //toMove:=True;
  //end;
  ////if (moveX<>x) and  (moveY<>y) then   needRefresh:=true;
end;

procedure TFrameCad.CadAreaMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
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
  Result := CadCaption.Caption;
end;

procedure TFrameCad.setCaption(Value: string);
begin
  CadCaption.Caption := Value;
end;

constructor TFrameCad.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  //frame.Parent:=TheOwner;
  CadPaint := TFrameCadPaint.Create(PanelCad);
  CadPaint.Parent := PanelCad;
  CadCanvas := CadPaint.paintbmp.Canvas;
  passport := nil;
end;

procedure TFrameCad.setPassport(Pas_ID: integer; User_ID: integer);
begin
  passport := TPassProp.Create(Pas_ID, User_ID, DataM.ZConnection1, True);
  ActionInit.Execute;
  ActionTest.Execute;
end;

end.
