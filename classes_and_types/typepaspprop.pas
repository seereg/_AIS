unit typePaspProp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZConnection, unit_types_and_const, unit_m_data;

type

  { TPassProp }

  TPassProp = class(TObject)
  private
    { private declarations }
    f_pass_type  :TMyField;
    f_pass_id    :TMyField;
    f_pass_name  :TMyField;
    f_year_built :TMyField;
    f_comment    :TMyField;
    f_conn       : TZConnection;
    ZQProp       : TZQuery;
    function  getValue(Index:Integer):string;
    procedure setValue(Index:Integer; Value:string);
    function  getNewID:integer;
    procedure rewValue(Index:Integer);
  public
    { public declarations }
    property pass_id     :string          read f_pass_id.Value  write f_pass_id.Value;
    property pass_type   :string  Index 0 read getValue  write setValue;
    property pass_name   :string  Index 1 read getValue  write setValue;
    property year_built  :string  Index 2 read getValue  write setValue;
    property comment     :string  Index 3 read getValue  write setValue;
    constructor Create(p_pass_id:integer;p_conn:TZConnection);
    function getDate():boolean;
  end;

implementation

{ TPassProp }

function TPassProp.getValue(Index: Integer): string;
var
  fld:^TMyField;
begin
  try
    case index of
    0: fld:=addr(f_pass_type);
    1: fld:=addr(f_pass_name);
    2: fld:=addr(f_year_built);
    3: fld:=addr(f_comment);
    else exit;
    end;
    result:=fld^.Value;
  except
    result:='';
  end;
end;

procedure TPassProp.setValue(Index: Integer; Value: string);
var
  fld:^TMyField;
  st:string;
begin
  try
    ZQProp.SQL.Clear;
    case index of
    0: fld:=addr(f_pass_type);
    1: fld:=addr(f_pass_name);
    2: fld:=addr(f_year_built);
    3: fld:=addr(f_comment);
    else exit;
    end;
    if Value=fld^.Value then exit;
{    if (StrToIntDef(f_pass_id.Value,-1)<0) and (index in [0,1]) //ненужно пока
       then begin
         f_pass_id.Value:=inttostr(getNewID);
         st:='INSERT INTO passports (id) VALUES ('+f_pass_id.Value+')';
         rewValue(0);//переписать по id
         rewValue(1);//переписать по id
         rewValue(2);//переписать по id
         rewValue(3);//переписать по id
       end;     }
    if not(StrToIntDef(f_pass_id.Value,-1)<0) then
    begin
      ZQProp.SQL.Clear;
      if fld^.table='passports'
      then  st:='Update '+ fld^.table+' set '+fld^.name+'="'+Value+'" where id='+f_pass_id.Value
      else
        begin
          st:='INSERT OR IGNORE INTO '+ fld^.table+' (pass_id) VALUES ('+f_pass_id.Value+')';
          ZQProp.SQL.Add(st);
          ZQProp.ExecSQL;
          ZQProp.SQL.Clear;
          st:='Update '+ fld^.table+' set value ="'+Value+'" where pass_id='+f_pass_id.Value;
        end;
      ZQProp.SQL.Add(st);
      ZQProp.ExecSQL;
      DataM.passListRefresh();
    end;
    fld^.Value:=Value;
  except
  end;
end;

function TPassProp.getNewID: integer;
var
  ZQ: TZQuery;
begin
    ZQ:= TZQuery.Create(nil);
    ZQ.Connection:=f_conn;
    ZQ.SQL.Text:=GetSQL('pass_new_id',0);
    ZQ.Open;
  try
    result:=ZQ.FieldByName('id').AsInteger;
  except
    result:=0;
  end;
  FreeAndNil(ZQ);
end;

procedure TPassProp.rewValue(Index: Integer);
var
  fld:^TMyField;
  st:string;
begin
  case index of
    0: fld:=addr(f_pass_type);
    1: fld:=addr(f_pass_name);
    2: fld:=addr(f_year_built);
    3: fld:=addr(f_comment);
  else exit;
  end;
  st:=fld^.Value;
  fld^.Value:='';
  setValue(Index,st); //переписать по id
end;

constructor TPassProp.Create(p_pass_id: integer;p_conn: TZConnection);
begin
  inherited Create;
  ZQProp:= TZQuery.Create(nil);
  f_conn:= p_conn;
  ZQProp.Connection:=f_conn;
  f_pass_id.value:=inttostr(p_pass_id);
  getDate();
end;

function TPassProp.getDate: boolean;
var
  st:string;
begin
  try
  if  (StrToIntDef(f_pass_id.Value,-1)<0) then
  begin
     f_pass_id.Value:=inttostr(getNewID);
     st:='INSERT INTO passports (id) VALUES ('+f_pass_id.Value+')';
     ZQProp.SQL.Clear;
     ZQProp.SQL.text:=st;
     ZQProp.Open;
  end;

  ZQProp.Close;
  ZQProp.SQL.Clear;
  ZQProp.SQL.Add(GetSQL('prop',StrToInt(pass_id)));
  ZQProp.Open;

  f_pass_type.name   := 'pass_type';
  f_pass_type.table  := 'passports';
  f_pass_type.value  := ZQProp.FieldByName('pass_type') .AsString;

  f_pass_name.name   := 'pass_name';
  f_pass_name.table  := 'passports';
  f_pass_name.value  := ZQProp.FieldByName('pass_name') .AsString;

  f_year_built.name  := 'year_built';
  f_year_built.table := 'passport_prop_year_built';
  f_year_built.value := ZQProp.FieldByName('year_built').AsString;

  f_comment.name     := 'comment';
  f_comment.table    := 'passport_prop_comment';
  f_comment.value    := ZQProp.FieldByName('comment').AsString;
  except
    result:=false;
  end;
  result:=True;
end;

end.

