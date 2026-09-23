unit uProdutoRepositoryZeos;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  uProdutoRepository,
  uProdutoModel,
  uDM;

type

  TProdutoRepositoryZeos = class(
    TInterfacedObject,
    IProdutoRepository
  )
  private
    FDM: TDM;

    function CriarProdutoAtual: TProduto;

    function BuscarInterno(
      AId: Integer
    ): TProduto;

  public
    constructor Create(
      ADM: TDM
    );

    function Listar: TList;

    function Buscar(
      AId: Integer
    ): TProduto;

    function Inserir(
      AProduto: TProduto
    ): TProduto;

    function Atualizar(
      AId: Integer;
      AProduto: TProduto
    ): TProduto;

    function Excluir(
      AId: Integer
    ): Boolean;
  end;

implementation

uses
  SysUtils;

constructor TProdutoRepositoryZeos.Create(
  ADM: TDM
);
begin
  inherited Create;

  if ADM = nil then
    raise EArgumentNilException.Create(
      'DataModule nao pode ser nil'
    );

  FDM := ADM;
end;

function TProdutoRepositoryZeos.CriarProdutoAtual: TProduto;
begin
  Result := TProduto.Create;

  try
    Result.Id :=
      FDM.ZQuery1.FieldByName('id').AsInteger;

    Result.Nome :=
      FDM.ZQuery1.FieldByName('nome').AsString;

    Result.Preco :=
      FDM.ZQuery1.FieldByName('preco').AsCurrency;

    Result.Estoque :=
      FDM.ZQuery1.FieldByName('estoque').AsInteger;

  except
    Result.Free;
    raise;
  end;
end;

function TProdutoRepositoryZeos.BuscarInterno(
  AId: Integer
): TProduto;
begin
  Result := nil;

  FDM.ZQuery1.Close;

  FDM.ZQuery1.SQL.Text :=
    'SELECT id, nome, preco, estoque ' +
    'FROM produtos ' +
    'WHERE id = :id';

  FDM.ZQuery1.ParamByName('id').AsInteger :=
    AId;

  FDM.ZQuery1.Open;

  if FDM.ZQuery1.EOF then
    Exit;

  Result :=
    CriarProdutoAtual;
end;

function TProdutoRepositoryZeos.Listar: TList;
var
  LProduto: TProduto;
begin
  Result := TList.Create;

  FDM.Enter;

  try
    try
      FDM.ZQuery1.Close;

      FDM.ZQuery1.SQL.Text :=
        'SELECT id, nome, preco, estoque ' +
        'FROM produtos ' +
        'ORDER BY id';

      FDM.ZQuery1.Open;

      while not FDM.ZQuery1.EOF do
      begin
        LProduto :=
          CriarProdutoAtual;

        try
          Result.Add(LProduto);
        except
          LProduto.Free;
          raise;
        end;

        FDM.ZQuery1.Next;
      end;

    except
      Result.Free;
      raise;
    end;

  finally
    FDM.Leave;
  end;
end;

function TProdutoRepositoryZeos.Buscar(
  AId: Integer
): TProduto;
begin
  Result := nil;

  FDM.Enter;

  try
    Result :=
      BuscarInterno(AId);
  finally
    FDM.Leave;
  end;
end;

function TProdutoRepositoryZeos.Inserir(
  AProduto: TProduto
): TProduto;
var
  LId: Integer;
begin
  if AProduto = nil then
    raise EArgumentNilException.Create(
      'Produto nao pode ser nil'
    );

  Result := nil;

  FDM.Enter;

  try
    FDM.ZTransaction1.StartTransaction;

    try
      FDM.ZQuery1.Close;

      FDM.ZQuery1.SQL.Text :=
        'INSERT INTO produtos ' +
        '(nome, preco, estoque) ' +
        'VALUES (:nome, :preco, :estoque)';

      FDM.ZQuery1.ParamByName('nome').AsString :=
        AProduto.Nome;

      FDM.ZQuery1.ParamByName('preco').AsCurrency :=
        AProduto.Preco;

      FDM.ZQuery1.ParamByName('estoque').AsInteger :=
        AProduto.Estoque;

      FDM.ZQuery1.ExecSQL;

      FDM.ZQuery1.Close;

      FDM.ZQuery1.SQL.Text :=
        'SELECT last_insert_rowid() AS id';

      FDM.ZQuery1.Open;

      LId :=
        FDM.ZQuery1.FieldByName('id').AsInteger;

      FDM.ZTransaction1.Commit;

      Result :=
        BuscarInterno(LId);

    except
      if FDM.ZTransaction1.Active then
        FDM.ZTransaction1.Rollback;

      raise;
    end;

  finally
    FDM.Leave;
  end;
end;

function TProdutoRepositoryZeos.Atualizar(
  AId: Integer;
  AProduto: TProduto
): TProduto;
begin
  if AProduto = nil then
    raise EArgumentNilException.Create(
      'Produto nao pode ser nil'
    );

  Result := nil;

  FDM.Enter;

  try
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
        AProduto.Nome;

      FDM.ZQuery1.ParamByName('preco').AsCurrency :=
        AProduto.Preco;

      FDM.ZQuery1.ParamByName('estoque').AsInteger :=
        AProduto.Estoque;

      FDM.ZQuery1.ExecSQL;

      if FDM.ZQuery1.RowsAffected = 0 then
      begin
        FDM.ZTransaction1.Rollback;
        Exit;
      end;

      FDM.ZTransaction1.Commit;

      Result :=
        BuscarInterno(AId);

    except
      if FDM.ZTransaction1.Active then
        FDM.ZTransaction1.Rollback;

      raise;
    end;

  finally
    FDM.Leave;
  end;
end;

function TProdutoRepositoryZeos.Excluir(
  AId: Integer
): Boolean;
begin
  Result := False;

  FDM.Enter;

  try
    FDM.ZTransaction1.StartTransaction;

    try
      FDM.ZQuery1.Close;

      FDM.ZQuery1.SQL.Text :=
        'DELETE FROM produtos ' +
        'WHERE id = :id';

      FDM.ZQuery1.ParamByName('id').AsInteger :=
        AId;

      FDM.ZQuery1.ExecSQL;

      Result :=
        FDM.ZQuery1.RowsAffected > 0;

      FDM.ZTransaction1.Commit;

    except
      if FDM.ZTransaction1.Active then
        FDM.ZTransaction1.Rollback;

      raise;
    end;

  finally
    FDM.Leave;
  end;
end;

end.

