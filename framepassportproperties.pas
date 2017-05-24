unit FramePassportProperties;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ValEdit, StdCtrls, ExtCtrls,
  DbCtrls, unit_m_data, rxdbgrid;

type

  { TFramePassportProperties }

  TFramePassportProperties = class(TFrame)
    Label1: TLabel;
    RxDBGrid1: TRxDBGrid;
    ValueListEditor1: TValueListEditor;
    ValueListEditor2: TValueListEditor;
  private
    { private declarations }
  public
    { public declarations }
  end;

implementation

{$R *.lfm}

end.

