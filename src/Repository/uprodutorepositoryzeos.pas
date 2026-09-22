unit uProdutoRepositoryZeos;

{$MODE DELPHI}{$H+}

interface

uses
  fpjson,
  uProdutoRepository,
  uDM;

type
  TJSONPreco = class(TJSONFloatNumber)
  protected
    function GetAsJSON: TJSONStringType; override;
  end;

  TProdutoRepositoryZeos = class(
    TInterfacedObject,
    IProdutoRepository
  )
  private
    FDM: TDM;

  public
    constructor Create(ADM: TDM);

    function Listar: TJSONArray;

    function Buscar(AId: Integer): TJSONObject;
    function Inserir(AProduto: TJSONObject): TJSONObject;
    function Atualizar(
      AId: Integer;
      AProduto: TJSONObject): TJSONObject;
    function Excluir(AId: Integer): Boolean;
  end;

implementation

uses
  SysUtils;

function TJSONPreco.GetAsJSON: TJSONStringType;
var
  LFormatSettings: TFormatSettings;
begin
  LFormatSettings := DefaultFormatSettings;
  LFormatSettings.DecimalSeparator := '.';

  Result := FormatFloat(
    '0.00',
    AsFloat,
    LFormatSettings
  );
end;

constructor TProdutoRepositoryZeos.Create(ADM: TDM);
begin
  inherited Create;
  FDM := ADM;
end;

function TProdutoRepositoryZeos.Listar: TJSONArray;
var
  LProduto: TJSONObject;
begin
  Result := TJSONArray.Create;

  FDM.ZQuery1.Close;

  FDM.ZQuery1.SQL.Text :=
    'SELECT id, nome, preco, estoque ' +
    'FROM produtos ' +
    'ORDER BY id';

  FDM.ZQuery1.Open;

  while not FDM.ZQuery1.EOF do
  begin
    LProduto := TJSONObject.Create;

    LProduto.Add(
      'id',
      FDM.ZQuery1.FieldByName('id').AsInteger
    );

    LProduto.Add(
      'nome',
      FDM.ZQuery1.FieldByName('nome').AsString
    );

    LProduto.Add(
      'preco',
      TJSONPreco.Create(
        FDM.ZQuery1.FieldByName('preco').AsFloat
      )
    );

    LProduto.Add(
      'estoque',
      FDM.ZQuery1.FieldByName('estoque').AsInteger
    );

    Result.Add(LProduto);

    FDM.ZQuery1.Next;
  end;
end;

function TProdutoRepositoryZeos.Buscar(
  AId: Integer): TJSONObject;
begin
  Result := nil;

  FDM.ZQuery1.Close;
  FDM.ZQuery1.SQL.Text :=
    'SELECT id, nome, preco, estoque ' +
    'FROM produtos ' +
    'WHERE id = :id';

  FDM.ZQuery1.ParamByName('id').AsInteger := AId;
  FDM.ZQuery1.Open;

  if FDM.ZQuery1.EOF then
    Exit;

  Result := TJSONObject.Create;

  Result.Add(
    'id',
    FDM.ZQuery1.FieldByName('id').AsInteger
  );

  Result.Add(
    'nome',
    FDM.ZQuery1.FieldByName('nome').AsString
  );

  Result.Add(
    'preco',
    TJSONPreco.Create(
      FDM.ZQuery1.FieldByName('preco').AsFloat
    )
  );

  Result.Add(
    'estoque',
    FDM.ZQuery1.FieldByName('estoque').AsInteger
  );
end;

function TProdutoRepositoryZeos.Inserir(
  AProduto: TJSONObject): TJSONObject;
var
  LId: Integer;
begin
  Writeln(
    'Preco JSON: ',
    AProduto.Find('preco').AsFloat:0:2
  );

  Writeln(
    'Tipo JSON: ',
    AProduto.Find('preco').ClassName
  );

  FDM.ZTransaction1.StartTransaction;

  try
    FDM.ZQuery1.Close;
    FDM.ZQuery1.SQL.Text :=
      'INSERT INTO produtos (nome, preco, estoque) ' +
      'VALUES (:nome, :preco, :estoque)';

    FDM.ZQuery1.ParamByName('nome').AsString :=
      AProduto.Get('nome', '');

    FDM.ZQuery1.ParamByName('preco').AsFloat :=
      AProduto.Find('preco').AsFloat;

    FDM.ZQuery1.ParamByName('estoque').AsInteger :=
      AProduto.Get('estoque', 0);

    FDM.ZQuery1.ExecSQL;

    FDM.ZQuery1.Close;
    FDM.ZQuery1.SQL.Text :=
      'SELECT last_insert_rowid() AS id';
    FDM.ZQuery1.Open;

    LId := FDM.ZQuery1.FieldByName('id').AsInteger;

    FDM.ZTransaction1.Commit;

    Result := Buscar(LId);
  except
    FDM.ZTransaction1.Rollback;
    raise;
  end;
end;

function TProdutoRepositoryZeos.Atualizar(
  AId: Integer;
  AProduto: TJSONObject): TJSONObject;
begin
  Result := nil;

  FDM.ZTransaction1.StartTransaction;

  try
    FDM.ZQuery1.Close;

    FDM.ZQuery1.SQL.Text :=
      'UPDATE produtos ' +
      'SET nome = :nome, ' +
      '    preco = :preco, ' +
      '    estoque = :estoque ' +
      'WHERE id = :id';

    FDM.ZQuery1.ParamByName('id').AsInteger :=
      AId;

    FDM.ZQuery1.ParamByName('nome').AsString :=
      AProduto.Get('nome', '');

    FDM.ZQuery1.ParamByName('preco').AsFloat :=
      AProduto.Find('preco').AsFloat;

    FDM.ZQuery1.ParamByName('estoque').AsInteger :=
      AProduto.Get('estoque', 0);

    FDM.ZQuery1.ExecSQL;

    if FDM.ZQuery1.RowsAffected = 0 then
    begin
      FDM.ZTransaction1.Rollback;
      Exit;
    end;

    FDM.ZTransaction1.Commit;

    Result := Buscar(AId);

  except
    FDM.ZTransaction1.Rollback;
    raise;
  end;
end;

function TProdutoRepositoryZeos.Excluir(
  AId: Integer): Boolean;
begin
  Result := False;

  FDM.ZTransaction1.StartTransaction;

  try
    FDM.ZQuery1.Close;

    FDM.ZQuery1.SQL.Text :=
      'DELETE FROM produtos ' +
      'WHERE id = :id';

    FDM.ZQuery1.ParamByName('id').AsInteger :=
      AId;

    FDM.ZQuery1.ExecSQL;

    Result := FDM.ZQuery1.RowsAffected > 0;

    FDM.ZTransaction1.Commit;

  except
    FDM.ZTransaction1.Rollback;
    raise;
  end;
end;
end.
