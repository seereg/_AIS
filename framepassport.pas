unit FramePassport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ComCtrls, ActnList, attabs,
  FramePassportObjects, FramePassportProperties, unit_types_and_const,
  unit_m_data, KGrids;

type

  { TFramePassport }

  TFramePassport = class(TFrame)
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    ActionList1: TActionList;
    PageControlPassport: TPageControl;
    TabSheet2: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    TabIndex:integer;
    PasspID:integer;
  public
    constructor Create(TheOwner: TComponent;TabOwner:TATTabs;pPasspID:integer); //override;
  end;

implementation

{$R *.lfm}

{ TFramePassport }
var
  FPassportProperties:TFramePassportProperties;

procedure TFramePassport.Action1Execute(Sender: TObject);
begin
  Caption:=Caption;
end;

procedure TFramePassport.Action2Execute(Sender: TObject);
begin
  Caption:=Caption;
end;

constructor TFramePassport.Create(TheOwner: TComponent; TabOwner: TATTabs;
  pPasspID: integer);
var
  i:integer;
  TabSheet:TTabSheet;
begin
  inherited Create(TheOwner);
  self.Parent:=TWinControl(TheOwner);
  self.Name:='FramePassportID'+inttostr(pPasspID);
  self.PasspID:=pPasspID;
  if pPasspID=const_pasNew
   then  begin
     TabOwner.AddTab(-1, 'Новый паспорт');
     TabOwner.TabIndex:=TabOwner.TabCount-1;
   end
   else begin
     TabOwner.AddTab(-1, DataM.ZQPasspList.FieldByName('pass_name').AsString);
     TabOwner.TabIndex:=TabOwner.TabCount-1;
   end;
   for i:=(PageControlPassport.PageCount-1) downto 0
    do PageControlPassport.Pages[i].Destroy;
   self.TabIndex:= TabOwner.TabIndex;
   TabSheet:=PageControlPassport.AddTabSheet;
   TabSheet.Caption:='Свойства';
   FPassportProperties:=TFramePassportProperties.Create(TabSheet);
   FPassportProperties.pass_id:=PasspID;
   FPassportProperties.Parent:=TabSheet;
   FPassportProperties.PageControlPassport:=PageControlPassport;
   FPassportProperties.getDate;
end;

end.

