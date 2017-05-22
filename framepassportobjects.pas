unit FramePassportObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, KGrids, KFunctions;

type

  { TFramePassportObjects }

  TFramePassportObjects = class(TFrame)
    KGrid: TKGrid;
  private
    { private declarations }
    procedure AddObject (ACol,ARow:integer);
    procedure AddElement(ACol,ARow:integer);
  public
    { public declarations }
    constructor Create(TheOwner: TComponent); override;
  end;

implementation

{$R *.lfm}

{ TFramePassportObjects }

procedure TFramePassportObjects.AddObject(ACol, ARow: integer);
begin
  KGrid.Cells[0, ARow] := '-';
  KGrid.CellSpan[1, ARow] := MakeCellSpan(3, 1);
  KGrid.Cells[1, ARow] := 'Прямой участок';
  KGrid.Cells[4, ARow] := '250 м.';
end;

procedure TFramePassportObjects.AddElement(ACol, ARow: integer);
begin
  KGrid.Cells[0, ARow] := '1';
  KGrid.CellSpan[1, ARow] := MakeCellSpan(3, 1);
  KGrid.Cells[1, ARow] := 'Рельса П-65';
  KGrid.Cells[4, ARow] := '50 м.';
  ARow:=ARow+1;
  KGrid.Cells[0, ARow] := '2';
  KGrid.CellSpan[1, ARow] := MakeCellSpan(3, 1);
  KGrid.Cells[1, ARow] := 'Рельса П-54';
  KGrid.Cells[4, ARow] := '200 м.';
end;

constructor TFramePassportObjects.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  KGrid.Cells[0, 0] := '№';
  KGrid.CellSpan[1, 0] := MakeCellSpan(3, 1);
  KGrid.Cells[1, 0] := 'Тип';
  KGrid.Cells[4, 0] := 'Длина';
  AddObject(0,1);
  AddElement(0,2);
end;

end.

