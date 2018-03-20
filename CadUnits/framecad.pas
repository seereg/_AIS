unit frameCad;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, ComCtrls, ActnList,
  unit_m_data, framePaint, typePaspProp, typePaspBranch, typePaspElem,
  typePaspObj, Type_directories, Graphics, StdCtrls;

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
type
  elemTemp = record 
    x: integer;
    y: integer;
    elemCount: Double;
    elemType:integer;
end;
var
  obj, pen: TPoint;
  elem: array [0..1] of array of elemTemp;
  i, j, k, m, len, spin, p_rad, scale, group_id, color_id: integer;
  branch: TPassBranch;
  passObj: TPassObj;
  passElem: TPassElem;
  st: string;
  n: double;
  test: array of integer;
  defColor: TColor;
  directories:TDirectories; { TODO : //нужно проверить освобождение памяти  }
begin
  // Обновляем или заполняем объекты-справочники
  directories := TDirectories.Create(passport.f_conn); //вынисти в общие и не пересоздавать
  
  if passport = nil then
    Exit;
  ActionClear.Execute;
  p_rad := 2;
  scale := 2;
  spin := 10 * scale;
  pen.x := 20 * scale;
  pen.y := 0;
  //Определяем кол-во покрытий
  //путь 1
  SetLength(elem[0], passport.getElementGroupsCount);
  for i := 0 to Length(elem[0]) - 1 do
  begin
    elem[0,i].x := pen.x;
    elem[0,i].y := pen.y;
    CadPaint.paintText(10 * scale, elem[0,i].y,
    directories.getElementGroupName(passport.getElementGroup(i)));
    //IntToStr(passport.getElementGroup(i)));
    //ресуем покрытия вместе с объектами
    pen.y := pen.y + 40 * scale;
  end;
  //путь 2
  SetLength(elem[1], passport.getElementGroupsCount);
  for i := 0 to Length(elem[0]) - 1 do
  begin
    elem[1,i].x := pen.x;
    elem[1,i].y := pen.y + (40 * scale * 4) + (40 * scale*(Length(elem[0]) - 1 - i));
    CadPaint.paintText(10 * scale, elem[1,i].y,
    directories.getElementGroupName(passport.getElementGroup(i)));
    //ресуем покрытия вместе с объектами
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
            if i>1 then break;//только первых 2 пути пока
            passObj := TPassObj(branch.Components[j]);
            //ресуем покрытия вместе с объектами
            defColor:=CadPen.Color;
            for m := 0 to Length(elem[i]) - 1 do
              elem[i,m].x := obj.x;
            for k := 0 to passObj.ComponentCount - 1 do
            begin
              passElem := TPassElem(passObj.Components[k]);
              group_id := StrToInt(passElem.elem_group_id);
              for m := 0 to Length(elem[i]) - 1 do
                if  passport.getElementGroup(m) = group_id then break;
              len := round(StrToCurrDef(passElem.elem_len, 0)) * scale;
              color_id:= strtoint(passElem.elem_type);
              while (color_id>length(ColorArr)-1) do color_id:= color_id - length(ColorArr);
              CadBrush.Color:=ColorArr[color_id];
              CadPen.Color:=ColorArr[color_id];
              CadBrush.Style:=bsSolid;
              CadPaint.paintRect(
                elem[i,m].x,
                elem[i,m].y+spin,
                elem[i,m].x + len,
                elem[i,m].y+spin*2);
                elem[i,m].x:= elem[i,m].x + len;
                if (elem[i,m].elemCount=2.1) 
                 then elem[i,m].elemCount:= 2.9
                 else elem[i,m].elemCount:= 2.1;
                
                CadPen.Color:=defColor;
                CadPaint.paintRect(
                  elem[i,m].x - 1,
                  elem[i,m].y+spin,
                  elem[i,m].x,
                  elem[i,m].y+spin*2);
                CadPen.Color:=ColorArr[color_id];
                
              CadPaint.paintText((elem[i,m].x - len/2), elem[i,m].y+spin*elem[i,m].elemCount,passElem.elem_year + ' - ' + directories.getElementName(strtoint(passElem.elem_type)));
            end;
            
            CadBrush.Color:=defColor;
            CadPen.Color:=defColor;
            CadBrush.Style:=bsClear;
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
