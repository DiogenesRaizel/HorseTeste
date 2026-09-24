unit uProdutoRepositoryZeos;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  uDM,
  ZDataset,
  uProdutoRepository,
  uProdutoModel;

type

  { TProdutoRepositoryZeos }

  TProdutoRepositoryZeos = class(
    TInterfacedObject,
    IProdutoRepository
  )
  private
    function CriarProdutoAtual(
      AQuery: TZQuery
    ): TProduto;

    function BuscarInterno(
      AQuery: TZQuery;
      AId: Integer
    ): TProduto;

    procedure LiberarLista(
      ALista: TList
    );
    {
    function SepararValores(
      const AValor: string
    ): TStringList;

    function MontarWhereConsulta(
      const AValor: string;
      out AValores: TStringList
    ): string;

    function PesquisarInterno(
      AQuery: TZQuery;
      const AValor: string
    ): TList;
     }
    function SepararValores(
      const ATexto: string
    ): TStringList;

    function MontarWhereConsulta(
      const AValor: string;
      out AValores: TStringList
    ): string;

  public
    function Listar: TList;
    function Buscar(AId: Integer): TProduto;
    function Inserir(AProduto: TProduto): TProduto;
    function Atualizar(
      AId: Integer;
      AProduto: TProduto
    ): TProduto;
    function Excluir(AId: Integer): Boolean;
    function Pesquisar(const AValor: string): TList;
  end;

implementation

function TProdutoRepositoryZeos.CriarProdutoAtual(
  AQuery: TZQuery
): TProduto;
begin
  Result := TProduto.Create;

  try
    Result.Id :=
      AQuery.FieldByName('id').AsInteger;

    Result.Nome :=
      AQuery.FieldByName('nome').AsString;

    Result.Preco :=
      AQuery.FieldByName('preco').AsCurrency;

    Result.Estoque :=
      AQuery.FieldByName('estoque').AsInteger;

  except
    Result.Free;
    raise;
  end;
end;

function TProdutoRepositoryZeos.BuscarInterno(
  AQuery: TZQuery;
  AId: Integer
): TProduto;
begin
  Result := nil;

  AQuery.Close;

  AQuery.SQL.Text :=
    'SELECT id, nome, preco, estoque ' +
    'FROM produtos ' +
    'WHERE id = :id';

  AQuery.ParamByName('id').AsInteger :=
    AId;

  AQuery.Open;

  if AQuery.EOF then
    Exit;

  Result :=
    CriarProdutoAtual(AQuery);
end;

procedure TProdutoRepositoryZeos.LiberarLista(
  ALista: TList
);
var
  I: Integer;
begin
  if ALista = nil then
    Exit;

  for I := 0 to ALista.Count - 1 do
    TObject(ALista[I]).Free;

  ALista.Free;
end;

function TProdutoRepositoryZeos.SepararValores(
  const ATexto: string
): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;

  Result.Delimiter := ',';
  Result.StrictDelimiter := True;
  Result.DelimitedText := ATexto;

  for I := Result.Count - 1 downto 0 do
  begin
    Result[I] := Trim(Result[I]);

    if Result[I] = '' then
      Result.Delete(I);
  end;
end;

function TProdutoRepositoryZeos.MontarWhereConsulta(
  const AValor: string;
  out AValores: TStringList
): string;
var
  I: Integer;
begin
  AValores := SepararValores(AValor);

  Result := '';

  for I := 0 to AValores.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ' OR ';

    Result :=
      Result +
      '(CAST(id AS TEXT) LIKE :p' + IntToStr(I) +
      ' OR nome LIKE :p' + IntToStr(I) + ')';
  end;
end;

{
function TProdutoRepositoryZeos.SepararValores(const AValor: string): TStringList;
begin

end;

function TProdutoRepositoryZeos.MontarWhereConsulta(const AValor: string; out AValores: TStringList): string;
begin

end;

function TProdutoRepositoryZeos.PesquisarInterno(AQuery: TZQuery; const AValor: string): TList;
begin

end;
 }
function TProdutoRepositoryZeos.Listar: TList;
var
  LDM: TDM;
  LProduto: TProduto;
begin
  Result := TList.Create;

  LDM := TDM.Create(nil);

  try
    try
      LDM.ZQuery1.SQL.Text :=
        'SELECT id, nome, preco, estoque ' +
        'FROM produtos ' +
        'ORDER BY id';

      LDM.ZQuery1.Open;

      while not LDM.ZQuery1.EOF do
      begin
        LProduto :=
          CriarProdutoAtual(LDM.ZQuery1);

        try
          Result.Add(LProduto);
        except
          LProduto.Free;
          raise;
        end;

        LDM.ZQuery1.Next;
      end;

    except
      LiberarLista(Result);
      Result := nil;
      raise;
    end;

  finally
    LDM.Free;
  end;
end;

function TProdutoRepositoryZeos.Buscar(
  AId: Integer
): TProduto;
var
  LDM: TDM;
begin
  Result := nil;

  LDM := TDM.Create(nil);

  try
    Result :=
      BuscarInterno(
        LDM.ZQuery1,
        AId
      );
  finally
    LDM.Free;
  end;
end;

function TProdutoRepositoryZeos.Inserir(
  AProduto: TProduto
): TProduto;
var
  LDM: TDM;
  LId: Integer;
begin
  if AProduto = nil then
    raise EArgumentNilException.Create(
      'Produto nao pode ser nil'
    );

  Result := nil;

  LDM := TDM.Create(nil);

  try
    try
      LDM.ZTransaction1.StartTransaction;

      LDM.ZQuery1.SQL.Text :=
        'INSERT INTO produtos ' +
        '(nome, preco, estoque) ' +
        'VALUES (:nome, :preco, :estoque)';

      LDM.ZQuery1.ParamByName('nome').AsString :=
        AProduto.Nome;

      LDM.ZQuery1.ParamByName('preco').AsCurrency :=
        AProduto.Preco;

      LDM.ZQuery1.ParamByName('estoque').AsFloat :=
        AProduto.Estoque;

      LDM.ZQuery1.ExecSQL;

      LDM.ZQuery1.Close;

      LDM.ZQuery1.SQL.Text :=
        'SELECT last_insert_rowid() AS id';

      LDM.ZQuery1.Open;

      LId :=
        LDM.ZQuery1.FieldByName('id').AsInteger;

      LDM.ZQuery1.Close;

      LDM.ZTransaction1.Commit;

    except
      if LDM.ZTransaction1.Active then
        LDM.ZTransaction1.Rollback;

      raise;
    end;

    Result :=
      BuscarInterno(
        LDM.ZQuery1,
        LId
      );

  finally
    LDM.Free;
  end;
end;

function TProdutoRepositoryZeos.Atualizar(
  AId: Integer;
  AProduto: TProduto
): TProduto;
var
  LDM: TDM;
begin
  if AProduto = nil then
    raise EArgumentNilException.Create(
      'Produto nao pode ser nil'
    );

  Result := nil;

  LDM := TDM.Create(nil);

  try
    try
      LDM.ZTransaction1.StartTransaction;

      LDM.ZQuery1.SQL.Text :=
        'UPDATE produtos ' +
        'SET nome = :nome, ' +
        '    preco = :preco, ' +
        '    estoque = :estoque ' +
        'WHERE id = :id';

      LDM.ZQuery1.ParamByName('id').AsInteger :=
        AId;

      LDM.ZQuery1.ParamByName('nome').AsString :=
        AProduto.Nome;

      LDM.ZQuery1.ParamByName('preco').AsCurrency :=
        AProduto.Preco;

      LDM.ZQuery1.ParamByName('estoque').AsFloat :=
        AProduto.Estoque;

      LDM.ZQuery1.ExecSQL;

      if LDM.ZQuery1.RowsAffected = 0 then
      begin
        LDM.ZTransaction1.Rollback;
        Exit;
      end;

      LDM.ZTransaction1.Commit;

    except
      if LDM.ZTransaction1.Active then
        LDM.ZTransaction1.Rollback;

      raise;
    end;

    Result :=
      BuscarInterno(
        LDM.ZQuery1,
        AId
      );

  finally
    LDM.Free;
  end;
end;

function TProdutoRepositoryZeos.Excluir(
  AId: Integer
): Boolean;
var
  LDM: TDM;
begin
  Result := False;

  LDM := TDM.Create(nil);

  try
    try
      LDM.ZTransaction1.StartTransaction;

      LDM.ZQuery1.SQL.Text :=
        'DELETE FROM produtos ' +
        'WHERE id = :id';

      LDM.ZQuery1.ParamByName('id').AsInteger :=
        AId;

      LDM.ZQuery1.ExecSQL;

      Result :=
        LDM.ZQuery1.RowsAffected > 0;

      LDM.ZTransaction1.Commit;

    except
      if LDM.ZTransaction1.Active then
        LDM.ZTransaction1.Rollback;

      raise;
    end;

  finally
    LDM.Free;
  end;
end;

function TProdutoRepositoryZeos.Pesquisar(
  const AValor: string
): TList;
var
  LDM: TDM;
  LProduto: TProduto;
  LValores: TStringList;
  LSQLWhere: string;
  I: Integer;
begin
  Result := TList.Create;

  LSQLWhere :=
    MontarWhereConsulta(
      AValor,
      LValores
    );

  LDM := TDM.Create(nil);

  try
    try
      LDM.ZQuery1.SQL.Text :=
        'SELECT id, nome, preco, estoque ' +
        'FROM produtos';

      if LSQLWhere <> '' then
        LDM.ZQuery1.SQL.Text :=
          LDM.ZQuery1.SQL.Text +
          ' WHERE ' + LSQLWhere;

      LDM.ZQuery1.SQL.Text :=
        LDM.ZQuery1.SQL.Text +
        ' ORDER BY id';

      for I := 0 to LValores.Count - 1 do
      begin
        LDM.ZQuery1.Params.ParamByName(
          'p' + IntToStr(I)
        ).AsString :=
          '%' + LValores[I] + '%';
      end;

      LDM.ZQuery1.Open;

      while not LDM.ZQuery1.EOF do
      begin
        LProduto :=
          CriarProdutoAtual(
            LDM.ZQuery1
          );

        try
          Result.Add(LProduto);
        except
          LProduto.Free;
          raise;
        end;

        LDM.ZQuery1.Next;
      end;

    except
      LiberarLista(Result);
      Result := nil;
      raise;
    end;

  finally
    LValores.Free;
    LDM.Free;
  end;
end;

end.
