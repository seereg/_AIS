unit typepaspobj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,ZDataset, ZConnection, unit_types_and_const;

type

  { TPassObj }

  TPassObj = class(TObject)
  private
    { private declarations }
    f_obj_type  :TMyField;
    f_pass_id    :TMyField;
    f_pass_name  :TMyField;
    f_year_built :TMyField;
    f_comment    :TMyField;
    ZQProp: TZQuery;
    function  getValue(Index:Integer):string;
    procedure setValue(Index:Integer; Value:string);
  public
    { public declarations }
    property pass_id     :string          read f_pass_id.Value  write f_pass_id.Value;
    property pass_type   :string  Index 0 read getValue  write setValue;
    property pass_name   :string  Index 1 read getValue  write setValue;
    property year_built  :string  Index 2 read getValue  write setValue;
    property comment     :string  Index 3 read getValue  write setValue;
    constructor Create(p_pass_id:integer;conn:TZConnection);
    function getDate():boolean;
  end;

implementation

{ TPassProp }

function TPassObj.getValue(Index: Integer): string;
var
  fld:^TMyField;
begin
  try
    case index of
    0: fld:=addr(f_obj_type);
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

procedure TPassObj.setValue(Index: Integer; Value: string);
var
  fld:^TMyField;
  st:string;
begin
  try
    ZQProp.SQL.Clear;
    case index of
    0: fld:=addr(f_obj_type);
    1: fld:=addr(f_pass_name);
    2: fld:=addr(f_year_built);
    3: fld:=addr(f_comment);
    else exit;
    end;
    if Value=fld^.Value then exit;
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
    fld^.Value:=Value;
  except
  end;
end;

constructor TPassObj.Create(p_pass_id: integer; conn: TZConnection);
begin
  inherited Create;
  ZQProp:= TZQuery.Create(nil);
  ZQProp.Connection:=conn;
  f_pass_id.value:=inttostr(p_pass_id);
  getDate();
end;

function TPassObj.getDate: boolean;
begin
  try
  ZQProp.Close;
  ZQProp.SQL.Clear;
  ZQProp.SQL.Add(GetSQL('prop',StrToInt(pass_id)));
  ZQProp.Open;

  f_obj_type.name   := 'pass_type';
  f_obj_type.table  := 'passports';
  f_obj_type.value  := ZQProp.FieldByName('pass_type') .AsString;

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

