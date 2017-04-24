unit unit_m_data;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Controls, ActnList, Menus, ZConnection,
  ZDataset;

type

  { TDataM }

  TDataM = class(TDataModule)
    DSPasspList: TDataSource;
    DSPasspTypeList: TDataSource;
    IL_16: TImageList;
    IL_64: TImageList;
    ZConnection1: TZConnection;
    ZQPasspList: TZQuery;
    ZQPasspTypeList: TZQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure ZQPasspTypeListAfterOpen(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataM: TDataM;

implementation

{$R *.lfm}
uses unit_m;
{ TDataM }

procedure TDataM.ZQPasspTypeListAfterOpen(DataSet: TDataSet);
begin
  FormM.PasspTypeListAfterUpdate();
end;

procedure TDataM.DataModuleCreate(Sender: TObject);
begin
end;

end.

