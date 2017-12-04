unit FramePassport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ComCtrls, ActnList, attabs,
  FramePassportObjects, FramePassportProperties, unit_types_and_const,
  unit_m_data, unitDemoFrame1, typePaspProp, KGrids;

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
    UserID :integer;
  public
    constructor Create(TheOwner: TComponent;TabOwner:TATTabs;pPasspID,pUserID:integer); //override;
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
  pPasspID,pUserID: integer);
var
  i:integer;
  TabSheet:TTabSheet;
  pass:TPassProp;
  FDemoFrame1:TDemoFrame1;
begin
  inherited Create(TheOwner);
  self.Parent:=TWinControl(TheOwner);
  pass:= TPassProp.Create(pPasspID,pUserID,DataM.ZConnection1);
  pPasspID:=strtoint(pass.pass_id);
  self.Name:='FramePassportID'+inttostr(pPasspID);
  self.PasspID:=pPasspID;
  self.UserID :=pUserID;
  TabOwner.AddTab(-1,'Тип-'+pass.pass_type+': '+pass.pass_name+' (ред.)');
  TabOwner.TabIndex:=TabOwner.TabCount-1;
  freeandnil(pass); //  pass.Destroy;
   for i:=(PageControlPassport.PageCount-1) downto 0
    do PageControlPassport.Pages[i].Destroy;
   self.TabIndex:= TabOwner.TabIndex;
   TabSheet:=PageControlPassport.AddTabSheet;
   TabSheet.Caption:='Свойства';
   FPassportProperties:=TFramePassportProperties.Create(TabSheet);
   FPassportProperties.pass_id:=PasspID;
   FPassportProperties.user_id:=UserID;
   FPassportProperties.Parent:=TabSheet;
   
   TabSheet:=PageControlPassport.AddTabSheet;
   TabSheet.Caption:='Продольный профиль';
   FDemoFrame1:=  TDemoFrame1.Create(TabSheet,PasspID,UserID);
   TabSheet:=PageControlPassport.AddTabSheet;
   TabSheet.Caption:='Специальные объекты';
   
   FPassportProperties.PageControlPassport:=PageControlPassport;
   FPassportProperties.getDate;
end;

end.

