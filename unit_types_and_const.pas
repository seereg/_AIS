unit unit_types_and_const;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, ZDataset, ZConnection;

const
 const_pasNew = 0;
 RT_VERSION   = MakeIntResource(16);

type
  TMyField= record
    name :string;
    Value:string;
    table:string;
  end;

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



 function GetMyVersion:string;
 function GetSQL(iden:string;param:integer):string;

implementation

function GetMyVersion:string;
type
  TVerInfo=packed record
    Nevazhno: array[0..47] of byte; // ненужные нам 48 байт
    Minor,Major,Build,Release: word; // а тут версия
  end;
var
  s:TResourceStream;
  v:TVerInfo;
begin
  result:='';
  try
    s:=TResourceStream.Create(HInstance,'#1',RT_VERSION); // достаём ресурс
    if s.Size>0 then begin
      s.Read(v,SizeOf(v)); // читаем нужные нам байты
      result:=IntToStr(v.Major)+'.'+IntToStr(v.Minor)+'.'+ // вот и версия...
              IntToStr(v.Release)+'.'+IntToStr(v.Build);
    end;
  s.Free;
  except; end;
end;

function GetSQL(iden: string; param: integer): string;
var SQL:string;
begin
  //нужно переделать на внешнее хранение в файлах а iden на список значений(const:int)

  if iden='prop' then
  begin
    sql:=
     '     SELECT                                  '
    +'      pas.pass_type,                         '
    +'      pas.pass_name,                         '
    +'      val1.value year_built,                 '
    +'      val2.value comment                     '
    +'      FROM passports pas                     '
    +'     LEFT JOIN passport_prop_year_built val1 '
    +'      ON val1.pass_id=pas.id                 '
    +'     LEFT JOIN passport_prop_comment val2    '
    +'      ON val2.pass_id=pas.id                 '
    +'      Where pas.id='+inttostr(param)
    ;
  end;
  //-----------------------
  if iden='prop0' then
  begin
    sql:=
     ' SELECT                             '
    +'  localiz.name_text name,           '
    +'  val.value value                   '
    +' FROM                               '
    +' passports pas                      '
    +' LEFT JOIN                          '
    +' passport_prop_year_built val       '
    +' ON val.pass_id=pas.id              '
    +' LEFT JOIN                          '
    +' localization_fields localiz        '
    +' ON localiz.id=1                    '
    +' WHERE pas.id='+inttostr(param)
    +' UNION                              '
    +' SELECT                             '
    +'  localiz.name_text name,           '
    +'  val.value value                   '
    +' FROM                               '
    +' passports pas                      '
    +' LEFT JOIN                          '
    +' passport_prop_comment val          '
    +' ON val.pass_id=pas.id              '
    +' LEFT JOIN                          '
    +' localization_fields localiz        '
    +' ON localiz.id=2                    '
    +' WHERE pas.id='+inttostr(param)
    ;
  end;
    //-----------------------
  if iden='branchs' then
  begin
    sql:=' select * from branch'
        +' where pass_id='+inttostr(param)
        +' '
        ;
  end;
  //-----------------------
  if iden='objects' then
  begin
    sql:=' '
        +' select objects.id id, objects_type.obj_type_name obj_type,'
        +' rad,length, pos from objects                              '
        +' LEFT JOIN objects_type                                    '
        +' on objects.obj_type=objects_type.id                       '
        +' where branch_id='+inttostr(param);
  end;
  //-----------------------
  if iden='objects_type' then
  begin
    sql:=' select * from objects_type'
        +' '
        ;
  end;
  //-----------------------
  if iden='elements' then
  begin
    sql:=' select * from elements'
        +' where object_id='+inttostr(param)
        +' '
        ;
  end;
  //-----------------------
  result:=sql;
end;


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

constructor TPassProp.Create(p_pass_id: integer; conn: TZConnection);
begin
  inherited Create;
  ZQProp:= TZQuery.Create(nil);
  ZQProp.Connection:=conn;
  f_pass_id.value:=inttostr(p_pass_id);
  getDate();
end;

function TPassProp.getDate: boolean;
begin
  try
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

