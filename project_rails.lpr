program project_rails;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, unit_m, unit_fr_pasport, unit_m_data, zcomponent, rxnew,
unit_types_and_const, FramePassportProperties, FramePassportObjects
  { you can add units after this };

{$R *.res}
begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TDataM, DataM);
  Application.CreateForm(TFormM, FormM);
  Application.Run;
end.
