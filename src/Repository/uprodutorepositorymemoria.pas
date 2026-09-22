unit uProdutoRepositoryMemoria;

{$MODE DELPHI}{$H+}

interface

uses
  fpjson,
  uProdutoRepository;

type
  TProdutoRepositoryMemoria = class(TInterfacedObject, IProdutoRepository)
  private
    FProdutos: TJSONArray;
    FProximoId: Integer;

    procedure InicializarProdutos;

  public
    constructor Create;
    destructor Destroy; override;

    function Listar: TJSONArray;
    function Buscar(AId: Integer): TJSONObject;
    function Inserir(AProduto: TJSONObject): TJSONObject;
    function Atualizar(
      AId: Integer;
      AProduto: TJSONObject): TJSONObject;
    function Excluir(AId: Integer): Boolean;
  end;

implementation

constructor TProdutoRepositoryMemoria.Create;
begin
  inherited Create;

  FProdutos := TJSONArray.Create;
  FProximoId := 1;

  InicializarProdutos;
end;

destructor TProdutoRepositoryMemoria.Destroy;
begin
  FProdutos.Free;

  inherited Destroy;
end;

procedure TProdutoRepositoryMemoria.InicializarProdutos;
var
  LProduto: TJSONObject;
begin
  LProduto := TJSONObject.Create;
  LProduto.Add('id', FProximoId);
  LProduto.Add('nome', 'Arroz 5kg');
  LProduto.Add('preco', 25.90);
  LProduto.Add('estoque', 10);
  FProdutos.Add(LProduto);
  Inc(FProximoId);

  LProduto := TJSONObject.Create;
  LProduto.Add('id', FProximoId);
  LProduto.Add('nome', 'Feijao 1kg');
  LProduto.Add('preco', 8.50);
  LProduto.Add('estoque', 20);
  FProdutos.Add(LProduto);
  Inc(FProximoId);
end;

function TProdutoRepositoryMemoria.Listar: TJSONArray;
begin
  Result := FProdutos;
end;

function TProdutoRepositoryMemoria.Buscar(
  AId: Integer): TJSONObject;
var
  I: Integer;
  LProduto: TJSONObject;
begin
  Result := nil;

  for I := 0 to FProdutos.Count - 1 do
  begin
    LProduto := FProdutos.Objects[I];

    if LProduto.Get('id', 0) = AId then
    begin
      Result := LProduto;
      Exit;
    end;
  end;
end;

function TProdutoRepositoryMemoria.Inserir(
  AProduto: TJSONObject): TJSONObject;
begin
  Result := TJSONObject.Create;

  Result.Add('id', FProximoId);
  Result.Add('nome', AProduto.Get('nome', ''));
  Result.Add('preco', AProduto.Get('preco', 0.0));
  Result.Add('estoque', AProduto.Get('estoque', 0));

  FProdutos.Add(Result);
  Inc(FProximoId);
end;

function TProdutoRepositoryMemoria.Atualizar(
  AId: Integer;
  AProduto: TJSONObject): TJSONObject;
var
  LProduto: TJSONObject;
begin
  Result := nil;

  LProduto := Buscar(AId);

  if LProduto = nil then
    Exit;

  LProduto.Strings['nome'] :=
    AProduto.Get('nome', LProduto.Get('nome', ''));

  LProduto.Floats['preco'] :=
    AProduto.Get('preco', LProduto.Get('preco', 0.0));

  LProduto.Integers['estoque'] :=
    AProduto.Get('estoque', LProduto.Get('estoque', 0));

  Result := LProduto;
end;

function TProdutoRepositoryMemoria.Excluir(
  AId: Integer): Boolean;
var
  I: Integer;
  LProduto: TJSONObject;
begin
  Result := False;

  for I := 0 to FProdutos.Count - 1 do
  begin
    LProduto := FProdutos.Objects[I];

    if LProduto.Get('id', 0) = AId then
    begin
      FProdutos.Delete(I);
      Result := True;
      Exit;
    end;
  end;
end;

end.
